// edit_goal_screen.dart - Allows users to view and update their fitness goal
// - Fetches current goal from Firestore
// - Provides form validation and async-safe updates
// - Uses Provider for theme management
// - Includes progress overlay during save operation

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workout_pro/services/user_service.dart';
import 'package:workout_pro/theme/theme_provider.dart';

class EditGoalScreen extends StatefulWidget {
  const EditGoalScreen({super.key});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final TextEditingController _goalController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _saveCompleted = false;

  @override
  void initState() {
    super.initState();
    _prepareUserAndFetchGoal(); // Load current goal on screen open
  }

  // Fetches current goal from Firestore after ensuring document exists
  Future<void> _prepareUserAndFetchGoal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Ensure user's Firestore doc exists before attempting fetch
      await _userService.ensureUserDocExists(user.uid, defaultFields: {
        'email': user.email ?? '',
        'goal': '',
      });

      final profile = await _userService.getUserProfile(user.uid);

      if (mounted) {
        setState(() {
          _goalController.text = profile['goal'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Goal fetch failure: $e');
      _showSnack("Failed to load your goal. Please retry.");
    }
  }

  // Validates and saves goal to Firestore with navigation safety
  Future<void> _saveGoal() async {
    _saveCompleted = false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack("Authentication error");
      return;
    }

    final newGoal = _goalController.text.trim();
    if (newGoal.isEmpty) {
      _showSnack("Goal cannot be empty");
      return;
    }

    setState(() {
      _isLoading = true;
      _isSaving = true;
    });

    try {
      // Prevent update failure due to missing doc
      await _userService.ensureUserDocExists(user.uid);
      await _userService.updateUserField(user.uid, 'goal', newGoal);

      _saveCompleted = true;
      _showSnack("Goal updated");

      // Return result to caller (e.g. ProfileScreen)
      if (mounted) context.pop(true);
    } catch (e) {
      debugPrint("Save failed: $e");
      _showSnack("Update failed. Check your connection.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSaving = false;
        });
      }
    }
  }

  // Navigation Guard to block back press during save
  Future<bool> _onWillPop() async {
    if (_isSaving) {
      _showSnack("Please wait until save completes");
      return false;
    }

    if (_saveCompleted) return true;

    // Confirm exit if user typed something
    if (_goalController.text.trim().isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Discard Changes?"),
          content: const Text("You have unsaved changes. Are you sure?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Discard"),
            ),
          ],
        ),
      );
      return confirm ?? false;
    }

    return true;
  }

  // Shows snackbars for feedback
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Your Goal"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                if (mounted) context.pop();
              }
            },
          ),
        ),
        body: AbsorbPointer(
          absorbing: _isSaving, // Disable all input while saving
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: _goalController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Enter your new goal",
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveGoal,
                        icon: const Icon(Icons.check_circle),
                        label: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Save Goal"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SwitchListTile(
                      value: themeProvider.isDarkMode,
                      onChanged:
                          _isSaving ? null : (_) => themeProvider.toggleTheme(),
                      title: const Text("Dark Mode"),
                      secondary: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: theme.iconTheme.color,
                      ),
                    ),
                  ],
                ),
                // Full-screen overlay during save
                if (_isSaving)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 20),
                          Text(
                            "Saving to Cloud...",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }
}
