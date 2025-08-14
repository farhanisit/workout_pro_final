import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core Screens
import 'package:workout_pro/core_screens/screens_/dashboard_screen.dart';
import 'package:workout_pro/core_screens/screens_/profile_screen.dart';
import 'package:workout_pro/features/progress/progress_screen.dart';

/// -------------------------------------------
/// BottomNavScaffold
/// -------------------------------------------
/// Root scaffold with BottomNavigationBar for main app areas:
/// Dashboard (Home), Progress, and Profile.
/// Injects a shared Firestore instance where needed.
///
class BottomNavScaffold extends StatefulWidget {
  const BottomNavScaffold({super.key});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int _selectedIndex = 0;

  // Shared Firestore instance for child screens
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Screens for each navigation tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize screen list once for better performance
    _screens = [
      const DashboardScreen(), // Home
      ProgressScreen(
          firestore: _firestore), // Progress (with Firestore injection)
      const ProfileScreen(), // Profile
    ];
  }

  // Handle tab change
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
