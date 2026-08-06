/// Public entry point for [PlantDiseaseAI] and [AIInferenceResult].
///
/// This file has no real code of its own — it just picks which
/// implementation gets compiled in, based on platform, at COMPILE
/// TIME (not runtime). This matters because `tflite_flutter` uses
/// `dart:ffi`, which the web compiler refuses to touch even if the
/// code path is never actually reached at runtime — a `kIsWeb`
/// runtime check alone cannot fix that, since the whole import graph
/// still has to compile. Conditional export is the correct fix:
/// on native platforms (`dart.library.io` available) it exports the
/// real `tflite_flutter`-backed implementation; everywhere else
/// (Flutter Web) it exports a harmless no-op stub with the same API.
///
/// Always import THIS file (`plant_disease_ai.dart`), never
/// `plant_disease_ai_native.dart` or `plant_disease_ai_stub.dart`
/// directly.
export 'plant_disease_ai_result.dart';
export 'plant_disease_ai_stub.dart'
    if (dart.library.io) 'plant_disease_ai_native.dart';
