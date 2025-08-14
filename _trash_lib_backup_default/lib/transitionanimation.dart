import 'package:flutter/material.dart';

// Transit class: Custom page transition using Slide animation.
// Extends PageRouteBuilder to animate route changes with a slide effect.
class Transit extends PageRouteBuilder {
  final Widget widget;

  // Constructor for Transit: Takes a widget and sets up animation
  Transit({required this.widget})
      : super(
          transitionDuration:
              const Duration(milliseconds: 700), // Duration of the animation
          // Builds the page to show
          pageBuilder: (context, animation, secondaryAnimation) => widget,
          // Defines the transition animation
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .animate(
                        CurvedAnimation(parent: animation, curve: Curves.ease)),
            child: child,
          ),
        );
}/*
transit.dart:
Custom page transition class using Flutter’s PageRouteBuilder.
Applies a right-to-left slide animation on screen change.
Used to replace Navigator.push with smoother motion.
*/

