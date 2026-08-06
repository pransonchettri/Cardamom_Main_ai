import 'package:flutter/material.dart';

enum DiseaseSeverity { none, low, medium, high }

extension DiseaseSeverityX on DiseaseSeverity {
  String get label {
    switch (this) {
      case DiseaseSeverity.none:
        return 'Healthy';
      case DiseaseSeverity.low:
        return 'Low';
      case DiseaseSeverity.medium:
        return 'Medium';
      case DiseaseSeverity.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case DiseaseSeverity.none:
        return const Color(0xFF2F855A);
      case DiseaseSeverity.low:
        return const Color(0xFF3FA66B);
      case DiseaseSeverity.medium:
        return const Color(0xFFD98E2E);
      case DiseaseSeverity.high:
        return const Color(0xFFCF4D3F);
    }
  }
}

/// Static reference entry describing a cardamom disease for the
/// in-app Library. This is reference/educational data, independent
/// from any single scan result.
class Disease {
  final String id;
  final String name;
  final String shortDescription;
  final String emoji;
  final IconData icon;
  final Color accent;
  final DiseaseSeverity typicalSeverity;
  final String overview;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> recommendations;

  const Disease({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.emoji,
    required this.icon,
    required this.accent,
    required this.typicalSeverity,
    required this.overview,
    required this.symptoms,
    required this.causes,
    required this.recommendations,
  });
}
