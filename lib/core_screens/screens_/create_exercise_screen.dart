// lib/core_screens/screens_/create_exercise_screen.dart
//
// CreateExerciseScreen: create OR edit an exercise.
// If `initial` is provided, the form pre-fills and saves via update.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_pro/model/exercise.dart' as model;
import 'package:workout_pro/services/exercise_service.dart' as svc;

class CreateExerciseScreen extends StatefulWidget {
  final model.Exercise? initial;
  const CreateExerciseScreen({super.key, this.initial});

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the 5 fields
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _equipment = TextEditingController();
  final _bodyPart = TextEditingController();
  final _gif = TextEditingController();

  late final svc.ExerciseService _service;
  bool _isSaving = false;

  /// Equipment choices stay the same.
  static const _equipmentOptions = <String>[
    'Bodyweight',
    'Dumbbell',
    'Barbell',
    'Machine',
    'Other',
  ];

  /// Body-part categories.
  /// NOTE: the missing comma after 'Full Body' in your file made 'cardio'
  /// stick to it as one long string -> 'Full Bodycardio'. Fixed here.
  static const _bodyPartOptions = <String>[
    'Cardio',
    'Full Body',
    'Upper Body',
    'Lower Body',
    'Arms',
    'Shoulders',
    'Back',
  ];

  /// Targets made meaningful for workouts like Running.
  /// (These are *training goals*, not anatomical parts.)
  static const _targetOptions = <String>[
    'Endurance', // ← default when Cardio is selected (e.g., Running)
    'HIIT',
    'Strength',
    'Hypertrophy',
    'Mobility',
    'Recovery',
    'Power',
    'Speed',
  ];

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _service = svc.ExerciseService(
      firestore: FirebaseFirestore.instance,
      userId: user.uid,
    );

    if (_isEdit) {
      final e = widget.initial!;
      _name.text = e.name;
      _target.text = e.target;
      _equipment.text = e.equipment;
      _bodyPart.text = e.bodyPart;
      _gif.text = e.gif;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _equipment.dispose();
    _bodyPart.dispose();
    _gif.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final ex = model.Exercise(
      id: widget.initial?.id,
      name: _name.text.trim(),
      target: _target.text.trim(),
      equipment: _equipment.text.trim(),
      bodyPart: _bodyPart.text.trim(),
      gif: _gif.text.trim(),
      // createdAt is controlled by the service (serverTimestamp on create).
      createdAt: _isEdit ? widget.initial!.createdAt : null,
      duration: widget.initial?.duration,
    );

    try {
      if (_isEdit) {
        await _service.updateExercise(widget.initial!.id!, ex);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Exercise updated')));
      } else {
        await _service.createExercise(ex);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercise successfully added!')));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving exercise: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Edit Exercise' : 'Create Exercise';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // If we have historical names, show a dropdown to speed entry
              FutureBuilder<List<String>>(
                future: _service.fetchUniqueExerciseNames(),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: LinearProgressIndicator(),
                    );
                  }
                  final names = snap.data ?? const <String>[];
                  return names.isNotEmpty && !_isEdit
                      ? _dropdown('Exercise Name', names, _name)
                      : _text('Exercise Name', _name);
                },
              ),

              // Target (training goal)
              _dropdown('Target', _targetOptions, _target),

              // Body Part (category)
              _dropdown(
                'Body Part',
                _bodyPartOptions,
                _bodyPart,
                onChanged: (v) {
                  // Small UX touch: default a sensible target.
                  if (v == 'Cardio' && !_targetOptions.contains(_target.text)) {
                    _target.text = 'Endurance';
                    setState(() {}); // rebuild so the dropdown shows it
                  }
                },
              ),

              _dropdown('Equipment', _equipmentOptions, _equipment),

              _text('GIF URL (optional)', _gif, required: false),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(_isEdit ? 'Save Changes' : 'Add Exercise'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers ----------

  Widget _text(String label, TextEditingController c, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null
            : null,
      ),
    );
  }

  /// Dropdown that writes to a controller (so service/model code stays the same).
  /// `onChanged` lets us react (e.g., default Target when Cardio is chosen).
  Widget _dropdown(
    String label,
    List<String> opts,
    TextEditingController c, {
    ValueChanged<String?>? onChanged,
  }) {
    // If the current controller value isn't in the options, show null so
    // the user explicitly picks one (prevents hidden invalid values).
    final current = opts.contains(c.text) ? c.text : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: current,
        items: opts
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: (v) {
          c.text = v ?? '';
          onChanged?.call(v);
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Please select $label' : null,
      ),
    );
  }
}
