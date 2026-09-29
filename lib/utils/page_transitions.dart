import 'package:flutter/material.dart';

/// Premium Custom Page Route with unmistakable, cinematic full Slide & Fade transition.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;

  SmoothPageRoute({
    required this.page,
    this.direction = AxisDirection.right,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 450),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // Full-screen sweep offset based on direction
            Offset beginOffset;
            switch (direction) {
              case AxisDirection.right:
                beginOffset = const Offset(1.0, 0.0); // Full slide from right
                break;
              case AxisDirection.left:
                beginOffset = const Offset(-1.0, 0.0); // Full slide from left
                break;
              case AxisDirection.up:
                beginOffset = const Offset(0.0, 1.0); // Full slide from bottom
                break;
              case AxisDirection.down:
                beginOffset = const Offset(0.0, -1.0);
                break;
            }

            final slideAnimation = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(curvedAnimation);

            final fadeAnimation = Tween<double>(
              begin: 0.1,
              end: 1.0,
            ).animate(curvedAnimation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Upward full sheet-style smooth reveal transition
class SmoothSlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothSlideUpRoute({
    required this.page,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(curvedAnimation);

            final fadeAnimation = Tween<double>(
              begin: 0.2,
              end: 1.0,
            ).animate(curvedAnimation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}
