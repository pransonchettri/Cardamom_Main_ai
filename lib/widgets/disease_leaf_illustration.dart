import 'dart:math';

import 'package:flutter/material.dart';

/// The visual symptom pattern to paint over the base leaf shape.
enum SymptomPattern { blotches, spots, mosaic, rotBase, healthy }

/// An original, hand-drawn illustration of a cardamom leaf showing a
/// disease's characteristic visual symptom pattern.
///
/// This exists instead of sourcing real photographs specifically to
/// avoid any licensing risk in a bundled app asset, and to avoid
/// adding any new package/dependency to an already hard-won build —
/// everything here is plain Flutter `CustomPainter` drawing.
class DiseaseLeafIllustration extends StatelessWidget {
  final SymptomPattern pattern;
  final Color accent;
  final double size;

  const DiseaseLeafIllustration({
    super.key,
    required this.pattern,
    required this.accent,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LeafPainter(pattern: pattern, accent: accent),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final SymptomPattern pattern;
  final Color accent;

  _LeafPainter({required this.pattern, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final leafPath = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..quadraticBezierTo(w * 0.96, h * 0.28, w * 0.86, h * 0.62)
      ..quadraticBezierTo(w * 0.74, h * 0.98, w * 0.5, h * 0.98)
      ..quadraticBezierTo(w * 0.26, h * 0.98, w * 0.14, h * 0.62)
      ..quadraticBezierTo(w * 0.04, h * 0.28, w * 0.5, h * 0.06)
      ..close();

    final baseGreen = const Color(0xFF3FA66B);
    final leafFill = Paint()
      ..shader = LinearGradient(
        colors: [baseGreen.withOpacity(0.85), baseGreen.withOpacity(0.55)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(leafPath, leafFill);

    // Midrib + veins, drawn before clipping to symptoms so they read
    // as part of the leaf, not the disease.
    final veinPaint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..strokeWidth = w * 0.014
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, h * 0.94), veinPaint);
    for (final t in [0.32, 0.5, 0.68, 0.84]) {
      canvas.drawLine(
        Offset(w * 0.5, h * t),
        Offset(w * (0.5 - 0.28 * (1 - t)), h * (t - 0.1)),
        veinPaint..strokeWidth = w * 0.008,
      );
      canvas.drawLine(
        Offset(w * 0.5, h * t),
        Offset(w * (0.5 + 0.28 * (1 - t)), h * (t - 0.1)),
        veinPaint,
      );
    }

    canvas.save();
    canvas.clipPath(leafPath);
    _paintSymptom(canvas, w, h);
    canvas.restore();

    // Outline on top for crispness.
    final outline = Paint()
      ..color = accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;
    canvas.drawPath(leafPath, outline);
  }

  void _paintSymptom(Canvas canvas, double w, double h) {
    switch (pattern) {
      case SymptomPattern.healthy:
        return; // clean leaf, no overlay
      case SymptomPattern.blotches:
        _paintBlotches(canvas, w, h);
      case SymptomPattern.spots:
        _paintSpots(canvas, w, h);
      case SymptomPattern.mosaic:
        _paintMosaic(canvas, w, h);
      case SymptomPattern.rotBase:
        _paintRotBase(canvas, w, h);
    }
  }

  void _paintBlotches(Canvas canvas, double w, double h) {
    final rand = Random(7);
    final blotchFill = Paint()..color = accent.withOpacity(0.72);
    final haloFill = Paint()..color = accent.withOpacity(0.22);
    for (var i = 0; i < 6; i++) {
      final cx = w * (0.25 + rand.nextDouble() * 0.5);
      final cy = h * (0.2 + rand.nextDouble() * 0.65);
      final r = w * (0.05 + rand.nextDouble() * 0.06);
      canvas.drawCircle(Offset(cx, cy), r * 1.7, haloFill);
      canvas.drawCircle(Offset(cx, cy), r, blotchFill);
    }
  }

  void _paintSpots(Canvas canvas, double w, double h) {
    final rand = Random(3);
    final ringPaint = Paint()
      ..color = accent.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012;
    final centerFill = Paint()..color = accent.withOpacity(0.35);
    for (var i = 0; i < 9; i++) {
      final cx = w * (0.22 + rand.nextDouble() * 0.56);
      final cy = h * (0.16 + rand.nextDouble() * 0.72);
      final r = w * (0.025 + rand.nextDouble() * 0.02);
      canvas.drawCircle(Offset(cx, cy), r, centerFill);
      canvas.drawCircle(Offset(cx, cy), r, ringPaint);
    }
  }

  void _paintMosaic(Canvas canvas, double w, double h) {
    final rand = Random(11);
    final patchFill = Paint()..color = accent.withOpacity(0.55);
    const cols = 5;
    const rows = 6;
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (rand.nextDouble() > 0.42) continue;
        final x = w * (col / cols);
        final y = h * (row / rows);
        final cw = w / cols;
        final ch = h / rows;
        canvas.drawRect(Rect.fromLTWH(x, y, cw, ch), patchFill);
      }
    }
  }

  void _paintRotBase(Canvas canvas, double w, double h) {
    final rotFill = Paint()
      ..shader = LinearGradient(
        colors: [accent.withOpacity(0.85), accent.withOpacity(0.15)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.55, w, h * 0.45));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.6, w, h * 0.4), rotFill);

    final rand = Random(5);
    final speckle = Paint()..color = accent.withOpacity(0.6);
    for (var i = 0; i < 10; i++) {
      final cx = w * (0.15 + rand.nextDouble() * 0.7);
      final cy = h * (0.65 + rand.nextDouble() * 0.3);
      canvas.drawCircle(Offset(cx, cy), w * 0.02, speckle);
    }
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.accent != accent;
}
