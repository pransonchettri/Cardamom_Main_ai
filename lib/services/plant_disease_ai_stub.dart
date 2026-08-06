import 'plant_disease_ai_result.dart';

/// Flutter Web stub for [PlantDiseaseAI].
///
/// `tflite_flutter` depends on `dart:ffi`, which does not exist on
/// web, so real on-device inference isn't possible there at all —
/// not "not implemented yet", but structurally unsupported by the
/// web platform. This stub keeps the exact same public API as the
/// native implementation (see `plant_disease_ai_native.dart`) so
/// callers never need platform checks of their own: [isReady] is
/// simply always false here, which `AnalysisScreen` already treats
/// as "fall back to the simulated result".
///
/// Compiled in automatically via the conditional export in
/// `plant_disease_ai.dart` — nothing should import this file directly.
class PlantDiseaseAI {
  bool get isReady => false;
  List<String> get labels => const [];

  Future<void> init() async {
    // No-op on web — there is nothing to load.
  }

  Future<AIInferenceResult?> classify(String imagePath) async => null;

  void dispose() {
    // No-op on web — nothing was ever allocated.
  }
}
