import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // UI components
import 'package:fl_chart/fl_chart.dart'; // For line chart
import 'package:go_router/go_router.dart'; // Navigation system

// DashboardScreen: Displays user greeting, stats, and workout program buttons
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalExercises = 0;
  List<double> _weeklyData =
      List.filled(7, 0.0); // Placeholder for weekly chart data

  @override
  void initState() {
    super.initState();
    _loadWorkoutCount(); // Load total exercises on init
  }

  // Fetches number of exercises from Firestore
  Future<void> _loadWorkoutCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('exercises').get();
    setState(() {
      _totalExercises = snapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Dashboard"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-exercise'),
        icon: const Icon(Icons.add),
        label: const Text("Add Workout"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome User
            Text(
              "Welcome back, ${user?.email?.split('@')[0] ?? 'Athlete'}!",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Weekly Goal Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              color: theme.cardColor,
              child: ListTile(
                leading: Icon(
                  Icons.flag,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : theme.primaryColor,
                ),
                title: Text("Weekly Goal", style: textTheme.bodyLarge),
                subtitle: Text("Workout at least 3 days",
                    style: textTheme.bodyMedium),
                trailing: Chip(
                  label: const Text("2 / 3"),
                  backgroundColor: theme.chipTheme.backgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Weekly Activity Chart
            Text("Activity Tracker", style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Container(
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
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
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weeklyData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: theme.brightness == Brightness.dark
                          ? Colors.cyanAccent
                          : theme.primaryColor,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.brightness == Brightness.dark
                                ? Colors.cyanAccent.withValues(alpha: 0.3)
                                : theme.primaryColor.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Program Buttons Section
            Text("Explore Programs", style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                // Cardio Workouts
                _buildGradientButton(
                  context,
                  "🔥 Break a Sweat",
                  '/cardio-list',
                  [Colors.indigo, Colors.indigoAccent],
                ),
                const SizedBox(width: 12),
                //  Full Body Creator
                // _buildGradientButton(
                // context,
                //"💪 Full Body Burn",
                //'/create-exercise',
                // [Colors.deepOrange, Colors.orangeAccent],
                //),
              ],
            ),

            const SizedBox(height: 24),

            // Workout Summary Section
            Text("Workout Summary", style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.fitness_center,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    title: Text("Total Workouts Logged",
                        style: textTheme.bodyLarge),
                    subtitle: Text("You've added $_totalExercises workouts.",
                        style: textTheme.bodyMedium),
                  ),
                  Divider(color: theme.dividerColor),
                  ListTile(
                    leading: Icon(
                      Icons.star,
                      color: theme.brightness == Brightness.dark
                          ? Colors.amberAccent
                          : Colors.amber,
                    ),
                    title:
                        Text("Consistency Streak", style: textTheme.bodyLarge),
                    subtitle: Text("7-day streak! Keep it up.",
                        style: textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable gradient button generator
  Widget _buildGradientButton(
      BuildContext context, String label, String route, List<Color> colors) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*
🧾 DashboardScreen Summary:
- Personalized user greeting and dynamic color theming
- Weekly goal display and total exercise count
- Real-time placeholder activity chart (7-day)
- Two gradient buttons linked to actual workout flows:
    🔵 Break a Sweat → /cardio-list
    🟠 Full Body Burn → /create-exercise
- Aligned with HomeScreen logic for consistent UX
*/
