// ExerciseDetailScreen.dart - Displays details of a specific exercise
// Allows users to view exercise information and edit or delete it.
// - Uses Firestore to fetch exercise data

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_pro/model/exercise.dart' as model;
import 'package:workout_pro/services/exercise_service.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final model.Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = ExerciseService(); // uses current user

    Future<void> _delete() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Workout?'),
          content: const Text('Are you sure you want to delete this workout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true && exercise.id != null) {
        await service.deleteExercise(exercise.id!);
        if (context.mounted) {
          Navigator.of(context).pop(); // back to the list (updates via Stream)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout deleted')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/exercises/form', extra: exercise),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workout Details', style: theme.textTheme.titleLarge),
                const Divider(),
                const SizedBox(height: 8),
                _row('Name', exercise.name, theme),
                _row('Equipment', exercise.equipment, theme),
                _row('Target', exercise.target, theme),
                _row('Body Part', exercise.bodyPart, theme),
                const SizedBox(height: 20),
                Text('Preview', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (exercise.gif.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      exercise.gif,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _noImage(),
                    ),
                  )
                else
                  _noImage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _noImage() => Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text('No preview available.'),
      );

  Widget _row(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
