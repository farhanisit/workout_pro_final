// user_service.dart - Service for managing user profiles in Workout Pro
// - Provides methods for creating, updating, and fetching user profiles
// - Uses Firestore for storage
// - Supports both production and test environments


import 'package:cloud_firestore/cloud_firestore.dart';

// UserService: Clean Firestore service layer with safe CRUD ops
class UserService {
  final FirebaseFirestore _firestore;

  // Optional DI constructor for testability
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  // Create new user profile (only if not exists)
  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? name,
    String? gender,
    String? goal,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = usersCollection.doc(uid);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          transaction.set(docRef, {
            'email': email,
            'name': name ?? '',
            'gender': gender ?? '',
            'goal': goal ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'modifiedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile map from Firestore
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    try {
      final snapshot = await usersCollection.doc(uid).get();
      return snapshot.data() ?? {};
    } catch (e) {
      rethrow;
    }
  }

  // Update a single field in user's profile atomically
  Future<void> updateUserField(
    String uid,
    String fieldName,
    dynamic value,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = usersCollection.doc(uid);
        final snapshot = await transaction.get(docRef);

        final dataToUpdate = {
          fieldName: value,
          'modifiedAt': FieldValue.serverTimestamp(),
        };

        if (!snapshot.exists) {
          transaction.set(docRef, {
            ...dataToUpdate,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.update(docRef, dataToUpdate);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Ensure doc exists — useful before any edits
  Future<void> ensureUserDocExists(String uid,
      {Map<String, dynamic>? defaultFields}) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = usersCollection.doc(uid);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          transaction.set(docRef, {
            'createdAt': FieldValue.serverTimestamp(),
            'modifiedAt': FieldValue.serverTimestamp(),
            ...?defaultFields,
          });
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Check if user document exists (from cache or server)
  Future<bool> doesUserExist(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get(
            const GetOptions(source: Source.serverAndCache),
          );
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  // Generate dynamic greeting like "Welcome, Mr. Khan" based on gender + name
  Future<String> getWelcomeGreeting(String uid) async {
    try {
      final profile = await getUserProfile(uid);
      final name = profile['name']?.toString().trim().split(' ') ?? [];
      final gender = profile['gender']?.toString().toLowerCase() ?? '';

      final surname = name.isNotEmpty ? name.last : '';
      final prefix = (gender == 'male')
          ? 'Mr.'
          : (gender == 'female')
              ? 'Ms.'
              : '';

      return 'Welcome, $prefix $surname';
    } catch (e) {
      return 'Welcome, User';
    }
  }
}
