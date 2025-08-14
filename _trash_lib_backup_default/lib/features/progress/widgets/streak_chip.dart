import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakChip extends StatelessWidget {
  final FirebaseFirestore firestore;

  const StreakChip({super.key, required this.firestore});

  Future<List<DateTime>> _fetchWorkoutTimestamps() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await firestore
        .collection('exercises')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => (doc['createdAt'] as Timestamp?)?.toDate())
        .whereType<DateTime>()
        .toList();
  }

  int calculateStreak(List<DateTime> timestamps) {
    if (timestamps.isEmpty) return 0;

    final Set<String> daysSet = timestamps
        .map((ts) => DateTime(ts.year, ts.month, ts.day).toIso8601String())
        .toSet();

    int streak = 0;
    DateTime dayCursor = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final formatted = DateTime(dayCursor.year, dayCursor.month, dayCursor.day)
          .toIso8601String();
      if (daysSet.contains(formatted)) {
        streak++;
        dayCursor = dayCursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<DateTime>>(
      future: _fetchWorkoutTimestamps(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: LinearProgressIndicator(),
          );
        }

        final streakCount = calculateStreak(snapshot.data ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Workout Streak",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isFilled = index < streakCount;
                return Expanded(
                  child: Container(
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              streakCount == 0
                  ? "No streak yet. Let’s begin today 💥"
                  : "🔥 $streakCount-day streak going strong!",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }
}
