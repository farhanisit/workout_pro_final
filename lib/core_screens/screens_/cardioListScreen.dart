// cardioListScreen.dart - Displays a list of cardio workouts from Firestore
// - Uses Firestore to fetch cardio exercises
// - Displays exercises in a scrollable list with cards
// - Each exercise can be tapped to view details or create a new one

import 'package:flutter/material.dart'; // Flutter UI rendering
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore DB
import 'package:go_router/go_router.dart'; // Routing system for navigation
import 'package:workout_pro/model/exercise.dart'; // Exercise model
import 'package:workout_pro/features/display_exercise.dart'; // Detail screen to display a single exercise

// cardioListScreen: A stateless widget to list cardio workouts from Firestore
class CardioListScreen extends StatelessWidget {
  final String bodyPart;
  const CardioListScreen({super.key, this.bodyPart = 'Cardio'});

  // Builds UI for cardio workout list
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
            "${bodyPart[0].toUpperCase()}${bodyPart.substring(1)} Workouts"),
      ),
      // StreamBuilder: Listens to real-time updates from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exercises')
            .where('bodyPart', isEqualTo: bodyPart)
            .snapshots(),
        builder: (context, snapshot) {
          // Show loader while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show fallback if no data is returned
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No workouts found."));
          }
          // Map Firestore documents into exercise objects
          final exercises = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Exercise(
              id: doc.id,
              name: data['name'] ?? 'No name',
              gif: data['gif'] ?? '',
              equipment: data['equipment'] ?? '',
              target: data['target'] ?? '',
              bodyPart: data['bodyPart'] ?? '',
            );
          }).toList();
          // List all exercises in a scrollable list
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return Card(
                color: theme.cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(ex.name, style: theme.textTheme.titleMedium),
                  subtitle: Text("Target: ${ex.target}"),
                  trailing: const Icon(Icons.fitness_center),
                  onTap: () {
                    // Navigate to exercise detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DisplayExercise(exercise: ex),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // FAB: navigate to create-exercise screen with bodyPart prefilled
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-exercise', extra: {'bodyPart': bodyPart});
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
/*
CardioListScreen:
==================
Displays a real-time list of cardio (or passed body part) workouts fetched from Firestore.
Includes navigation to the CreateExerciseScreen and allows users to view details by tapping.
==================
*/
