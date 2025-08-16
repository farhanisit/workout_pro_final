// Bottom Navigation Scaffold-- Main tab host for the app
// - Displays Home, Progress, and Profile tabs
// - Uses NavigationBar for tab selection
// - Updates selected tab when route changes
// - Uses IndexedStack to maintain state of each tab
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import 'home_screen.dart';
import 'package:workout_pro/features/progress/progress_screen.dart';
import 'profile_screen.dart';

// - Reads the route param (:index) on construct
// - Updates selected tab when the route changes (didUpdateWidget)
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
    setState(() => _index = i); // Update local state
    // Update the route to reflect the new tab index
    // e.g. /tabs/0, /tabs/1, /tabs/2
    context.go('/tabs/$i'); // update the route
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
