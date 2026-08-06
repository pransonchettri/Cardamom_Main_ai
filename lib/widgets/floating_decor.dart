import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Soft, slow-drifting decorative icons behind a gradient screen's
/// content. Purely visual and ignored for hit-testing. Shared across
/// Splash, Onboarding, Credits and the web Scan screen so every
/// full-bleed gradient moment in the app feels like part of the same
/// polished family instead of one-off treatments.
class FloatingDecor extends StatelessWidget {
  /// Optional override for the set of icons/positions. Defaults to a
  /// balanced 5-icon spread that works on most screen heights.
  final List<Widget>? children;

  const FloatingDecor({super.key, this.children});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: children ??
            [
              _drift(top: 90, left: 24, icon: Icons.eco_rounded, size: 26, duration: 4200, opacity: 0.10),
              _drift(top: 160, right: 30, icon: Icons.spa_rounded, size: 20, duration: 3600, opacity: 0.08),
              _drift(top: 340, left: 10, icon: Icons.auto_awesome_rounded, size: 16, duration: 5000, opacity: 0.12),
              _drift(bottom: 220, right: 18, icon: Icons.eco_rounded, size: 22, duration: 4600, opacity: 0.09),
              _drift(bottom: 120, left: 40, icon: Icons.grass_rounded, size: 24, duration: 3900, opacity: 0.10),
            ],
      ),
    );
  }

  static Widget _drift({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required IconData icon,
    required double size,
    required int duration,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(icon, color: Colors.white.withOpacity(opacity), size: size)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -18, duration: duration.ms, curve: Curves.easeInOut),
    );
  }
}
