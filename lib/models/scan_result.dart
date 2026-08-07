import 'package:plant_ai/models/disease.dart';

/// Result of a single scan / analysis run.
///
/// [isSimulated] tells the UI whether this came from the real
/// on-device model ([PlantDiseaseAI], general PlantVillage-trained,
/// not cardamom-specific) or from the simulated fallback used on
/// Flutter Web / when the model isn't available on this device.
/// Either way, this is not a cardamom-specific diagnosis — the
/// Result screen always discloses that.
class ScanResult {
  final String id;
  final String imagePath;
  final String diseaseName;
  final String? diseaseId;
  final double confidence; // 0.0 - 1.0
  final DiseaseSeverity severity;
  final List<String> symptoms;
  final List<String> recommendations;
  final DateTime timestamp;
  final bool isHealthy;
  final bool isInconclusive;
  final bool isSimulated;
  final String? rawModelLabel;

  /// When the model was genuinely torn between two symptom
  /// categories (see [CategoryResult.isCloseCall]), this names the
  /// runner-up disease so the Result screen can be honest about the
  /// uncertainty instead of presenting one pick with false certainty.
  final String? secondaryDiseaseName;

  ScanResult({
    required this.id,
    required this.imagePath,
    required this.diseaseName,
    required this.diseaseId,
    required this.confidence,
    required this.severity,
    required this.symptoms,
    required this.recommendations,
    required this.timestamp,
    required this.isHealthy,
    this.isInconclusive = false,
    this.isSimulated = false,
    this.rawModelLabel,
    this.secondaryDiseaseName,
  });

  String get confidencePercent => '${(confidence * 100).round()}%';
}
