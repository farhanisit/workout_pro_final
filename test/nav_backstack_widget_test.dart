// nav_backstack_widget_test.dart - Tests navigation backstack behavior in Workout Pro
// - Verifies that programmatic back navigation works correctly
// - Ensures that tab navigation does not interfere with backstack
// - Uses GoRouter for navigation and widget testing
// - Supports both production and test environments

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_pro/testing/keys.dart';

final _navKey = GlobalKey<NavigatorState>(); // ← control the stack directly

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListTile(
        key: TKeys.totalWorkoutsTile,
        title: const Text('Total Workouts Logged'),
        onTap: () =>
            context.push('/exercise-list'), // push so Back returns here
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) =>
            context.go('/tabs/$i'), // go for tab switch
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Progress'),
        ],
      ),
    );
  }
}

class ListPage extends StatelessWidget {
  const ListPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Your Exercises')),
      );
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Progress')));
}

GoRouter _router() => GoRouter(
      navigatorKey: _navKey, // ← give us access to pop()
      routes: [
        GoRoute(path: '/tabs/0', builder: (_, __) => const HomePage()),
        GoRoute(path: '/tabs/1', builder: (_, __) => const ProgressPage()),
        GoRoute(path: '/exercise-list', builder: (_, __) => const ListPage()),
      ],
      initialLocation: '/tabs/0',
    );

void main() {
  testWidgets('push to list, programmatic back; tabs switch with go()',
      (tester) async {
    final r = _router();
    await tester.pumpWidget(MaterialApp.router(routerConfig: r));
    await tester.pumpAndSettle();

    // Push list from Home
    await tester.tap(find.byKey(TKeys.totalWorkoutsTile));
    await tester.pumpAndSettle();
    expect(find.text('Your Exercises'), findsOneWidget);

    // Programmatic back (no reliance on platform back button widget)
    expect(_navKey.currentState!.canPop(), isTrue);
    _navKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);

    // Switch to Progress via go()
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Progress'), findsOneWidget);

    // Back now should NOT return to the List page (tabs used go())
    final canPop = _navKey.currentState!.canPop();
    if (canPop) {
      _navKey.currentState!.pop();
      await tester.pumpAndSettle();
    }
    expect(find.text('Your Exercises'), findsNothing);
  });
}
