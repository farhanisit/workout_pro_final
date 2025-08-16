// activity_line_golden_test.dart - Golden tests for MiniActivityLine widget
// - Tests rendering in light and dark themes

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:fl_chart/fl_chart.dart';
import '../_goldens_config.dart';

class MiniActivityLine extends StatelessWidget {
  final List<double> data;
  const MiniActivityLine({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    final spots = [
      for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i])
    ];
    return SizedBox(
      width: 240,
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              barWidth: 3,
              spots: spots,
              color: Theme.of(context).colorScheme.primary,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.25),
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
  }
}

void main() {
  setUpAll(loadFonts);

  testGoldens('Activity line renders (light/dark)', (tester) async {
    final data = <double>[0, 2, 3, 1, 4, 3, 5];

    await tester.pumpWidgetBuilder(
      MaterialApp(
        theme: ThemeData.light(),
        home: const Scaffold(
            body: Center(child: MiniActivityLine(data: [0, 2, 3, 1, 4, 3, 5]))),
      ),
      surfaceSize: const Size(260, 180),
    );
    await screenMatchesGolden(tester, 'activity_line_light');

    await tester.pumpWidgetBuilder(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
            body: Center(child: MiniActivityLine(data: [0, 2, 3, 1, 4, 3, 5]))),
      ),
      surfaceSize: const Size(260, 180),
    );
    await screenMatchesGolden(tester, 'activity_line_dark');
  });
}
