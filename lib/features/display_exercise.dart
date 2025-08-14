import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For consistent font style
import 'dart:async';
import 'package:workout_pro/model/exercise.dart';
import 'package:workout_pro/services/progress_service.dart'; // Logs workout sessions

// Class DisplayExercise: Displays a workout with detailed info and timer to track progress
class DisplayExercise extends StatefulWidget {
  final Exercise exercise;

  const DisplayExercise({super.key, required this.exercise});
  // Creates a mutable state for the screen
  @override
  State<DisplayExercise> createState() => _DisplayExerciseState();
}

// State Class: Handles timer logic and workout logging for DisplayExercise
class _DisplayExerciseState extends State<DisplayExercise> {
  late Timer _timer;
  int _seconds = 0;
  bool _isRunning = false;

  final ProgressService _progressService =
      ProgressService(); // For logging progress
  // Method: starts a 1-second repeating timer
  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  // Method: Stops the timer and logs the workout duration to Firestore
  void _stopTimer() async {
    _timer.cancel();
    setState(() => _isRunning = false);

    // Log progress on stop
    if (_seconds > 0) {
      await _progressService.logWorkout(
        exerciseId: widget.exercise.id ?? 'unknown',
        durationInSeconds: _seconds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Workout logged successfully!")),
        );
      }
    }
  }

  // Method : Stops the timer if still running when widget is disposed
  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    super.dispose();
  }

  // Build Method that constructs the complete UI showing exercise details and a timer
  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(ex.name,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // GIF or fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ex.gif,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            const SizedBox(height: 24),

            // Info rows
            _buildDetailRow(Icons.fitness_center, "Target", ex.target),
            _buildDetailRow(Icons.accessibility, "Target Area", ex.bodyPart),
            _buildDetailRow(Icons.build, "Equipment", ex.equipment),

            const SizedBox(height: 24),

            // Timer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(_seconds),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isRunning ? _stopTimer : _startTimer,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? "Stop Timer" : "Start Timer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Method: _buildDetailRow - reusable widget for showing icon-lavel-value rows
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text("$label:",
              style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.openSans(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Method: _formatTime() - Formats seconds into MM:SS string for display
  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
/*
display_exercise.dart:
This screen displays workout details (name, target, body part, equipment)
alongside a built-in timer to track exercise duration.
Once stopped, the session is logged using ProgressService.
Useful for visual feedback + performance tracking.
*/
