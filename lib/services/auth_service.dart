// auth_service.dart - Centralized service for Firebase Authentication
// - Handles user sign up, sign in, and sign out
// - Provides a stream to listen to authentication state changes
// - Uses FirebaseAuth for backend authentication

import 'package:firebase_auth/firebase_auth.dart';

// A centralized AuthService to handle all Firebase Auth logic
class AuthService {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up using email & password
  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Sign Up Error: $e');
      return null;
    }
  }

  // Login using email & password
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }

  // Log out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream to listen to auth state changes (e.g., auto-login)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current logged-in user (or null)
  User? getCurrentUser() => _auth.currentUser;
}
