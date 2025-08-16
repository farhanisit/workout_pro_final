//************
//DashboardScreen - Displays user dashboard with activity tracker and workout summary.
// - Shows weekly workout data in a line chart.
// - Provides quick access to create and manage exercises.
// - Uses ExerciseService for Firestore operations.
//************

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:workout_pro/services/exercise_service.dart';
import 'package:workout_pro/model/exercise.dart' as model;
import 'package:workout_pro/testing/keys.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ExerciseService _svc;
  late Future<List<int>> _weekly; // 7 buckets, oldest → newest

  @override
  void initState() {
    super.initState();
    _svc = ExerciseService();
    _weekly = _svc.getWeeklyWorkoutData();
  }

  Future<void> _openCreateAndRefresh() async {
    await context.push('/create-exercise'); // standalone → PUSH
    if (mounted) setState(() => _weekly = _svc.getWeeklyWorkoutData());
  }

  Future<void> _openManageAndRefresh() async {
    await context.push('/exercise-list'); // standalone → PUSH
    if (mounted) setState(() => _weekly = _svc.getWeeklyWorkoutData());
  }

  Color _subtle(BuildContext c) =>
      Theme.of(c).colorScheme.onSurface.withOpacity(
            Theme.of(c).brightness == Brightness.dark ? 0.75 : 0.65,
          );

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    // precompute tiny tint for the area under the chart
    final primaryTint = theme.colorScheme.primary.withOpacity(
      theme.brightness == Brightness.dark ? 0.28 : 0.22,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: _NoStealTap(
        child: RefreshIndicator(
          onRefresh: () async =>
              setState(() => _weekly = _svc.getWeeklyWorkoutData()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
            children: [
              // Welcome
              Text(
                "Welcome back, ${user?.email?.split('@').first ?? 'Athlete'}!",
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Activity Tracker (7-day)
              Text("Activity Tracker", style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                color: theme.cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FutureBuilder<List<int>>(
                    future: _weekly,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final values = (snap.data ?? List<int>.filled(7, 0))
                          .map((e) => e.toDouble())
                          .toList();
                      return SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: theme.brightness == Brightness.dark
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
                                color: theme.colorScheme.primary,
                                barWidth: 3,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [primaryTint, Colors.transparent],
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
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Explore Programs
              Text("Explore Programs", style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/cardio-list'), 
                child: Ink(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Break a Sweat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Workout Summary
              Text("Workout Summary", style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),

              _SummaryCard(
                onTap: _openManageAndRefresh, 
                leading: const Icon(Icons.fitness_center),
                title: const Text("Total Workouts Logged"),
                subtitle: _LiveCountWithFallback(
                  svc: _svc,
                  color: _subtle(context),
                ),
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                
                onTap: () => GoRouter.of(context).go('/tabs/1'),
                leading: const Icon(Icons.star),
                title: const Text("Consistency Streak"),
                subtitle: FutureBuilder<int>(
                  future: _svc.getStreakDays(),
                  builder: (context, snap) {
                    final streak = snap.data ?? 0;
                    return Text(
                      "$streak-day streak! Keep it up.",
                      style: TextStyle(color: _subtle(context)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateAndRefresh,
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final VoidCallback onTap;
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  const _SummaryCard({
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle.merge(
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      child: title,
                    ),
                    const SizedBox(height: 4),
                    DefaultTextStyle.merge(child: subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
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
