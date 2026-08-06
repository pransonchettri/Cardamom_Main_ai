import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'plant_disease_ai_result.dart';

/// Loads and runs the bundled general plant-disease TFLite model.
///
/// This performs genuine on-device inference — not a simulation —
/// using a small (≈240KB) MobileNet-style classifier trained on the
/// public PlantVillage dataset (39 classes: common crop diseases +
/// healthy + background). It is NOT trained on cardamom specifically;
/// see [PlantDiseaseLabelMapper] for how its output is interpreted.
///
/// NATIVE ONLY (Android/iOS/desktop) — this file uses `dart:ffi` via
/// `tflite_flutter`, which does not exist on Flutter Web. It is only
/// ever compiled in via the conditional export in `plant_disease_ai.dart`;
/// nothing should import this file directly.
class PlantDiseaseAI {
  static const _modelPath = 'assets/model/plant_disease_model.tflite';
  static const _labelsPath = 'assets/model/labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = const [];
  bool _ready = false;

  bool get isReady => _ready;
  List<String> get labels => _labels;

  Future<void> init() async {
    if (_ready) return;
    try {
      final options = InterpreterOptions();
      if (Platform.isAndroid) {
        options.addDelegate(XNNPackDelegate());
      }

      _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

      final labelsRaw = await rootBundle.loadString(_labelsPath);
      _labels = labelsRaw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      _ready = _interpreter != null && _labels.isNotEmpty;
    } catch (_) {
      _ready = false;
    }
  }

  /// Runs inference on the image at [imagePath] and returns the
  /// top predicted class + its softmax confidence, or null if the
  /// model isn't ready or the image couldn't be decoded.
  ///
  /// Uses horizontal-flip test-time augmentation: the model runs
  /// TWICE — once on the image as captured, once on its mirror
  /// image — and the two 39-class probability distributions are
  /// averaged before picking a result. This is a standard technique
  /// for making small CNN classifiers like this one meaningfully
  /// more robust to how the leaf happened to be oriented in the
  /// photo, at the cost of one extra (cheap) forward pass. The full
  /// averaged distribution is also returned via [AIInferenceResult.allScores]
  /// so callers can aggregate confidence by symptom category instead
  /// of trusting a single top-1 class.
  Future<AIInferenceResult?> classify(String imagePath) async {
    if (!_ready || _interpreter == null) return null;

    try {
      final bytes = await File(imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final resized = img.copyResize(decoded, width: 200, height: 200);
      // flipHorizontal mutates its argument in place, so clone first -
      // otherwise both "passes" below would silently run on the same
      // flipped image instead of one original + one mirrored.
      final flipped = img.flipHorizontal(img.Image.from(resized));

      final scoresA = _runSinglePass(resized);
      final scoresB = _runSinglePass(flipped);
      if (scoresA == null || scoresB == null) return null;

      final averaged = List<double>.generate(
        _labels.length,
        (i) => (scoresA[i] + scoresB[i]) / 2.0,
      );

      var bestIndex = 0;
      var bestScore = averaged[0];
      for (var i = 1; i < averaged.length; i++) {
        if (averaged[i] > bestScore) {
          bestScore = averaged[i];
          bestIndex = i;
        }
      }

      return AIInferenceResult(
        rawLabel: _labels[bestIndex],
        confidence: bestScore,
        allScores: averaged,
        labels: _labels,
      );
    } catch (_) {
      return null;
    }
  }

  /// Runs a single forward pass on an already-resized 200x200 image
  /// and returns the raw 39-class softmax scores.
  List<double>? _runSinglePass(img.Image resized) {
    final interpreter = _interpreter;
    if (interpreter == null) return null;

    final input = [
      List.generate(
        resized.height,
        (y) => List.generate(resized.width, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    ];

    final output = [List<double>.filled(_labels.length, 0.0)];
    interpreter.run(input, output);
    return output[0];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _ready = false;
  }
}
