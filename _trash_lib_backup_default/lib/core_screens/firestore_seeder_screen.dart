import 'package:flutter/material.dart';
import 'package:workout_pro/core_screens/firestore_seeder.dart'; // Seeder logic

// SeederScreen provides a simple UI to trigger Firestore data seeding.
class SeederScreen extends StatelessWidget {
  const SeederScreen({super.key});

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔥 Firestore Seeder"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚠️ Developer Utility Only",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Tap the button below to seed all predefined gym and cardio exercises into Firestore. Use with caution.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.fitness_center),
              label: const Text("Seed All Exercises to Firestore"),
              onPressed: () async {
                try {
                  await seedAllGymExercises(); // actual seeding method
                  _showSnackBar(context, "✅ Successfully seeded exercises!");
                } catch (e) {
                  _showSnackBar(context, "❌ Seeding failed: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const Spacer(),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Exit Seeder"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
