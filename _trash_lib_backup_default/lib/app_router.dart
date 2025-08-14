import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workout_pro/auth/login.dart';
import 'package:workout_pro/core_screens/screens_/home_screen.dart';
import 'package:workout_pro/features/progress/progress_screen.dart';
import 'package:workout_pro/core_screens/exercise_list_screen.dart';
import 'package:workout_pro/core_screens/exercise_form_screen.dart'
    show CreateExerciseScreen;

abstract final class AppRoutes {
  static const login = 'login';
  static const home = 'home';
  static const progress = 'progress';
  static const manageWorkouts = 'manageWorkouts';
  static const createExercise = 'createExercise';
}

final class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier(this._auth) {
    _sub = _auth.authStateChanges().listen((_) => notifyListeners());
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final class AppRouter {
  AppRouter._(this.router);

  factory AppRouter.create() {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final notifier = AuthStateNotifier(auth);

    final router = GoRouter(
      debugLogDiagnostics: false,
      initialLocation: '/login',
      refreshListenable: notifier,
      redirect: (context, state) {
        final user = auth.currentUser;
        final goingToLogin = state.matchedLocation == '/login';

        if (user == null) {
          return goingToLogin ? null : '/login';
        }
        if (goingToLogin) {
          return '/home';
        }
        return null;
      },
      routes: <RouteBase>[
        // Public
        GoRoute(
          name: AppRoutes.login,
          path: '/login',
          pageBuilder: (context, state) => const MaterialPage(child: Login()),
        ),

        // Private shell
        GoRoute(
          name: AppRoutes.home,
          path: '/home',
          pageBuilder: (context, state) =>
              const MaterialPage(child: HomeScreen()),
          routes: <RouteBase>[
            GoRoute(
              name: AppRoutes.progress,
              path: 'progress',
              pageBuilder: (context, state) {
                final user = FirebaseAuth.instance.currentUser!;
                return MaterialPage(
                  child: ProgressScreen(
                    firestore: firestore,
                    userId: user.uid,
                  ),
                );
              },
            ),
            GoRoute(
              name: AppRoutes.manageWorkouts,
              path: 'manage',
              pageBuilder: (context, state) {
                final user = FirebaseAuth.instance.currentUser!;
                return MaterialPage(
                  child: ExerciseListScreen(
                    firestore: firestore,
                    userId: user.uid,
                  ),
                );
              },
            ),
          ],
        ),

        // Top-level create (so FAB /create-exercise works anywhere)
        GoRoute(
          name: AppRoutes.createExercise,
          path: '/create-exercise',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CreateExerciseScreen()),
        ),
      ],
      errorPageBuilder: (context, state) => MaterialPage(
        child: Scaffold(
          appBar: AppBar(title: const Text('Navigation Error')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Route not found or failed to build.\n\nLocation: ${state.uri}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    return AppRouter._(router);
  }

  final GoRouter router;
}
