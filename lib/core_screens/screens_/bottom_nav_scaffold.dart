// lib/core_screens/screens_/bottom_nav_scaffold.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import 'home_screen.dart';
import 'package:workout_pro/features/progress/progress_screen.dart';
import 'profile_screen.dart';

/// Hosts the three tabs. IMPORTANT:
/// - Reads the route param (:index) on construct
/// - Updates selected tab when the route changes (didUpdateWidget)
/// - Uses `context.go('/tabs/$i')` to switch tabs (no stacking hosts)
class BottomNavScaffold extends StatefulWidget {
  final int initialIndex;
  const BottomNavScaffold({super.key, this.initialIndex = 0});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 2);
  }

  // When router goes from /tabs/1 -> /tabs/0, this widget
  // is rebuilt with a different `initialIndex`. Sync our state.
  @override
  void didUpdateWidget(covariant BottomNavScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex &&
        widget.initialIndex != _index) {
      setState(() => _index = widget.initialIndex.clamp(0, 2));
    }
  }

  void _onTap(int i) {
    if (i == _index) return;
    setState(() => _index = i); // update immediately for snappy UI
    context.go('/tabs/$i'); // make route canonical
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      ProgressScreen(firestore: FirebaseFirestore.instance),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
