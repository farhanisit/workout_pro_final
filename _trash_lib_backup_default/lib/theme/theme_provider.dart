import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For saving theme preference locally

class ThemeProvider with ChangeNotifier {
  static const _key =
      'isDarkMode'; // Used to store theme prefernce in device storage

  ThemeMode _themeMode = ThemeMode.light;
  // public getter for accessing the current theme from the app
  ThemeMode get currentTheme => _themeMode;
  // To check it it's currently dark mode
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Constructor calls theme load on startup
  ThemeProvider() {
    _loadTheme(); // Load user's saved preference at app launch
  }

  // Function to Toggle theme
  void toggleTheme() async {
    final isDark = !isDarkMode;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    // Save the preference locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }

  // Load shared theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
  /*
   I used ThemeProvider to persist the user's UI pereference using SharedPreferences
   It leverage ChangeNotifier from the provider package to reflect theme changes instantly
   Tied directly to main.dart root widget for consistent theme usage across the app
   */