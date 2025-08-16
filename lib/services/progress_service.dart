// progress_service.dart - Service for managing user workout progress in Workout Pro
// - Logs completed workouts with duration
// - Fetches user progress history
// - Provides total workout count


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressService {
  final FirebaseFirestore firestore;
  final String uid;

  ProgressService({FirebaseFirestore? firestore, String? userId})
      : firestore = firestore ?? FirebaseFirestore.instance,
        uid = userId ?? (FirebaseAuth.instance.currentUser?.uid ?? '') {
    assert(uid.isNotEmpty,
        'ProgressService requires an authenticated user (uid missing).');
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('users').doc(uid).collection('progress');

  /// 🏁 Log a completed (timed) workout
  Future<void> logWorkout({
    required String exerciseId,
    required int durationInSeconds,
  }) async {
    await _col.add({
      'exerciseId': exerciseId,
      'duration': durationInSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// 📦 All session logs for the current user (latest first)
  Future<List<Map<String, dynamic>>> getUserProgress() async {
    final snap = await _col.orderBy('timestamp', descending: true).get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .toList(growable: false);
  }

  /// 🔢 Total number of logged sessions
  Future<int> getWorkoutCount() async {
    final snap = await _col.get();
    return snap.size;
  }
}
