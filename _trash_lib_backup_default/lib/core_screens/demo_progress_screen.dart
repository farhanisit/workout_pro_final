import 'package:flutter/material.dart';

// A demo screen to preview your app's progress bar styling from theme.dart
class DemoProgressScreen extends StatelessWidget {
  const DemoProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // DEBUG PRINTS: Helpful during dev, remove before production
    print("Theme primaryColor: ${Theme.of(context).primaryColor}");
    print(
        "\uD83D\uDD25 ProgressIndicatorTheme color: ${Theme.of(context).progressIndicatorTheme.color}");
    print(
        "\uD83D\uDD25 AppBarTheme color: ${Theme.of(context).appBarTheme.backgroundColor}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Demo"),
        // backgroundColor: Colors.red, // Uncomment to override AppBar color manually
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //  Title
              Text(
                "Your Custom Progress Bar",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Linear progress bar that reflects your theme colors
              LinearProgressIndicator(
                value: 0.6, // Pretend 60% progress
                minHeight: 10,
              ),

              const SizedBox(height: 24),

              //  Optional fallback example for color testing
              LinearProgressIndicator(
                value: 0.6,
                minHeight: 10,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF800080)),
              ),

              Text(
                "If the above bar isn't purple, your theme isn't applied.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
DemoProgressScreen is a standalone widget used to preview how LinearProgressIndicator
adapts to the current theme. It’s mostly for testing and showcasing how theming
from theme.dart is applied across visual elements like AppBar and Progress bar.
*/
