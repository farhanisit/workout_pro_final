// ProfileSetupScreen.dart - Displays user profile with options to edit goal, toggle theme, and logout

import 'package:flutter/material.dart'; // Flutter material component for UI rendering
import 'package:firebase_auth/firebase_auth.dart'; // Firebase auth to get current user
import 'package:go_router/go_router.dart'; // Navigation management
import 'package:provider/provider.dart'; // State management for theme toggling
import 'package:workout_pro/services/user_service.dart'; // User Firestore logic
import 'package:workout_pro/theme/theme_provider.dart'; // Theme state (light/dark)

// ProfileSetupScreen displays current user details, goal, theme toggle, and logout
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

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
        debugPrint('Failed to load user: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Your Profile"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null || _userData!.isEmpty
              ? const Center(child: Text("No profile data found."))
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: theme.colorScheme
                              .primaryContainer, // Updated to avoid withOpacity
                          child: Text(
                            (_userData!['username'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 28,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Welcome, ${_userData!['username'] ?? 'Athlete'}",
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Account Info",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                          Icons.email, "Email", user?.email ?? 'N/A', theme),
                      if ((_userData!['gender'] ?? '').isNotEmpty)
                        _buildDetailRow(Icons.wc, "Gender",
                            _userData!['gender'] ?? '', theme),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Your Goal",
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => context.go('/edit-goal'),
                            child: const Text("Edit"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text((_userData!['goal'] ?? 'Not set'),
                          style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 30),
                      SwitchListTile(
                        value: themeProvider.isDarkMode,
                        onChanged: (_) =>
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme(),
                        title: const Text("Dark Mode"),
                        secondary: Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: theme.colorScheme.primary,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 30),
                      Divider(thickness: 1.2, color: theme.dividerColor),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text("Log Out"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
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

  Widget _buildDetailRow(
      IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: theme.iconTheme.color),
          const SizedBox(width: 12),
          Text("$label:",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
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
