// lib/services/exercise_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_pro/model/exercise.dart';
import 'package:meta/meta.dart'; // for @visibleForTesting

/// Central service for CRUD + analytics.
/// Storage path: users/{uid}/exercises/{docId}
class ExerciseService {
  final FirebaseFirestore firestore;
  final String uid;

  // Production / normal constructor
  ExerciseService({FirebaseFirestore? firestore, String? userId})
      : firestore = firestore ?? FirebaseFirestore.instance,
        uid = userId ?? (FirebaseAuth.instance.currentUser?.uid ?? '') {
    assert(uid.isNotEmpty,
        'ExerciseService requires an authenticated user (uid missing).');
  }

  // ✅ Test-only constructor (no FirebaseAuth needed in tests)
  @visibleForTesting
  ExerciseService.test(
      {required FirebaseFirestore firestore, required String userId})
      : firestore = firestore,
        uid = userId;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('users').doc(uid).collection('exercises');

  // ---------- Create / Update / Delete ----------

  Future<void> createExercise(Exercise e) async {
    await _col.add({
      'name': e.name,
      'target': e.target,
      'equipment': e.equipment,
      'bodyPart': e.bodyPart,
      'gif': e.gif,
      'duration': e.duration,
      'createdAt': FieldValue.serverTimestamp(), // single source of truth
    });
  }

  Future<void> updateExercise(String id, Exercise e) async {
    // We do not touch createdAt on update.
    await _col.doc(id).update({
      'name': e.name,
      'target': e.target,
      'equipment': e.equipment,
      'bodyPart': e.bodyPart,
      'gif': e.gif,
      'duration': e.duration,
    });
  }

  Future<void> deleteExercise(String id) => _col.doc(id).delete();

  // ---------- Reads ----------

  Stream<List<Exercise>> streamExercises({
    String search = '',
    String bodyPart = 'ALL',
  }) {
    final s = search.trim().toLowerCase();
    final bp = bodyPart.trim().toLowerCase();

    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).where((e) {
              final nameOk = s.isEmpty || e.name.toLowerCase().contains(s);
              final bpOk =
                  (bp == 'all') || e.bodyPart.trim().toLowerCase() == bp;
              return nameOk && bpOk;
            }).toList());
  }

  Future<List<Exercise>> fetchExercises({int limit = 200}) async {
    final q =
        await _col.orderBy('createdAt', descending: true).limit(limit).get();
    return q.docs.map(_fromDoc).toList();
  }

  Future<List<String>> fetchUniqueExerciseNames({int limit = 200}) async {
    final q = await _col.orderBy('name').limit(limit).get();
    final set = <String>{};
    for (final d in q.docs) {
      final n = (d.data()['name'] as String?)?.trim();
      if (n != null && n.isNotEmpty) set.add(n);
    }
    final list = set.toList()..sort();
    return list;
  }

  // ---------- Analytics ----------

  /// 7 buckets (oldest → newest), counts by day.
  Future<List<int>> getWeeklyWorkoutData() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6)); // inclusive 7 days

    final q = await _col
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('createdAt')
        .get();

    final buckets = List<int>.filled(7, 0);
    for (final d in q.docs) {
      final ts = d.data()['createdAt'];
      if (ts is! Timestamp) continue; // ignore pending nulls
      final idx = ts.toDate().difference(start).inDays;
      if (idx >= 0 && idx < 7) buckets[idx]++;
    }
    return buckets;
  }

  /// Total documents in the user’s exercises (small datasets).
  Future<int> getTotalCount() async {
    final q = await _col.get();
    return q.size;
  }

  /// Consecutive-day streak ending today.
  Future<int> getStreakDays() async {
    final q =
        await _col.orderBy('createdAt', descending: true).limit(500).get();
    if (q.docs.isEmpty) return 0;

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    var streak = 0;
    final seen = <String>{};

    for (final d in q.docs) {
      final ts = d.data()['createdAt'];
      if (ts is! Timestamp) continue;
      final dt = ts.toDate();
      final key = _dayKey(dt);
      if (seen.contains(key)) continue; // collapse same-day multiples

      if (_sameDay(dt, cursor)) {
        streak++;
        seen.add(key);
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (dt.isAfter(cursor)) {
        continue; // same day already handled
      } else {
        break; // gap
      }
    }
    return streak;
  }

  /// Breakdown of sessions by bodyPart over the last [days].
  Future<Map<String, int>> getBodyPartBreakdown({int days = 30}) async {
    final start = DateTime.now().subtract(Duration(days: days));
    final q = await _col
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .get();

    final map = <String, int>{};
    for (final d in q.docs) {
      final m = d.data();
      final ts = m['createdAt'];
      if (ts is! Timestamp) continue;
      final bp = (m['bodyPart'] as String? ?? 'Unknown').trim();
      if (bp.isEmpty) continue;
      map[bp] = (map[bp] ?? 0) + 1;
    }

    return map;
  }

  // ---------- Helpers ----------

  Exercise _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    final ts = m['createdAt'];
    return Exercise(
      id: d.id,
      name: (m['name'] ?? '') as String,
      target: (m['target'] ?? '') as String,
      equipment: (m['equipment'] ?? '') as String,
      bodyPart: (m['bodyPart'] ?? '') as String,
      gif: (m['gif'] ?? '') as String,
      duration: (m['duration'] as num?)?.toInt(),
      createdAt: (ts is Timestamp) ? ts.toDate() : null,
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
