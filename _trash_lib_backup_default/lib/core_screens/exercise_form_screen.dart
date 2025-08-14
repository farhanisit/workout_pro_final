import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Routing System for navigation
import 'package:workout_pro/model/exercise.dart'; // Exercise model
import 'package:workout_pro/services/exercise_service.dart'; // Firestore operations

// ExerciseFormScreen
// Allows user to create or edit a workout
// Data flows through ExerciseService into Firestore
class ExerciseFormScreen extends StatefulWidget {
  const ExerciseFormScreen({super.key});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _gifController = TextEditingController();
  String _selectedBodyPart = 'Upper Body';

  final ExerciseService _service = ExerciseService();
  Exercise? _editingExercise;
  bool _isSaving = false;

  final List<String> _bodyParts = ['Upper Body', 'Lower Body']; // Schema-locked

  // Load existing exercise if editing
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Exercise) {
      _editingExercise = extra;
      _nameController.text = extra.name;
      _targetController.text = extra.target;
      _equipmentController.text = extra.equipment;
      _gifController.text = extra.gif;
      _selectedBodyPart = extra.bodyPart;
    }
  }

  // Save or update workout to Firestore
  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final exercise = Exercise(
      id: _editingExercise?.id,
      name: _nameController.text.trim(),
      target: _targetController.text.trim(),
      equipment: _equipmentController.text.trim(),
      bodyPart: _selectedBodyPart,
      gif: _gifController.text.trim(),
    );

    try {
      if (_editingExercise != null) {
        await _service.updateExercise(_editingExercise!.id!, exercise);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Exercise updated")));
      } else {
        await _service.createExercise(exercise);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Exercise created")));
      }
      if (context.mounted) context.go('/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // UI Renderer
  @override
  Widget build(BuildContext context) {
    final isEdit = _editingExercise != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Workout' : 'Add Workout')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Name", _nameController),
              _buildTextField("Target", _targetController),
              _buildTextField("Equipment", _equipmentController),
              _buildDropdownField("Body Part"),
              _buildTextField("GIF URL (optional)", _gifController,
                  required: false),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveExercise,
                icon: Icon(isEdit ? Icons.save_as : Icons.save),
                label: Text(isEdit ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Text input builder
  Widget _buildTextField(String label, TextEditingController controller,
      {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) =>
                (value == null || value.trim().isEmpty) ? "Required" : null
            : null,
      ),
    );
  }

  // Dropdown builder for bodyPart
  Widget _buildDropdownField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedBodyPart,
        items: _bodyParts
            .map((part) => DropdownMenuItem(value: part, child: Text(part)))
            .toList(),
        onChanged: (value) {
          setState(() => _selectedBodyPart = value!);
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
