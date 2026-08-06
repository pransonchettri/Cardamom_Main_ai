import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/data/diseases_data.dart';
import 'package:plant_ai/models/disease.dart';
import 'package:plant_ai/models/scan_result.dart';
import 'package:plant_ai/screens/result_screen.dart';
import 'package:plant_ai/services/history_service.dart';
import 'package:plant_ai/services/plant_disease_ai.dart';
import 'package:plant_ai/services/plant_disease_label_mapper.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/utils/app_route.dart';

class _AnalysisStep {
  final String title;
  final String description;
  final IconData icon;

  const _AnalysisStep({required this.title, required this.description, required this.icon});
}

const _steps = [
  _AnalysisStep(
    title: 'Image processing',
    description: 'Cleaning up and preparing the photo',
    icon: Icons.image_search_rounded,
  ),
  _AnalysisStep(
    title: 'Symptom detection',
    description: 'Looking for visible patterns on the leaf',
    icon: Icons.biotech_rounded,
  ),
  _AnalysisStep(
    title: 'Analysis',
    description: 'Running the on-device plant-health model',
    icon: Icons.psychology_rounded,
  ),
];

/// Confidence threshold above which a "background" (no clear leaf)
/// prediction is treated as an inconclusive/rejected scan rather than
/// forced into a disease/healthy bucket.
const _kBackgroundConfidenceThreshold = 0.35;

/// If the model's single best guess — across all 39 trained classes —
/// scores below this, nothing it recognises matched well. Used as a
/// best-effort proxy to reject photos that aren't a leaf at all (a
/// face, a random object, etc). The model has no dedicated "is this a
/// human" detector — this is a confidence heuristic, not true
/// out-of-distribution detection, and is disclosed as such in the UI.
const _kLowConfidenceRejectThreshold = 0.30;

class AnalysisScreen extends StatefulWidget {
  final String imagePath;

