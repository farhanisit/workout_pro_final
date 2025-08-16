// firestore_service.dart - Service for managing Firestore operations in Workout Pro
// - Provides methods for user profile management and workout storage
// - Uses FirebaseAuth for user authentication
// - Supports both production and test environments

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid => _auth.currentUser!.uid;

  // Save user profile
  Future<void> createUserProfile(String email) async {
    final doc = _firestore.collection('users').doc(uid);
    await doc.set({
      'email': email,
      'createdAt': Timestamp.now(),
    }, SetOptions(merge: true)); // Merge to avoid overwriting
  }

  // Save a workout for the user
  Future<void> addWorkout(
      String name, List<Map<String, dynamic>> exercises) async {
    final doc =
        _firestore.collection('users').doc(uid).collection('workouts').doc();

    await doc.set({
      'name': name,
      'exercises': exercises,
      'createdAt': Timestamp.now(),
    });
  }

  // Fetch saved workouts
  Stream<QuerySnapshot> getWorkouts() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
