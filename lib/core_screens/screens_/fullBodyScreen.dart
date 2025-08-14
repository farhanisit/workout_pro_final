import 'package:flutter/material.dart'; // UI framework
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore for realtime DB
import 'package:go_router/go_router.dart'; // Routing navigation
import 'package:workout_pro/model/exercise.dart'; // exercise model
import 'package:workout_pro/features/display_exercise.dart'; // Page to show exercise details

class FullBodyScreen extends StatelessWidget {
  // Stateless screen that displays full-body exercises from Firestore
  final String bodyPart; // Muscle group filter for workouts
  const FullBodyScreen({super.key, this.bodyPart = 'fullbody'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Fetch the current theme for styling

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(// Dynamic title (eg; Fullbody workouts)
            "${bodyPart[0].toUpperCase()}${bodyPart.substring(1)} Workouts"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exercises')
            .where('bodyPart', isEqualTo: bodyPart)
            .snapshots(), // Listen to real-time updates of workouts for this body part
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // While loading data
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No workouts found.")); // No data fallback
          }

          final exercises = snapshot.data!.docs.map((doc) {
            // Parse Firestore documents into Exercise objects
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

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: theme.cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(ex.name, style: theme.textTheme.titleMedium),
                  subtitle: Text("Target: ${ex.target}"),
                  trailing: const Icon(Icons.fitness_center),
                  onTap: () {
                    // Navigate to display page for selected workout
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
      floatingActionButton: FloatingActionButton(
        // FAB to create new workout with pre-filled bodyPart
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
FullBodyScreen filters and shows workouts based on body part (Default full body).
It uses Firestore's real-tie stream and maps them into cards.Each workout can be viewed in detail, 
and new ones can be added via FAB which pre-fills the category.
 */
