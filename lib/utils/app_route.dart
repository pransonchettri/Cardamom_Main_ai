import 'package:flutter/material.dart';

/// A refined page transition — fade combined with a subtle slide-up
/// and scale — used across the app's primary journey (Home → Scan →
/// Preview → Analysis → Result → Library/Care Guide) so navigating
/// feels considered rather than using the platform's default abrupt
/// slide-in-from-the-right.
///
/// Usage: `Navigator.push(context, AppRoute.to(const ScanScreen()));`
class AppRoute<T> extends PageRouteBuilder<T> {
  AppRoute.to(Widget page)
      : super(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
                  child: child,
                ),
              ),
            );
          },
        );
}
