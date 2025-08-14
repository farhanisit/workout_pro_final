import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_pro/services/exercise_service.dart';
import 'package:workout_pro/model/exercise.dart' as model;

/// Progress can be:
/// 1) a tab root inside BottomNav, or
/// 2) a pushed page from Home.
/// Back behavior:
/// - If router can pop → pop()
/// - Else (tab root) → go('/tabs/0').
class ProgressScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  const ProgressScreen({super.key, required this.firestore});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final ExerciseService _svc;

  @override
  void initState() {
    super.initState();
    _svc = ExerciseService(firestore: widget.firestore);
  }

  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go('/tabs/0');
    }
  }

  // Theme helpers
  Color _subtle(BuildContext c) => Theme.of(c)
      .colorScheme
      .onSurface
      .withOpacity(Theme.of(c).brightness == Brightness.dark ? 0.75 : 0.65);

  Color _track(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? Colors.white10
      : Colors.black12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final emptyDonutTrack = cs.primary
        .withOpacity(theme.brightness == Brightness.dark ? 0.22 : 0.18);

    return PopScope(
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fitness Dashboard'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBack(context),
            tooltip: 'Back',
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ---- Weekly strip (LIVE; waits for pending writes) ----
              StreamBuilder<List<model.Exercise>>(
                stream: _svc.streamExercises(),
                builder: (context, _) {
                  return FutureBuilder<List<int>>(
                    future: () async {
                      // Make sure any local writes are committed server-side
                      await widget.firestore.waitForPendingWrites();
                      return _svc.getWeeklyWorkoutData();
                    }(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const _CardWrap(
                          child: SizedBox(
                            height: 72,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }
                      if (snap.hasError) {
                        return _ErrorBlock(
                          error: snap.error,
                          onRetry: () => setState(() {}),
                        );
                      }
                      final data = snap.data ?? List<int>.filled(7, 0);
                      return _CardWrap(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Last 7 days',
                                  style: theme.textTheme.titleMedium),
                              const SizedBox(height: 12),
                              _DotStrip(
                                  values: data, zeroColor: _track(context)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // ---- Donut (30d split) — LIVE; waits for pending writes ----
              StreamBuilder<List<model.Exercise>>(
                stream: _svc.streamExercises(),
                builder: (context, _) {
                  return FutureBuilder<Map<String, int>>(
                    future: () async {
                      await widget.firestore.waitForPendingWrites();
                      return _svc.getBodyPartBreakdown(days: 30);
                    }(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const _CardWrap(
                          child: SizedBox(
                            height: 260,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }
                      if (snap.hasError) {
                        return _ErrorBlock(
                          error: snap.error,
                          onRetry: () => setState(() {}),
                        );
                      }
                      final raw = snap.data ?? <String, int>{};
                      final total = raw.values.fold<int>(0, (a, b) => a + b);

                      return _CardWrap(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Body Part Split (30d)',
                                      style: theme.textTheme.titleMedium),
                                  const Spacer(),
                                  Text(
                                    '$total ${total == 1 ? "session" : "sessions"}',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(color: _subtle(context)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _DonutChart(
                                data: raw,
                                trackColorWhenEmpty: emptyDonutTrack,
                                trackColorDefault: _track(context),
                                centerTextColor: _subtle(context),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: raw.isEmpty
                                    ? [
                                        Chip(
                                          avatar: CircleAvatar(
                                            backgroundColor: _track(context),
                                            radius: 6,
                                          ),
                                          label: Text(
                                            'No data · 0',
                                            style: TextStyle(
                                                color: _subtle(context)),
                                          ),
                                        ),
                                      ]
                                    : raw.entries
                                        .map((e) => Chip(
                                              avatar: CircleAvatar(
                                                backgroundColor:
                                                    _colorFor(e.key),
                                                radius: 6,
                                              ),
                                              label:
                                                  Text('${e.key} · ${e.value}'),
                                            ))
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // ---- Actions ----
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Manage Workouts'),
                  onPressed: () => context.push('/exercise-list'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/create-exercise'),
                icon: const Icon(Icons.fitness_center),
                label: const Text('Log Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Small UI helpers ----------

class _CardWrap extends StatelessWidget {
  final Widget child;
  const _CardWrap({required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;
  const _ErrorBlock({this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return _CardWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: $error', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// 7 tiny bars (dot strip)
class _DotStrip extends StatelessWidget {
  final List<int> values; // length = 7
  final Color zeroColor;
  const _DotStrip({required this.values, required this.zeroColor});
  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    return Row(
      children: List.generate(7, (i) {
        final v = (i < values.length) ? values[i] : 0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: v > 0 ? active : zeroColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Donut with center total label (no packages)
class _DonutChart extends StatelessWidget {
  final Map<String, int> data;
  final Color centerTextColor;
  final Color trackColorWhenEmpty;
  final Color trackColorDefault;

  const _DonutChart({
    required this.data,
    required this.centerTextColor,
    required this.trackColorWhenEmpty,
    required this.trackColorDefault,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    final entries = data.entries.toList();

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(200),
            painter: _DonutPainter(
              entries: entries,
              total: total,
              emptyTrack: trackColorWhenEmpty,
              defaultTrack: trackColorDefault,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                total == 1 ? 'session' : 'sessions',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: centerTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final int total;
  final Color emptyTrack;
  final Color defaultTrack;

  _DonutPainter({
    required this.entries,
    required this.total,
    required this.emptyTrack,
    required this.defaultTrack,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.18;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = (total <= 0) ? emptyTrack : defaultTrack;

    // Background track
    canvas.drawArc(
        rect.deflate(stroke / 2), -math.pi / 2, 2 * math.pi, false, track);

    if (total <= 0) return;

    final seg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    double start = -math.pi / 2;
    for (final e in entries) {
      final value = e.value;
      if (value <= 0) continue;
      final sweep = (value / total) * 2 * math.pi;
      seg.color = _colorFor(e.key);
      canvas.drawArc(rect.deflate(stroke / 2), start, sweep, false, seg);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.entries != entries ||
      old.total != total ||
      old.emptyTrack != emptyTrack ||
      old.defaultTrack != defaultTrack;
}

// Deterministic color per key
Color _colorFor(String key) {
  final palette = <Color>[
    const Color(0xFF6366F1),
    const Color(0xFF22C55E),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF14B8A6),
    const Color(0xFF8B5CF6),
    const Color(0xFF3B82F6),
  ];
  final i = key.hashCode.abs() % palette.length;
  return palette[i];
}
