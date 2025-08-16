// app_header.dart - Custom AppBar for Workout Pro
// - Follows the design of the fitness UI kit
// - Uses Google Fonts for typography

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A custom AppBar that follows the design of your fitness UI kit.
// Use this across your screens to keep a uniform look.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppHeader({Key? key, required this.title}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.blueAccent, // Brand color from the kit
      centerTitle: true,
    );
  }
}
