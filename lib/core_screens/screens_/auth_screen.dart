// AuthScreen - Handles user authentication (login/signup).
// - Uses Firebase Auth for authentication
// - Initializes Firestore profile for new users
// - Returns to main screen on success
// - Follows async-safety and mounted check rules

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_pro/services/user_service.dart';
import 'package:workout_pro/widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Handles login or sign-up with Firebase Auth and Firestore profile setup
  Future<void> _handleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential;

      if (_isLogin) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user != null) {
          await _userService.createUserProfile(
            uid: user.uid,
            email: user.email ?? '',
            name: user.email!.split('@')[0],
            gender: '',
            goal: '',
          );
        }
      }

      if (mounted) context.go('/main');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? "Authentication failed.");
    } catch (_) {
      setState(() => _errorMessage = "Something went wrong.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Clears all input fields and error messages
  void _clearInputs() {
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            _isLogin ? "Login" : "Sign Up",
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.fitness_center, size: 80),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 12),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Column(
                              children: [
                                PrimaryButton(
                                  label: _isLogin ? "Login" : "Sign Up",
                                  onPressed: _handleAuth,
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _clearInputs,
                                  child: const Text("Clear Inputs"),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  _isLogin
                      ? "Need an account? Sign up"
                      : "Already have an account? Log in",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
AuthScreen:
- Handles login and sign-up using Firebase Authentication.
- Initializes Firestore profile for new accounts.
- Returns to main screen on success.
- Follows async-safety and mounted check rules.
*/
