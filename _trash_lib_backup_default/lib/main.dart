// Flutter and Dart core packages
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Firebase packages for backend and authentication
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// State management and dev tools
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

// Project-specific imports
import 'firebase_options.dart';
import 'app_router.dart';
import 'package:workout_pro/theme/theme.dart';
import 'package:workout_pro/theme/theme_provider.dart';

// Seeder imports
import 'package:workout_pro/core_screens/firestore_seeder_screen.dart';
import 'package:workout_pro/core_screens/firestore_seeder.dart';
import 'package:workout_pro/services/user_service.dart';

// Seeder flag (set during build time)
const bool isSeederMode = bool.fromEnvironment('SEEDER_MODE');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Optional: auto seed data (if SEEDER_MODE flag is true)
  if (!kReleaseMode && isSeederMode) {
    await seedAllGymExercises();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    if (!isSeederMode) {
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          // Auto-create user profile if missing
          if (!userDoc.exists) {
            await UserService().createUserProfile(
              uid: user.uid,
              email: user.email ?? '',
            );
          }
        }

        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      });
    } else {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Workout Pro',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      themeMode: themeProvider.currentTheme,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      routerConfig: isSeederMode ? _seederRouter() : router,
    );
  }

  // Seeder-only Router to launch SeederScreen
  GoRouter _seederRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SeederScreen(),
        ),
      ],
    );
  }
}
