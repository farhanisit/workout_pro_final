// streak_detail_screen.dart - Displays detailed streak information
// - Shows current streak and next badge progress
// - Uses Firestore to fetch streak data

import 'package:flutter/material.dart';
import 'package:workout_pro/services/exercise_service.dart';

class StreakDetailScreen extends StatefulWidget {
  const StreakDetailScreen({super.key});

  @override
  State<StreakDetailScreen> createState() => _StreakDetailScreenState();
}

class _StreakDetailScreenState extends State<StreakDetailScreen> {
  late final ExerciseService _svc;
  late Future<int> _streak;

  @override
  void initState() {
    super.initState();
    _svc = ExerciseService();
    _streak = _svc.getStreakDays();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Consistency Streak')),
      body: FutureBuilder<int>(
        future: _streak,
        builder: (_, snap) {
          final s = snap.data ?? 0;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('$s-day streak',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (s % 7) / 7.0,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 8),
                        Text('Next badge in ${7 - (s % 7)} day(s)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _Badge(label: 'Rookie (7d)'),
                    _Badge(label: 'Consistent (21d)'),
                    _Badge(label: 'Beast (60d)'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.emoji_events),
    );
  }
}
