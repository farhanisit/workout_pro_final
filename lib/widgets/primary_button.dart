import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A basic custom button
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // Custom style based on Figma spec (adjust colors/padding as needed)
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent, // Figma primary color
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
