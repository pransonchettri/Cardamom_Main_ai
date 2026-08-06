/// Result of a single real on-device inference pass.
///
/// [allScores] + [labels] (when present) carry the full 39-class
/// probability distribution, not just the top-1 guess, so callers
/// can aggregate confidence across a symptom category (e.g. summing
/// every "blight" class) rather than relying on a single class that
/// may have split its probability mass with close relatives. See
/// [PlantDiseaseLabelMapper.bestCategoryFromScores].
class AIInferenceResult {
  final String rawLabel;
  final double confidence;
  final List<double>? allScores;
  final List<String>? labels;

  const AIInferenceResult({
    required this.rawLabel,
    required this.confidence,
    this.allScores,
    this.labels,
  });
}
