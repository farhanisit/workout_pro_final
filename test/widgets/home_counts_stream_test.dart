// home_counts_stream_test.dart - Tests the CountsTile widget with a stream
// - Verifies that the subtitle updates when the stream emits new values
// - Uses a StreamController to simulate the stream
// - Ensures the widget is async-safe and uses a local key for subtitle
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_pro/testing/keys.dart';

/// Minimal widget that mimics your Home tile with a stream.
class CountsTile extends StatelessWidget {
  final Stream<int> count$;
  const CountsTile({super.key, required this.count$});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: StreamBuilder<int>(
          stream: count$,
          initialData: 0,
          builder: (_, snap) {
            final c = snap.data ?? 0;
            return ListTile(
              key: TKeys.totalWorkoutsTile,
              title: const Text('Total Workouts Logged'),
              // Give the subtitle a local key so the test can grab it deterministically
              subtitle: Text(
                "You've added $c workouts.",
                key: const Key('countsSubtitle'),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Tile updates when stream emits', (tester) async {
    // Broadcast stream avoids “already listened” pitfalls when widgets rebuild
    final ctrl = StreamController<int>.broadcast();
    addTearDown(ctrl.close);

    await tester.pumpWidget(CountsTile(count$: ctrl.stream));
    await tester.pump(); // allow initial build

    final subtitleFinder = find.byKey(const Key('countsSubtitle'));
    expect(subtitleFinder, findsOneWidget);

    Text subtitle = tester.widget<Text>(subtitleFinder);
    expect(subtitle.data, contains('added 0'));

    // Emit a new value and allow two frames (deflakes rebuild timing)
    ctrl.add(5);
    await tester.pump();
    await tester.pump();

    subtitle = tester.widget<Text>(subtitleFinder);
    expect(subtitle.data, contains('added 5'));
  });
}
