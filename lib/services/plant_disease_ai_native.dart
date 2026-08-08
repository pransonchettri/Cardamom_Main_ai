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
  /// Uses three-view test-time augmentation: the model runs on (1)
  /// the image as captured, (2) its horizontal mirror, and (3) a
  /// center crop zoomed in ~20% — since a hand-held photo often
  /// doesn't perfectly frame just the symptom, a tighter center crop
  /// can pick up detail the full frame dilutes. The three 39-class
  /// probability distributions are averaged before picking a result.
  /// This costs two extra (cheap, ~240KB model) forward passes for a
  /// meaningfully steadier read. The full averaged distribution is
  /// also returned via [AIInferenceResult.allScores] so callers can
  /// aggregate confidence by symptom category instead of trusting a
  /// single top-1 class.
  Future<AIInferenceResult?> classify(String imagePath) async {
    if (!_ready || _interpreter == null) return null;

    try {
      final bytes = await File(imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final resized = img.copyResize(decoded, width: 200, height: 200);
      final qualityWarning = _assessQuality(resized);
      // flipHorizontal mutates its argument in place, so clone first -
      // otherwise both "passes" below would silently run on the same
      // flipped image instead of one original + one mirrored.
      final flipped = img.flipHorizontal(img.Image.from(resized));
      final centerCropped = _centerCrop(decoded);

      final scoresA = _runSinglePass(resized);
      final scoresB = _runSinglePass(flipped);
      final scoresC = _runSinglePass(centerCropped);
      if (scoresA == null || scoresB == null || scoresC == null) return null;

      final averaged = List<double>.generate(
        _labels.length,
        (i) => (scoresA[i] + scoresB[i] + scoresC[i]) / 3.0,
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
        qualityWarning: qualityWarning,
      );
    } catch (_) {
      return null;
    }
  }

  /// Cheap pre-inference photo-quality heuristic: average pixel
  /// brightness across the resized frame. Not a substitute for real
  /// blur/exposure detection, but catches the two most common reasons
  /// a farmer's phone photo comes out unusable — deep shadow/backlight,
  /// or flash/direct-sun glare — cheaply enough to run on every scan.
  String? _assessQuality(img.Image resized) {
    var total = 0.0;
    var sampleCount = 0;
    // Every 3rd pixel is plenty to estimate overall brightness and
    // keeps this effectively free next to the model inference itself.
    for (var y = 0; y < resized.height; y += 3) {
      for (var x = 0; x < resized.width; x += 3) {
        final pixel = resized.getPixel(x, y);
        total += (pixel.r + pixel.g + pixel.b) / 3.0;
        sampleCount++;
      }
    }
    if (sampleCount == 0) return null;
    final avgBrightness = total / sampleCount; // 0-255

    if (avgBrightness < 40) return 'dark';
    if (avgBrightness > 235) return 'bright';
    return null;
  }

  /// Crops the central ~70% of the original (pre-resize) image, then
  /// resizes that crop to the model's 200x200 input — a "zoomed in"
  /// view that can surface symptom detail a full, loosely-framed
  /// photo dilutes.
  img.Image _centerCrop(img.Image original) {
    final cropFraction = 0.7;
    final cropW = (original.width * cropFraction).round();
    final cropH = (original.height * cropFraction).round();
    final x = ((original.width - cropW) / 2).round();
    final y = ((original.height - cropH) / 2).round();

    final cropped = img.copyCrop(original, x: x, y: y, width: cropW, height: cropH);
    return img.copyResize(cropped, width: 200, height: 200);
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
