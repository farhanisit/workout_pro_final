import 'package:flutter/material.dart'; // Flutter material component for UI rendering
import 'package:go_router/go_router.dart'; // Routing system for navigation
import 'package:workout_pro/model/exercise.dart'; // Model containing exercise data
import 'package:workout_pro/services/exercise_service.dart'; // Firestore CRUD operations

// Screen: ExerciseDetailScreen
// Displays full details of a selected workout, allows editing and deletion.
class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({Key? key, required this.exercise})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ExerciseService _service = ExerciseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          //  Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.pushNamed('exerciseForm',
                  extra: exercise); // Route to edit form
            },
          ),

          //  Delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Workout?"),
                  content: const Text(
                      "Are you sure you want to delete this workout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );

              //  Safe deletion with null-check fallback
              if (confirmed == true) {
                if (exercise.id != null) {
                  await _service.deleteExercise(exercise.id!);
                  if (context.mounted)
                    context.go('/dashboard'); // Go home after delete
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cannot delete: Invalid ID")),
                  );
                }
              }
            },
          ),
        ],
      ),

      // Exercise content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                Text("Workout Details", style: theme.textTheme.titleLarge),
                const Divider(),
                const SizedBox(height: 8),

                // Detail rows
                _buildRow("Name", exercise.name, theme),
                _buildRow("Equipment", exercise.equipment, theme),
                _buildRow("Target", exercise.target, theme),
                _buildRow("Body Part", exercise.bodyPart, theme),

                const SizedBox(height: 20),
                Text("Preview", style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),

                // GIF Display with graceful error fallback
                if (exercise.gif.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      exercise.gif,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Text(
                          'Could not load image.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text("No preview available."),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Utility: Builds labeled key-value display row
  Widget _buildRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
