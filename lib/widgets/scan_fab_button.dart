import 'package:flutter/material.dart';
import 'package:plant_ai/theme/app_theme.dart';

/// The raised, glowing center "Scan" button docked into the bottom
/// nav's notch — the app's single most important action gets a
/// visual treatment that sets it apart from the flat nav items
/// around it, instead of just being one icon among four.
class ScanFabButton extends StatefulWidget {
  final VoidCallback onTap;

  const ScanFabButton({super.key, required this.onTap});

  @override
  State<ScanFabButton> createState() => _ScanFabButtonState();
}

class _ScanFabButtonState extends State<ScanFabButton> with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          final glowStrength = 0.18 + _glow.value * 0.16;
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.emeraldLight.withOpacity(glowStrength),
                  blurRadius: 18 + _glow.value * 6,
                  spreadRadius: 1 + _glow.value * 2,
                ),
                BoxShadow(
                  color: AppColors.forest.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          );
        },
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.emeraldLight, AppColors.forest],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 27),
          ),
        ),
      ),
    );
  }
}
