import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Routing system for navigation

// Initial entry screen of the app to introduce users
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const darkBackground = Color(0xFF1A1A2E); // Deep navy background tone

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Dark gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [darkBackground, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Central icon branding
                const Icon(Icons.fitness_center,
                    size: 100, color: Colors.white),
                const SizedBox(height: 32),
                // Welcome headline
                Text(
                  "Welcome to Workout Pro",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Sub-Headline- explaining app purpose
                Text(
                  "Track your workouts. Build strength. Stay consistent.",
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Sends User to Authentication screen
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('getStartedButton'),
                    onPressed: () => context.go('/auth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      "Get Started",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
==============================
   OnboardingScreen Summary
==============================
Intro screen shown to users on first app launch.
Features:
- Clean, minimal welcome UI with bold typography.
- Encourages user to proceed with account setup.
- Navigates directly to /auth on button tap.
- Styled with a vertical gradient and dark theme.

Acts as the entry point for first-time users and sets the tone of the app.
*/
