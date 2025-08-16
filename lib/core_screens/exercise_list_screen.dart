// ExerciseListScreen.dart - Displays a list of user exercises with search and filter options
// - Uses Firestore to fetch exercises
// - Allows searching by name and filtering by body part
// - Displays exercises in a scrollable list with cards
// - Each exercise can be tapped to view details or deleted

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:workout_pro/model/exercise.dart' as model;
import 'package:workout_pro/services/exercise_service.dart' as svc;

class ExerciseListScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;

  const ExerciseListScreen({
    super.key,
    required this.firestore,
    required this.userId,
  });

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late final svc.ExerciseService _service;

  final _search = TextEditingController();
  String _selectedBodyPart = 'All';
  final List<String> _bodyParts = const [
    'All',
    'Upper Body',
    'Lower Body',
    'Arms',
    'Shoulders',
    'Back',
    'Full Body'
  ];

  @override
  void initState() {
    super.initState();
    _service = svc.ExerciseService(
      firestore: widget.firestore,
      userId: widget.userId,
    );
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(model.Exercise e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text("Are you sure you want to delete '${e.name}'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && e.id != null) {
      await _service.deleteExercise(e.id!);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Deleted '${e.name}'")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.grey[600]! : Colors.grey[300]!;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    final q = _search.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Exercises'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
            ),
          ),

          // Body part filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: _selectedBodyPart,
              dropdownColor: cardColor,
              style: TextStyle(color: textColor),
              items: _bodyParts
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedBodyPart = v ?? 'All'),
              decoration: InputDecoration(
                labelText: 'Filter by Body Part',
                labelStyle: TextStyle(color: textColor),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Live list
          Expanded(
            child: StreamBuilder<List<model.Exercise>>(
              stream: _service.streamExercises(
                search: q,
                bodyPart:
                    _selectedBodyPart == 'All' ? 'ALL' : _selectedBodyPart,
              ),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                final items = snap.data ?? const <model.Exercise>[];
                if (items.isEmpty) {
                  return Center(
                      child: Text('No exercises found.',
                          style: TextStyle(color: textColor)));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final e = items[i];
                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: (e.gif.isNotEmpty)
                            ? Image.network(e.gif,
                                width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.fitness_center,
                                color: theme.primaryColor),
                        title: Text(e.name, style: TextStyle(color: textColor)),
                        subtitle: Text('Equipment: ${e.equipment}',
                            style:
                                TextStyle(color: textColor.withOpacity(0.7))),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(e),
                        ),
                        onTap: () =>
                            context.push('/exercises/detail', extra: e),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
            '/create-exercise'), // push (not go) so we return to this list
        child: const Icon(Icons.add),
      ),
    );
  }
}
