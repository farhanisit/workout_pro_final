import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:workout_pro/features/progress/models/body_part.dart';
import 'package:workout_pro/model/exercise.dart';
import 'package:workout_pro/services/exercise_service.dart';

class CreateExerciseScreen extends StatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _target = TextEditingController();
  final _equipment = TextEditingController();
  final _gifUrl = TextEditingController();
  final _duration = TextEditingController();

  BodyPart? _selectedBodyPart;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _equipment.dispose();
    _gifUrl.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    if (!_formKey.currentState!.validate() || _selectedBodyPart == null) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = ExerciseService(
        firestore: FirebaseFirestore.instance,
        userId: user.uid,
      );

      final ex = Exercise(
        name: _name.text.trim(),
        gif: _gifUrl.text.trim(),
        equipment: _equipment.text.trim(),
        target: _target.text.trim(),
        bodyPart: _selectedBodyPart!.displayName,
        duration: int.tryParse(_duration.text.trim()),
        createdAt: DateTime.now(),
      );

      await service.createExercise(ex);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Exercise added!')));
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding exercise: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Exercise'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Exercise Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _target,
                  decoration:
                      const InputDecoration(labelText: 'Target (e.g. abs)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<BodyPart>(
                  value: _selectedBodyPart,
                  decoration: const InputDecoration(labelText: 'Target Area'),
                  items: BodyPart.values
                      .where((p) => p != BodyPart.unknown)
                      .map((bp) => DropdownMenuItem(
                            value: bp,
                            child: Text(bp.displayName),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBodyPart = val),
                  validator: (val) => val == null ? 'Select a body part' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _equipment,
                  decoration: const InputDecoration(labelText: 'Equipment'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _gifUrl,
                  decoration: const InputDecoration(labelText: 'GIF URL'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _duration,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Duration (minutes)'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Duration required';
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(_isSubmitting ? 'Adding...' : 'Add Exercise'),
                    onPressed: _isSubmitting ? null : _addExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
