import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:workout_pro/services/exercise_service.dart';
import 'package:workout_pro/model/exercise.dart';

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
  late final ExerciseService _service;
  final TextEditingController _search = TextEditingController();
  String _selectedBodyPart = 'ALL';

  static const _bodyParts = <String>[
    'ALL', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Full Body', 'Cardio', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _service = ExerciseService(
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

  Future<void> _confirmDelete(BuildContext context, String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete exercise?'),
        content: Text('This will remove “$name” permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _service.delete(id); // uses typed service
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted “$name”')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            // Search
            TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search exercises...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),

            // Body part filter
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Filter by Body Part',
                border: UnderlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBodyPart,
                  isExpanded: true,
                  items: _bodyParts.map((bp) => DropdownMenuItem(value: bp, child: Text(bp))).toList(),
                  onChanged: (val) => setState(() => _selectedBodyPart = val ?? 'ALL'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Live list (typed)
            Expanded(
              child: StreamBuilder<List<Exercise>>(
                stream: _service.streamExercises(
                  search: q,
                  bodyPart: _selectedBodyPart,
                ),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }

                  final items = snap.data ?? const <Exercise>[];
                  if (items.isEmpty) {
                    return const Center(child: Text('No exercises yet. Tap + to add one.'));
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final e = items[i];
                      final id = e.id ?? '';
                      final name = e.name;
                      final equip = e.equipment;

                      return ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text(name),
                        subtitle: Text(
                          equip.isEmpty ? 'Equipment: —' : 'Equipment: $equip',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, id, name),
                        ),
                        onTap: () {
                          // TODO: context.push('/exercise/$id');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // NOTE: This route must exist. See router patch below.
        onPressed: () => context.push('/create-exercise'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
