import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:workout_pro/services/exercise_service.dart';
import 'package:workout_pro/features/progress/widgets/streak_chip.dart';
import 'package:workout_pro/features/progress/widgets/weekly_bar_graph.dart';
import 'package:workout_pro/features/progress/widgets/summary_card.dart';

class ProgressScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;

  const ProgressScreen({
    super.key,
    required this.firestore,
    required this.userId,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final ExerciseService _exerciseService;
  late Future<List<int>> _weeklyDataFuture;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _exerciseService = ExerciseService(
      firestore: widget.firestore,
      userId: widget.userId,
    );
    _weeklyDataFuture = _exerciseService.getWeeklyWorkoutData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _retryFetch() {
    if (!mounted || _isDisposed) return;
    setState(() {
      _weeklyDataFuture = _exerciseService.getWeeklyWorkoutData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).maybePop(result);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Progress')),
        body: FutureBuilder<List<int>>(
          future: _weeklyDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Data Acquisition Failure\nError: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: _retryFetch,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final weeklyData = snapshot.data ?? const <int>[];
            final noData =
                weeklyData.isEmpty || weeklyData.every((c) => c == 0);

            if (noData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/no_data.png',
                        height: 120,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, size: 100),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No workout data recorded\nInitiate training to generate metrics',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.go('/create-exercise'),
                        child: const Text('Create First Workout'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreakChip(firestore: widget.firestore),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: WeeklyBarGraph(firestore: widget.firestore),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SummaryCard(firestore: widget.firestore),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.push('/manage-workouts'),
                      icon: const Icon(Icons.manage_history_outlined),
                      label: const Text('Manage workouts'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('dataCollectionTrigger'),
          onPressed: () => context.push('/create-exercise'),
          icon: const Icon(Icons.fitness_center),
          label: const Text('Log Activity'),
        ),
      ),
    );
  }
}
