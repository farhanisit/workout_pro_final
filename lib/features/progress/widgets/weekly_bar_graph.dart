//  WeeklyBarGraph — Displays weekly workout data as a bar graph
// - Fetches workout timestamps from Firestore
// - Groups data by weekday and displays in a bar chart
// - Uses fl_chart for rendering the bar chart
// - Shows the number of workouts per day of the week

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyBarGraph extends StatelessWidget {
  final FirebaseFirestore firestore;

  const WeeklyBarGraph({super.key, required this.firestore});

  Future<List<DateTime>> _fetchTimestamps() async {
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

  Map<int, int> _groupByWeekday(List<DateTime> timestamps) {
    final Map<int, int> weekdayCounts = {for (int i = 1; i <= 7; i++) i: 0};
    for (var ts in timestamps) {
      weekdayCounts[ts.weekday] = weekdayCounts[ts.weekday]! + 1;
    }
    return weekdayCounts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<DateTime>>(
      future: _fetchTimestamps(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: LinearProgressIndicator(),
          );
        }

        final grouped = _groupByWeekday(snapshot.data ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("This Week’s Activity",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.8,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final day = value.toInt() - 1;
                          return Text(
                            labels[day >= 0 && day < 7 ? day : 0],
                            style: theme.textTheme.bodySmall,
                          );
                        },
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    final weekday = index + 1;
                    final count = grouped[weekday] ?? 0;
                    return BarChartGroupData(
                      x: weekday,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                          color: theme.primaryColor,
                        ),
                      ],
                    );
                  }),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
