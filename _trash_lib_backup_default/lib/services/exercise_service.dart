import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_pro/model/exercise.dart';

/// Service layer for Firestore 'exercises' collection (root-level).
class ExerciseService {
  final FirebaseFirestore firestore;
  late final CollectionReference<Map<String, dynamic>> exercisesCollection;
  final String userId; // 🔐 scope queries

  /// Allow test injection; require user scope for multi-tenant correctness.
  ExerciseService({FirebaseFirestore? firestore, required this.userId})
      : firestore = firestore ?? FirebaseFirestore.instance {
    exercisesCollection = this.firestore.collection('exercises');
  }
// Keeps older calls working
  Future<void> deleteExercise(String id) => delete(id);

  // ===========================================================================
  // CREATE
  // ===========================================================================
  Future<String> createExercise(Exercise exercise) async {
    try {
      final data = exercise.toMap()
        ..addAll({
          'userId': userId, // 🔐 partition key
          'createdAt': FieldValue.serverTimestamp(), // 🌐 canonical (UTC)
          'createdAtClient': DateTime.now(), // ⏱️ local fallback
        });

      final docRef = await exercisesCollection.add(data);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // ===========================================================================
  // READ (stream for list screen)
  // ===========================================================================
  /// Returns a typed stream of this user's exercises.
  /// Firestore query kept simple; text/bodyPart filters applied in-memory.
  Stream<List<Exercise>> streamExercises({
    String search = '',
    String bodyPart = 'ALL',
  }) {
    final q =
        exercisesCollection.where('userId', isEqualTo: userId).orderBy('name');

    return q.snapshots().map((snap) {
      final all =
          snap.docs.map((d) => Exercise.fromMap(d.data(), d.id)).toList();

      final byPart = bodyPart == 'ALL'
          ? all
          : all
              .where((e) => e.bodyPart.toLowerCase() == bodyPart.toLowerCase())
              .toList();

      final term = search.trim().toLowerCase();
      if (term.isEmpty) return byPart;

      return byPart.where((e) => e.name.toLowerCase().contains(term)).toList();
    });
  }

  // Single doc fetch (optional if you have a detail screen)
  Future<Exercise?> getById(String id) async {
    final doc = await exercisesCollection.doc(id).get();
    if (!doc.exists) return null;
    return Exercise.fromMap(doc.data()!, doc.id);
  }

  // ===========================================================================
  // UPDATE / DELETE
  // ===========================================================================
  Future<void> updateExercise(String id, Map<String, dynamic> updates) {
    return exercisesCollection.doc(id).update(updates);
  }

  Future<void> delete(String id) {
    return exercisesCollection.doc(id).delete();
  }

  // ===========================================================================
  // ANALYTICS — Weekly Frequency (Mon–Sun)
  // (kept from your version, with small typing cleanups)
  // ===========================================================================
  Future<List<int>> getWeeklyWorkoutData() async {
    try {
      final nowLocal = DateTime.now();

      final startOfWeekLocal = DateTime(
        nowLocal.year,
        nowLocal.month,
        nowLocal.day,
      ).subtract(Duration(days: nowLocal.weekday - 1));

      final endOfWeekLocal = startOfWeekLocal.add(const Duration(days: 7));

      final startUtc = Timestamp.fromDate(startOfWeekLocal.toUtc());
      final endUtc = Timestamp.fromDate(endOfWeekLocal.toUtc());

      final snapshot = await exercisesCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startUtc)
          .where('createdAt', isLessThan: endUtc)
          .get();

      final fallbackSnapshot = await exercisesCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isNull: true)
          .where('createdAtClient', isGreaterThanOrEqualTo: startOfWeekLocal)
          .where('createdAtClient', isLessThan: endOfWeekLocal)
          .get();

      final counts = List<int>.filled(7, 0);

      void accumulate(QuerySnapshot<Map<String, dynamic>> s) {
        for (final doc in s.docs) {
          final data = doc.data();
          final ts = data['createdAt'] as Timestamp?;
          final when = (ts?.toDate() ??
              (data['createdAtClient'] as DateTime?) ??
              DateTime.fromMillisecondsSinceEpoch(0));
          final idx = when.weekday - 1; // 0..6
          if (idx >= 0 && idx < 7) counts[idx]++;
        }
      }

      accumulate(snapshot);
      accumulate(fallbackSnapshot);

      return counts;
    } catch (_) {
      return List<int>.filled(7, 0);
    }
  }

  Future<List<Map<String, dynamic>>> getProgressStats() async {
    final weeklyData = await getWeeklyWorkoutData();
    return [
      {'weeklyData': weeklyData}
    ];
  }

  Stream<List<int>> getWeeklyWorkoutDataStream() async* {
    final nowLocal = DateTime.now();
    final startOfWeekLocal = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
    ).subtract(Duration(days: nowLocal.weekday - 1));
    final endOfWeekLocal = startOfWeekLocal.add(const Duration(days: 7));
    final startUtc = Timestamp.fromDate(startOfWeekLocal.toUtc());
    final endUtc = Timestamp.fromDate(endOfWeekLocal.toUtc());

    final base = exercisesCollection
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startUtc)
        .where('createdAt', isLessThan: endUtc)
        .snapshots();

    await for (final snap in base) {
      final counts = List<int>.filled(7, 0);
      for (final doc in snap.docs) {
        final data = doc.data();
        final ts = data['createdAt'] as Timestamp?;
        final when = (ts?.toDate() ??
            (data['createdAtClient'] as DateTime?) ??
            DateTime.fromMillisecondsSinceEpoch(0));
        final idx = when.weekday - 1;
        if (idx >= 0 && idx < 7) counts[idx]++;
      }
      yield counts;
    }
  }
}
