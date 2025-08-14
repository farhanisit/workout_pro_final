import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Routing system for navigation

// Class GoalSetupScreen : Screen for selecting user's fitness goal
class GoalSetupScreen extends StatefulWidget {
  // Goal setup screen shown during onboarding
  const GoalSetupScreen({Key? key}) : super(key: key);
  // Creates a mutable state for the screen
  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

// Holds logic for goal selection and UI behaviour
class _GoalSetupScreenState extends State<GoalSetupScreen> {
  String?
      selectedGoal; // Holds the currently selected goal type (e.g., "fat", "muscle")
  //Called when the user presses "Continue"
  void _continue() {
    if (selectedGoal != null) {
      context.go('/dashboard'); // Navigate to dashboard if goal is selected
    } else {
      // Show error if no goal selected
      ScaffoldMessenger.of(context).showSnackBar(
        // Show error if no goal selected
        const SnackBar(content: Text("Please select a goal")),
      );
    }
  }

// Builds a goal selection card (e.g., "Lose Fat", "Build Muscle")
  Widget _goalCard(String label, IconData icon, String goalKey) {
    final isSelected = selectedGoal == goalKey;
    final theme = Theme.of(context);
    final color = theme.primaryColor;

    return GestureDetector(
      onTap: () =>
          setState(() => selectedGoal = goalKey), // Update selected goal on tap
      child: Card(
        color: isSelected ? color.withOpacity(0.85) : Colors.white,
        elevation: isSelected ? 6 : 2, // Subtle shadow when selected
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build Method that renders the full layout of goal setup screen
  @override
  Widget build(BuildContext context) {
    final padding =
        MediaQuery.of(context).size.width * 0.05; // Responsive padding

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("What's Your Goal?"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              "Select your primary fitness goal:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Goal options
            _goalCard("Lose Fat", Icons.local_fire_department, "fat"),
            const SizedBox(height: 16),
            _goalCard("Build Muscle", Icons.fitness_center, "muscle"),
            const SizedBox(height: 16),
            _goalCard("Stay Fit", Icons.directions_run, "fit"),
            const SizedBox(height: 16),
            _goalCard("Improve Flexibility", Icons.self_improvement, "flex"),
            const Spacer(),
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
/*
GoalSetupScreen:
This onboarding screen lets the user select a primary fitness goal (e.g., lose fat, build muscle).
Each goal is presented as a card, and the selection is stored locally.
After selection, the user can proceed to the dashboard using the Continue button.
*/
