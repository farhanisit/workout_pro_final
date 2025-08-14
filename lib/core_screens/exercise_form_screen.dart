import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/exercise.dart';
import '../services/exercise_service.dart' as svc;

/// Create / edit exercise form.
/// Uses ExerciseService(firestore,userId) consistently.
class ExerciseFormScreen extends StatefulWidget {
  const ExerciseFormScreen({super.key});
  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  late final svc.ExerciseService _service;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _gifController = TextEditingController();
  String _selectedBodyPart = 'Upper Body';

  Exercise? _editingExercise;
  bool _isSaving = false;

  final List<String> _bodyParts = ['Upper Body', 'Lower Body'];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    assert(user != null, 'ExerciseFormScreen requires auth.');
    _service = svc.ExerciseService(
      firestore: FirebaseFirestore.instance,
      userId: user!.uid,
    );
  }

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
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Exercise updated")));
        }
      } else {
        await _service.createExercise(exercise);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Exercise created")));
        }
      }
      if (context.mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _equipmentController.dispose();
    _gifController.dispose();
    super.dispose();
  }

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
              _text("Name", _nameController),
              _text("Target", _targetController),
              _text("Equipment", _equipmentController),
              _dropdown("Body Part"),
              _text("GIF URL (optional)", _gifController, required: false),
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

  Widget _text(String label, TextEditingController c, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
            : null,
      ),
    );
  }

  Widget _dropdown(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedBodyPart,
        items: _bodyParts
            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
            .toList(),
        onChanged: (v) => setState(() => _selectedBodyPart = v!),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }
}
