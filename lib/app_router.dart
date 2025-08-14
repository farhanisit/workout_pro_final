// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Public / auth
import 'auth/signup.dart';
import 'auth/login.dart';
import 'core_screens/screens_/onboardingScreen.dart';

// Tabs host
import 'core_screens/screens_/bottom_nav_scaffold.dart';

// Programs
import 'core_screens/screens_/cardioListScreen.dart';
import 'core_screens/screens_/fullBodyScreen.dart';

// Exercises
import 'core_screens/exercise_list_screen.dart';
import 'core_screens/screens_/create_exercise_screen.dart';
import 'core_screens/exercise_detail_screen.dart';
import 'model/exercise.dart' as model;

// Progress extras
import 'features/progress/streak_detail_screen.dart';

// Dev only
import 'core_screens/firestore_seeder_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  // Auth guard: unauthed → /auth. Authed at public → into tab host.
  redirect: (context, state) async {
    final isAuthed = await _isAuthed();
    final loc = state.matchedLocation;
    const public = {'/', '/auth', '/login'};

    if (!isAuthed && !public.contains(loc)) return '/auth';
    if (isAuthed && public.contains(loc)) return '/tabs/0';
    return null;
  },
  routes: [
    // ---------- Public ----------
    GoRoute(path: '/', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/auth', builder: (_, __) => const Signup()),
    GoRoute(path: '/login', builder: (_, __) => const Login()),

    // ========== TAB HOST (Canonical) ==========
    // /tabs/0 = Home, /tabs/1 = Progress, /tabs/2 = Profile
    GoRoute(
      path: '/tabs/:index',
      builder: (_, state) {
        final i = int.tryParse(state.pathParameters['index'] ?? '0') ?? 0;
        return BottomNavScaffold(initialIndex: i);
      },
    ),

    // ---------- Back-compat aliases ----------
    GoRoute(path: '/main', redirect: (_, __) => '/tabs/0'),
    GoRoute(path: '/dashboard', redirect: (_, __) => '/tabs/0'),
    GoRoute(path: '/profile', redirect: (_, __) => '/tabs/2'),
    GoRoute(path: '/progress', redirect: (_, __) => '/tabs/1'),

    // ---------- Programs ----------
    GoRoute(path: '/cardio-list', builder: (_, __) => const CardioListScreen()),
    GoRoute(path: '/fullbody', builder: (_, __) => FullBodyScreen()),

    // ---------- Exercises (standalone flows: PUSH is fine) ----------
    GoRoute(
      path: '/exercise-list',
      builder: (_, __) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return const _NeedsLogin();
        return ExerciseListScreen(
          firestore: FirebaseFirestore.instance,
          userId: user.uid,
        );
      },
    ),
    GoRoute(
      path: '/create-exercise',
      builder: (_, __) => const CreateExerciseScreen(),
    ),
    GoRoute(
      path: '/streak-detail',
      builder: (_, __) => const StreakDetailScreen(),
    ),
    GoRoute(
      path: '/exercises',
      builder: (_, __) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return const _NeedsLogin();
        return ExerciseListScreen(
          firestore: FirebaseFirestore.instance,
          userId: user.uid,
        );
      },
      routes: [
        GoRoute(
          path: 'detail',
          builder: (_, state) {
            final exercise = state.extra as model.Exercise?;
            if (exercise == null) {
              return const Scaffold(
                body: Center(child: Text('No exercise selected.')),
              );
            }
            return ExerciseDetailScreen(exercise: exercise);
          },
        ),
        GoRoute(
          path: 'form',
          builder: (_, state) =>
              CreateExerciseScreen(initial: state.extra as model.Exercise?),
        ),
      ],
    ),

    // ---------- Dev only ----------
    if (!const bool.fromEnvironment('dart.vm.product'))
      GoRoute(path: '/seed', builder: (_, __) => const SeederScreen()),
  ],
  errorBuilder: (_, __) =>
      const Scaffold(body: Center(child: Text('404 - Page Not Found'))),
);

class _NeedsLogin extends StatelessWidget {
  const _NeedsLogin();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Please log in.')));
}

Future<bool> _isAuthed() async {
  await Future.delayed(const Duration(milliseconds: 80));
  return FirebaseAuth.instance.currentUser != null;
}
