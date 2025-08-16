// custom_button.dart - Custom button widget for Workout Pro
// - Reusable button for login/signup actions
// - Uses ElevatedButton with custom styles
// - Supports both production and test environments

import 'package:flutter/material.dart';

// A reusable custom-styled button widget
// Used for Login / Signup actions
class CustomButton extends StatelessWidget {
  // Text to display inside the button (e.g. "Login" or "Sign Up")
  final String text;

  // Function to execute when button is tapped
  final VoidCallback onPressed;

  // Constructor with required named parameters
  const CustomButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Trigger the passed-in function
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        backgroundColor: Colors.deepPurpleAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
