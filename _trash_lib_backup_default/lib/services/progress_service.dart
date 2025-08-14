import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressService {
  final _db = FirebaseFirestore.instance;

  /// 🏁 Log a completed workout for the current user
  Future<void> logWorkout({
    required String exerciseId,
    required int durationInSeconds,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('user_progress').add({
      'uid': user.uid,
      'exerciseId': exerciseId,
      'duration': durationInSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// 📦 Get all completed workouts for current user
  Future<List<Map<String, dynamic>>> getUserProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('user_progress')
        .where('uid', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// 🔢 Get total number of workouts done
  Future<int> getWorkoutCount() async {
    final progress = await getUserProgress();
    return progress.length;
  }
}
