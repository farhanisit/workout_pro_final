// ProfileScreen.dart - Displays user profile information and settings
// - Provides user's profile details like username, email  and goal
// - Allows editing of user goal
// - Includes theme toggle and logout functionality
// - Uses Firestore to fetch user data and update profile

import 'package:flutter/material.dart'; // UI Framework
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth for user session
import 'package:go_router/go_router.dart'; // Navigation system
import 'package:provider/provider.dart'; // For Theme switching

import 'package:workout_pro/services/user_service.dart'; // Firestore user service
import 'package:workout_pro/theme/theme_provider.dart'; // Theme toggler

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService(); // Instance to call Firestore
  Map<String, dynamic>?
      _userData; // Holds profile fields (username, gender, goal, etc.)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser(); // Fetch data when screen loads
  }

  // Method to fetch user profile data from Firestore
  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final data = await _userService.getUserProfile(user.uid);
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Error fetching user: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  // Logout and navigate to /auth
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Authenticated user
    final theme = Theme.of(context); // App theme
    final themeProvider = Provider.of<ThemeProvider>(context); // Theme toggle
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading spinner
          : _userData == null
              ? const Center(child: Text("No profile data found."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(_userData, isDark, theme),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Welcome, ${_userData!["username"] ?? "Athlete"}",
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Account Info section
                      Text("Account Info",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                          Icons.email, "Email", user?.email ?? "N/A", theme),
                      if ((_userData!["gender"] ?? '').toString().isNotEmpty)
                        _buildDetailRow(
                            Icons.wc, "Gender", _userData!["gender"], theme),

                      const SizedBox(height: 30),

                      // Goal Section with refreshed load after editing
                      Text("Your Goal",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _userData!["goal"] ?? "Not set",
                              style: theme.textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            key: const Key('editGoalButton'),
                            onPressed: () async {
                              // Use push so we can await for return
                              await context.push('/edit-goal');
                              _loadUser(); // Refetch after return
                            },
                            child: const Text("Edit"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Theme toggle
                      SwitchListTile(
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        title:
                            Text("Dark Mode", style: theme.textTheme.bodyLarge),
                        secondary: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: theme.iconTheme.color,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),

                      const SizedBox(height: 30),

                      Divider(thickness: 1.2, color: theme.dividerColor),
                      const SizedBox(height: 20),

                      // Logout button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text("Log Out"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Helper widget to render user initial as avatar
  Widget _buildAvatar(
      Map<String, dynamic>? userData, bool isDark, ThemeData theme) {
    final username = userData?["username"] ?? "U";
    final initial =
        username.toString().isNotEmpty ? username[0].toUpperCase() : "U";

    return Center(
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.grey[800] : theme.colorScheme.primaryContainer,
        ),
        child: CircleAvatar(
          radius: 36,
          backgroundColor: Colors.transparent,
          child: Text(
            initial,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : theme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for label-value detail row
  Widget _buildDetailRow(
      IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: theme.iconTheme.color),
          const SizedBox(width: 12),
          Text(
            "$label:",
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
