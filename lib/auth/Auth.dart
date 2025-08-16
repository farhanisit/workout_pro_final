// ================================
// AuthService.dart
// ================================

// AuthService.dart - Centralized service for Firebase Authentication
// - Handles user sign up, sign in, and sign out
// - Provides a stream to listen to authentication state changes
// - Uses FirebaseAuth for backend authentication
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

 
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Signup error: ${e.toString()}');
      return null;
    }
  }

  /// Signs in a user using email and password.
  /// Returns the [User] if successful, else returns null.
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Sign-in error: ${e.toString()}');
      return null;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign-out error: ${e.toString()}');
    }
  }

  /// Returns the currently logged-in user, or null.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Returns the UID of the currently logged-in user, or null.
  String? getUserId() {
    return _auth.currentUser?.uid;
  }
}
/*
AuthService:
=================
A lightweight authentication utility class to manage FirebaseAuth operations.
Includes methods for signing in (`signIn`) and signing out (`signOut`) using Firebase.
All auth logic is wrapped with error handling for robustness.
*/
