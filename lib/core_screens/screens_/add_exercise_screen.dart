//*************
// add_exercise_screen.dart - Allows users to log a new workout exercise
// - Includes dropdowns for most fields and async exercise name selector
// - Uses Firestore to save exercise data
// - Provides form validation and error handling
// - Displays success message and navigates back to app dashboard
// *************
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_pro/model/exercise.dart';
import 'package:workout_pro/services/exercise_service.dart';

// AddExerciseScreen allows users to log a new workout exercise.
// Includes dropdowns for most fields and async exercise name selector.
class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({Key? key}) : super(key: key);

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form inputs
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _bodyPartController = TextEditingController();
  final _gifController = TextEditingController();

  final ExerciseService _exerciseService = ExerciseService();
  bool _isSaving = false;

  // Static dropdown options
  final List<String> _equipmentOptions = [
    'Bodyweight',
    'Dumbbell',
    'Barbell',
    'Machine',
    'Other',
  ];

  final List<String> _bodyPartOptions = [
    'Upper Body',
    'Lower Body',
    'Arms',
    'Shoulders',
    'Back',
    'Full Body',
  ];

  final List<String> _targetOptions = [
    'Abs',
    'Chest',
    'Glutes',
    'Biceps',
    'Triceps',
    'Quads',
    'Hamstrings',
    'Calves',
    'Shoulders',
    'Back',
  ];

  // Handles form submission and saves exercise to Firestore
  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final newExercise = Exercise(
      name: _nameController.text.trim(),
      target: _targetController.text.trim(),
      equipment: _equipmentController.text.trim(),
      bodyPart: _bodyPartController.text.trim(),
      gif: _gifController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _exerciseService.createExercise(newExercise);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise successfully added!')),
      );

      context.go('/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving exercise: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _equipmentController.dispose();
    _bodyPartController.dispose();
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Exercise")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Async dropdown for exercise name
              FutureBuilder<List<String>>(
                future: _exerciseService.fetchUniqueExerciseNames(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final names = snapshot.data ?? [];

                  // Show dropdown if data found, else fallback to manual
                  return names.isNotEmpty
                      ? _buildDropdown("Exercise Name", names, _nameController)
                      : _buildTextField("Exercise Name", _nameController);
                },
              ),
              _buildDropdown("Target", _targetOptions, _targetController),
              _buildDropdown(
                  "Body Part", _bodyPartOptions, _bodyPartController),
              _buildDropdown(
                  "Equipment", _equipmentOptions, _equipmentController),
              _buildTextField("GIF URL (optional)", _gifController,
                  required: false),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Add Exercise"),
                onPressed: _isSaving ? null : _saveExercise,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) => (value == null || value.trim().isEmpty)
                ? 'Required field'
                : null
            : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: options.contains(controller.text) ? controller.text : null,
        items: options
            .map((val) => DropdownMenuItem(value: val, child: Text(val)))
            .toList(),
        onChanged: (value) => controller.text = value ?? '',
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Please select $label' : null,
      ),
    );
  }
}