  const AnalysisScreen({super.key, required this.imagePath});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  final PlantDiseaseAI _ai = PlantDiseaseAI();
  int _stepIndex = 0;
  double _stepProgress = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _run();
  }

  double get _overallProgress => (_stepIndex + _stepProgress) / _steps.length;

  Future<void> _run() async {
    // Kick off real inference (if available on this platform) in the
    // background while the step animation plays, so the UI always
    // feels responsive regardless of how fast the model itself runs.
    final inferenceFuture = _runInference();

    for (var s = 0; s < _steps.length; s++) {
      if (!mounted) return;
      setState(() {
        _stepIndex = s;
        _stepProgress = 0;
      });
      for (var i = 1; i <= 20; i++) {
        await Future.delayed(const Duration(milliseconds: 45));
        if (!mounted) return;
        setState(() => _stepProgress = i / 20);
      }
    }

    final aiResult = await inferenceFuture;

    if (!mounted) return;
    setState(() => _finished = true);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _completeAnalysis(aiResult);
  }

  /// Runs the real on-device model on native platforms. Returns null
  /// on web (no `tflite_flutter` support there) or if inference fails
  /// for any reason, so the caller can fall back to the simulated
  /// result — the UI is always told which happened.
  Future<AIInferenceResult?> _runInference() async {
    if (kIsWeb) return null;
    try {
      await _ai.init();
      if (!_ai.isReady) return null;
      return await _ai.classify(widget.imagePath);
    } catch (_) {
      return null;
    }
  }

  void _completeAnalysis(AIInferenceResult? aiResult) {
    final result = aiResult != null
        ? _buildRealResult(widget.imagePath, aiResult)
        : _simulateResult(widget.imagePath);

    final settings = context.read<SettingsController>();
    if (settings.saveScans) {
      context.read<HistoryService>().add(result);
    }

    Navigator.pushReplacement(
      context,
      AppRoute.to(ResultScreen(result: result)),
    );
  }

  /// Builds a [ScanResult] from a genuine model prediction.
  ///
  /// The bundled model is trained on the public PlantVillage dataset,
  /// not on cardamom, so a detected disease class is mapped to the
  /// closest matching entry in our cardamom library by symptom
  /// pattern (blight / rot / spot / virus) — see
  /// [PlantDiseaseLabelMapper]. The raw model label is kept on the
  /// result so the Result screen can disclose exactly what the model
  /// actually saw.
  ///
  /// When the full 39-class distribution is available (it is, after
  /// the flip-TTA averaging in [PlantDiseaseAI.classify]), this uses
  /// [PlantDiseaseLabelMapper.bestCategoryFromScores] to decide the
  /// outcome from the SUM of probability across every class in a
  /// symptom category, rather than a single top-1 class — the "more
  /// accurate" half of this round's AI work. Falls back to the
  /// simpler top-1-only path if that richer data isn't present for
  /// any reason.
  ScanResult _buildRealResult(String imagePath, AIInferenceResult aiResult) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    final hasFullDistribution = aiResult.allScores != null && aiResult.labels != null;

    final category = hasFullDistribution
        ? PlantDiseaseLabelMapper.bestCategoryFromScores(aiResult.allScores!, aiResult.labels!)
        : CategoryResult(category: PlantDiseaseLabelMapper.categoryFor(aiResult.rawLabel), confidence: aiResult.confidence);

    final isBackgroundGuess = category.category == 'background' && category.confidence >= _kBackgroundConfidenceThreshold;
    final isLowConfidence = category.confidence < _kLowConfidenceRejectThreshold;

    if (isBackgroundGuess || isLowConfidence) {
      return ScanResult(
        id: id,
        imagePath: imagePath,
        diseaseName: 'Not recognized as cardamom',
        diseaseId: null,
        confidence: category.confidence,
        severity: DiseaseSeverity.none,
        symptoms: const [
          'CardamomAI could not confidently match this photo to a plant leaf pattern',
          'This can happen if the photo isn\'t a cardamom leaf, or the leaf isn\'t clearly visible',
        ],
        recommendations: const [
          'Make sure you\'re photographing a cardamom leaf or capsule',
          'Fill more of the frame with the leaf, avoiding other objects',
          'Use even, natural daylight and hold the camera steady',
          'Avoid busy or cluttered backgrounds',
        ],
        timestamp: now,
        isHealthy: false,
        isInconclusive: true,
        isSimulated: false,
        rawModelLabel: aiResult.rawLabel,
      );
    }

    if (category.category == 'healthy') {
      return ScanResult(
        id: id,
        imagePath: imagePath,
        diseaseName: 'Healthy',
        diseaseId: null,
        confidence: category.confidence,
        severity: DiseaseSeverity.none,
        symptoms: const ['No visible lesions or discoloration detected', 'Leaf pattern looks typical of a healthy plant'],
        recommendations: const [
          'Continue your current care routine',
          'Recheck periodically, especially after heavy rain',
        ],
        timestamp: now,
        isHealthy: true,
        isSimulated: false,
        rawModelLabel: aiResult.rawLabel,
      );
    }

    final diseaseId = PlantDiseaseLabelMapper.cardamomDiseaseIdForCategory(category.category);
    final disease = diseaseId != null ? DiseasesData.byId(diseaseId) : null;

    if (disease == null) {
      // Extremely unlikely given the mapper always returns a category
      // for non-healthy/background labels, but fall back safely.
      return _simulateResult(imagePath);
    }

    return ScanResult(
      id: id,
      imagePath: imagePath,
      diseaseName: disease.name,
      diseaseId: disease.id,
      confidence: category.confidence,
      severity: disease.typicalSeverity,
      symptoms: disease.symptoms.take(4).toList(),
      recommendations: disease.recommendations.take(4).toList(),
      timestamp: now,
      isHealthy: false,
      isSimulated: false,
      rawModelLabel: aiResult.rawLabel,
    );
  }

  /// Simulated fallback — used on Flutter Web, or if the on-device
  /// model fails to load or run for any reason. Clearly flagged via
  /// [ScanResult.isSimulated] so the UI never presents it as real.
  ScanResult _simulateResult(String imagePath) {
    final rand = Random();
    final isHealthy = rand.nextDouble() < 0.28;

    if (isHealthy) {
      return ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        diseaseName: 'Healthy',
        diseaseId: null,
        confidence: 0.9 + rand.nextDouble() * 0.09,
        severity: DiseaseSeverity.none,
        symptoms: const ['No visible lesions or discoloration', 'Leaf colour and structure look typical'],
        recommendations: const [
          'Continue your current care routine',
          'Recheck periodically, especially after heavy rain',
        ],
        timestamp: DateTime.now(),
        isHealthy: true,
        isSimulated: true,
      );
    }

    final disease = DiseasesData.all[rand.nextInt(DiseasesData.all.length)];
    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      diseaseName: disease.name,
      diseaseId: disease.id,
      confidence: 0.68 + rand.nextDouble() * 0.28,
      severity: disease.typicalSeverity,
      symptoms: disease.symptoms.take(4).toList(),
      recommendations: disease.recommendations.take(4).toList(),
      timestamp: DateTime.now(),
      isHealthy: false,
      isSimulated: true,
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _ai.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis', style: TextStyle(fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Transform.scale(
                      scale: 1 + _pulse.value * 0.05,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: context.mutedColor,
                          borderRadius: BorderRadius.circular(38),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 84,
                              height: 84,
                              child: CircularProgressIndicator(
                                value: _overallProgress,
                                strokeWidth: 5,
                                backgroundColor: context.borderColor,
                                valueColor: const AlwaysStoppedAnimation(AppColors.emeraldLight),
                              ),
                            ),
                            Icon(
                              _finished ? Icons.check_circle_rounded : step.icon,
                              color: AppColors.emeraldLight,
                              size: 42,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                _finished ? 'Analysis complete' : step.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: context.primaryText),
              ),
              const SizedBox(height: 8),
              Text(
                _finished
                    ? 'Preparing your results…'
                    : step.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.secondaryText, height: 1.5),
              ),
              const SizedBox(height: 22),
              Column(
                children: List.generate(_steps.length, (i) {
                  final isDone = i < _stepIndex || _finished;
                  final isActive = i == _stepIndex && !_finished;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive ? AppColors.emeraldLight.withOpacity(0.5) : context.borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDone
                              ? Icons.check_circle_rounded
                              : (isActive ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded),
                          color: isDone || isActive ? AppColors.emeraldLight : context.secondaryText,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _steps[i].title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDone || isActive ? context.primaryText : context.secondaryText,
                            ),
                          ),
                        ),
                        if (isActive)
                          Text(
                            '${(_stepProgress * 100).round()}%',
                            style: const TextStyle(color: AppColors.emeraldLight, fontWeight: FontWeight.w900, fontSize: 12),
                          )
                        else if (isDone)
                          const Text('Done', style: TextStyle(color: AppColors.emeraldLight, fontWeight: FontWeight.w800, fontSize: 12)),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
