import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A custom input field that uses consistent styling
// It features a label, outlined border and a friendly font.
class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.controller,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8), // Using the same corner rounding
        ),
        // Add content padding if needed
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.poppins(fontSize: 14),
    );
  }
}
