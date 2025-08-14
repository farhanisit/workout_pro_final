import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:workout_pro/services/exercise_service.dart';
import 'package:workout_pro/model/exercise.dart' as model;
import 'package:workout_pro/testing/keys.dart'; // ← added

/// Home/Dashboard under BottomNav host.
/// - PUSH for standalone flows (create/list) so Back returns here.
/// - GO to switch tabs (/tabs/1 for Progress) to avoid stacked hosts.
/// - Activity tracker is a line chart (restored) and **live** via stream.
/// - _NoStealTap prevents the “need two taps” issue when dismissing keyboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ExerciseService _svc;

  @override
  void initState() {
    super.initState();
    _svc = ExerciseService(); // requires current user
  }

  Future<void> _openCreate() async => context.push('/create-exercise');
  Future<void> _openManage() async => context.push('/exercise-list');

  Color _subtle(BuildContext c) =>
      Theme.of(c).colorScheme.onSurface.withOpacity(
            Theme.of(c).brightness == Brightness.dark ? 0.75 : 0.65,
          );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTint = theme.colorScheme.primary.withOpacity(
      theme.brightness == Brightness.dark ? 0.28 : 0.22,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: _NoStealTap(
        child: RefreshIndicator(
          onRefresh: () async {}, // live via stream anyway
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // room for FAB
            children: [
              // ---- Activity Tracker (line chart) ----
              Text('Activity Tracker',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                color: Theme.of(context).cardColor,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: StreamBuilder<List<model.Exercise>>(
                    stream: _svc.streamExercises(),
                    builder: (context, _) {
                      return FutureBuilder<List<int>>(
                        future: _svc.getWeeklyWorkoutData(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 160,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final values = (snap.data ?? List<int>.filled(7, 0))
                              .map((e) => e.toDouble())
                              .toList();
                          return SizedBox(
                            height: 160,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white12
                                        : Colors.black12,
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: values
                                        .asMap()
                                        .entries
                                        .map((e) =>
                                            FlSpot(e.key.toDouble(), e.value))
                                        .toList(),
                                    isCurved: true,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    barWidth: 3,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryTint,
                                          Colors.transparent
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ---- Explore Programs ----
              Text('Explore Programs',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              InkWell(
                key: TKeys.programsHub, // ← added
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/cardio-list'), // PUSH
                child: Ink(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '🔥 Break a Sweat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ---- Workout Summary ----
              Text('Workout Summary',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),

              // Total Workouts (tap → manage)
              _tappableCard(
                key: TKeys.totalWorkoutsTile, // ← added
                onTap: _openManage, // PUSH
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Workouts Logged',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          _LiveCountWithFallback(
                            svc: _svc,
                            color: _subtle(context),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Streak (tap → Progress TAB) — live via stream trigger
              StreamBuilder<List<model.Exercise>>(
                stream: _svc.streamExercises(),
                builder: (context, _) {
                  return FutureBuilder<int>(
                    future: _svc.getStreakDays(),
                    builder: (context, snap) {
                      final streak = snap.data ?? 0;
                      return _tappableCard(
                        onTap: () => GoRouter.of(context).go('/tabs/1'),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rate_rounded, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Consistency Streak',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$streak-day streak! Keep it going.',
                                    style: TextStyle(color: _subtle(context)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: TKeys.addWorkoutFab, // ← added
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Add Workout'),
      ),
    );
  }

  // Card shells (dark friendly via theme tokens)
  Widget _tappableCard({
    Key? key, // ← added
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Card(
      key: key, // ← added
      elevation: 2,
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class _LiveCountWithFallback extends StatelessWidget {
  final ExerciseService svc;
  final Color? color;
  const _LiveCountWithFallback({required this.svc, this.color});

  @override
  Widget build(BuildContext context) {
    final subtle = color ??
        Theme.of(context).colorScheme.onSurface.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.75 : 0.65,
            );
    return StreamBuilder<List<model.Exercise>>(
      stream: svc.streamExercises(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Text('Loading…', style: TextStyle(color: subtle));
        }
        final live = snap.data?.length ?? 0;
        if (live > 0) {
          return Text(
            "You've added $live workout${live == 1 ? '' : 's'}.",
            style: TextStyle(color: subtle),
          );
        }
        return FutureBuilder<int>(
          future: svc.getTotalCount(),
          builder: (context, f) {
            final count = f.data ?? 0;
            return Text(
              "You've added $count workout${count == 1 ? '' : 's'}.",
              style: TextStyle(color: subtle),
            );
          },
        );
      },
    );
  }
}

/// Dismiss keyboard without stealing the tap target
class _NoStealTap extends StatelessWidget {
  final Widget child;
  const _NoStealTap({required this.child});
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
