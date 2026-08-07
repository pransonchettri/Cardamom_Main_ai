/// Maps a raw label from the bundled general plant-disease model
/// (trained on the public PlantVillage dataset — apple, tomato,
/// potato, corn, grape, etc.) to something useful for CardamomAI.
///
/// IMPORTANT: PlantVillage does not include cardamom. These mappings
/// are a best-effort bridge from the *symptom pattern* the model
/// recognised (blight / rot / spot / virus) to the closest matching
/// entry in our cardamom disease library — not a claim that the
/// model has ever seen or been trained on cardamom. The UI must
/// always disclose this; see [ResultScreen]'s AI source badge.
class PlantDiseaseLabelMapper {
  PlantDiseaseLabelMapper._();

  static bool isHealthy(String rawLabel) => rawLabel.trim().toLowerCase().contains('healthy');

  static bool isBackground(String rawLabel) => rawLabel.trim().toLowerCase() == 'background';

  /// A human-readable version of the raw training label, e.g.
  /// "tomato early blight" -> "Tomato Early Blight".
  static String friendlyName(String rawLabel) {
    final cleaned = rawLabel.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return 'Unknown';
    return cleaned
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Coarse symptom category inferred from keywords in the raw label.
  /// Order matters — more specific checks come first.
  static String categoryFor(String rawLabel) {
    final label = rawLabel.toLowerCase();
    if (label.contains('healthy')) return 'healthy';
    if (label.contains('background')) return 'background';
    if (label.contains('virus') || label.contains('mosaic') || label.contains('curl')) return 'virus';
    if (label.contains('blight')) return 'blight';
    if (label.contains('rot')) return 'rot';
    if (label.contains('rust')) return 'blight';
    if (label.contains('mildew')) return 'spot';
    if (label.contains('spot')) return 'spot';
    if (label.contains('bacterial')) return 'blight';
    if (label.contains('mite')) return 'spot';
    return 'spot';
  }

  /// The closest matching entry in [DiseasesData], if any, based on
  /// the coarse symptom category. Returns null for healthy/background
  /// results, which are handled as distinct outcomes rather than
  /// mapped to a disease entry.
  static String? cardamomDiseaseIdFor(String rawLabel) => cardamomDiseaseIdForCategory(categoryFor(rawLabel));

  /// Same mapping as [cardamomDiseaseIdFor], but starting from an
  /// already-known category (e.g. from [bestCategoryFromScores])
  /// rather than a single raw label.
  static String? cardamomDiseaseIdForCategory(String category) {
    switch (category) {
      case 'virus':
        return 'katte_virus';
      case 'blight':
        return 'leaf_blight';
      case 'rot':
        return 'capsule_rot';
      case 'spot':
        return 'leaf_spot';
      default:
        return null;
    }
  }

  /// Aggregates the full 39-class probability distribution into
  /// symptom-category buckets (healthy / background / blight / rot /
  /// spot / virus) by summing the probability of every class that
  /// falls into each category, then returns the category with the
  /// highest total probability mass — and the runner-up, so callers
  /// can tell a confident read apart from a genuinely close call
  /// instead of presenting every result with the same false certainty.
  ///
  /// This is meaningfully more robust than trusting a single top-1
  /// class: e.g. if "tomato early blight", "potato early blight" and
  /// "corn northern leaf blight" each individually score only 15–20%
  /// because they're splitting probability with each other, a naive
  /// top-1 pick could lose to something unrelated at 25%. Summed
  /// together, that 45–60% of blight-pattern probability mass
  /// correctly dominates. Combined with the multi-view test-time
  /// averaging in [PlantDiseaseAI], this is the "smarter, not
  /// fabricated" accuracy improvement — it uses strictly more of the
  /// real model's own output, not invented signal.
  static CategoryResult bestCategoryFromScores(List<double> scores, List<String> labels) {
    final totals = <String, double>{};
    for (var i = 0; i < scores.length && i < labels.length; i++) {
      final category = categoryFor(labels[i]);
      totals[category] = (totals[category] ?? 0) + scores[i];
    }

    var bestCategory = 'spot';
    var bestTotal = -1.0;
    String? runnerUpCategory;
    var runnerUpTotal = -1.0;

    totals.forEach((category, total) {
      if (total > bestTotal) {
        runnerUpCategory = bestCategory;
        runnerUpTotal = bestTotal;
        bestCategory = category;
        bestTotal = total;
      } else if (total > runnerUpTotal) {
        runnerUpCategory = category;
        runnerUpTotal = total;
      }
    });

    return CategoryResult(
      category: bestCategory,
      confidence: bestTotal.clamp(0.0, 1.0),
      runnerUpCategory: runnerUpTotal < 0 ? null : runnerUpCategory,
      runnerUpConfidence: runnerUpTotal < 0 ? null : runnerUpTotal.clamp(0.0, 1.0),
    );
  }
}

/// Result of aggregating model scores into symptom-category buckets.
///
/// [runnerUpCategory] / [runnerUpConfidence] describe the second-best
/// category, when there is one — useful for telling a confident read
/// apart from a genuinely close call between two symptom patterns.
class CategoryResult {
  final String category;
  final double confidence;
  final String? runnerUpCategory;
  final double? runnerUpConfidence;

  const CategoryResult({
    required this.category,
    required this.confidence,
    this.runnerUpCategory,
    this.runnerUpConfidence,
  });

  /// True when the runner-up is close enough to the winner that
  /// presenting only the top pick would overstate how sure the model
  /// really is (within 12 percentage points of aggregated probability
  /// mass).
  bool get isCloseCall {
    final gap = runnerUpConfidence;
    if (gap == null) return false;
    return (confidence - gap) < 0.12;
  }
}
