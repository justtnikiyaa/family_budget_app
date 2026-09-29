import 'package:flutter/material.dart';

/// Premium Custom Page Route with silky smooth Slide, Scale, and Fade transitions.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;

  SmoothPageRoute({
    required this.page,
    this.direction = AxisDirection.right,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 480),
          reverseTransitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Forward curved animation
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // Secondary animation for the page underneath (exit animation)
            final secondaryCurve = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
            );

            // Calculate slide offset based on direction
            Offset beginOffset;
            switch (direction) {
              case AxisDirection.right:
                beginOffset = const Offset(0.20, 0.0);
                break;
              case AxisDirection.left:
                beginOffset = const Offset(-0.20, 0.0);
                break;
              case AxisDirection.up:
                beginOffset = const Offset(0.0, 0.20);
                break;
              case AxisDirection.down:
                beginOffset = const Offset(0.0, -0.20);
                break;
            }

            final slideAnimation = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(curve);

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curve);

            final scaleAnimation = Tween<double>(
              begin: 0.94,
              end: 1.0,
            ).animate(curve);

            // Subtle parallax push-back on exit
            final exitSlide = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.08, 0.0),
            ).animate(secondaryCurve);

            final exitFade = Tween<double>(
              begin: 1.0,
              end: 0.85,
            ).animate(secondaryCurve);

            return SlideTransition(
              position: exitSlide,
              child: FadeTransition(
                opacity: exitFade,
                child: SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
        );
}

/// Upward sheet-style smooth reveal transition
class SmoothSlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothSlideUpRoute({
    required this.page,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 380),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.18),
              end: Offset.zero,
            ).animate(curve);

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curve);

            final scaleAnimation = Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(curve);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
        );
}
