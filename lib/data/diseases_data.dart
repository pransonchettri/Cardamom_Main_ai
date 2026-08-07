import 'package:flutter/material.dart';
import 'package:plant_ai/models/disease.dart';
import 'package:plant_ai/widgets/disease_leaf_illustration.dart';

/// Reference library of cardamom diseases shown in the Library screen
/// and used to generate simulated analysis results. This is
/// educational placeholder data — the real detection model will
/// replace the simulated matching logic later.
class DiseasesData {
  DiseasesData._();

  static const List<Disease> all = [
    Disease(
      id: 'leaf_blight',
      symptomPattern: SymptomPattern.blotches,
      name: 'Leaf Blight',
      shortDescription: 'Fungal leaf damage',
      emoji: '🍃',
      icon: Icons.grass_rounded,
      accent: Color(0xFF2F855A),
      typicalSeverity: DiseaseSeverity.medium,
      overview:
          'A common fungal infection that produces irregular water-soaked '
          'lesions on cardamom leaves, gradually turning brown and '
          'reducing the plant\'s ability to photosynthesise.',
      symptoms: [
        'Irregular brown or grey lesions on leaf blades',
        'Yellow halo surrounding older spots',
        'Leaf tips drying and curling inward',
        'Premature leaf fall in severe cases',
      ],
      causes: [
        'Prolonged leaf wetness and high humidity',
        'Poor air circulation between plants',
        'Overcrowded planting reducing sunlight exposure',
      ],
      recommendations: [
        'Remove and destroy severely affected leaves',
        'Improve spacing and airflow around plants',
        'Avoid overhead irrigation late in the day',
        'Consult an agronomist about approved fungicides',
      ],
    ),
    Disease(
      id: 'capsule_rot',
      symptomPattern: SymptomPattern.rotBase,
      name: 'Capsule Rot (Azhukal)',
      shortDescription: 'Capsule infection',
      emoji: '🟤',
      icon: Icons.spa_rounded,
      accent: Color(0xFF8A5A3B),
      typicalSeverity: DiseaseSeverity.high,
      overview:
          'One of the most destructive cardamom diseases, affecting '
          'capsules, panicles and leaves during periods of heavy, '
          'continuous rainfall.',
      symptoms: [
        'Water-soaked lesions on immature capsules',
        'Capsules turning dark brown and shrivelling',
        'Rotting panicles with a soft, mushy texture',
        'Rapid spread during wet, humid weeks',
      ],
      causes: [
        'Phytophthora infection favoured by continuous rain',
        'Waterlogged soil around the plant base',
        'Dense shade with poor ventilation',
      ],
      recommendations: [
        'Improve field drainage before the monsoon',
        'Remove infected capsules and panicles promptly',
        'Maintain recommended shade levels',
        'Seek guidance on preventive fungicide schedules',
      ],
    ),
    Disease(
      id: 'rhizome_rot',
      symptomPattern: SymptomPattern.rotBase,
      name: 'Rhizome Rot',
      shortDescription: 'Root & rhizome damage',
      emoji: '🌱',
      icon: Icons.eco_rounded,
      accent: Color(0xFF6B7A4A),
      typicalSeverity: DiseaseSeverity.high,
      overview:
          'A soil-borne disease attacking the rhizome and root system, '
          'often first noticed as gradual yellowing and wilting of '
          'whole tillers.',
      symptoms: [
        'Yellowing of lower leaves spreading upward',
        'Wilting tillers despite adequate soil moisture',
        'Soft, discoloured rhizome tissue when inspected',
        'Stunted new shoot growth',
      ],
      causes: [
        'Waterlogging and poorly drained soil',
        'Pythium or Fusarium infection in the root zone',
        'Reusing infected planting material',
      ],
      recommendations: [
        'Ensure the planting site drains well',
        'Remove and isolate severely wilted clumps',
        'Use disease-free rhizomes for new planting',
        'Avoid excess nitrogen fertiliser during wet spells',
      ],
    ),
    Disease(
      id: 'katte_virus',
      symptomPattern: SymptomPattern.mosaic,
      name: 'Katte (Mosaic) Disease',
      shortDescription: 'Viral mosaic pattern',
      emoji: '🟡',
      icon: Icons.blur_on_rounded,
      accent: Color(0xFFD98E2E),
      typicalSeverity: DiseaseSeverity.high,
      overview:
          'A viral disease spread mainly by aphids, causing '
          'characteristic mosaic mottling and progressive weakening '
          'of the plant with no known cure once established.',
      symptoms: [
        'Light and dark green mosaic mottling on leaves',
        'Narrow, stunted leaves with rosette appearance',
        'Reduced flowering and capsule set',
        'Gradual decline in overall plant vigour',
      ],
      causes: [
        'Transmitted by banana aphid (Pentalonia nigronervosa)',
        'Spread through infected planting material',
        'Nearby infected banana or cardamom clumps',
      ],
      recommendations: [
        'Rogue out and destroy infected clumps immediately',
        'Control aphid populations around the plantation',
        'Source certified, virus-indexed planting material',
        'Avoid planting near known infected fields',
      ],
    ),
    Disease(
      id: 'leaf_spot',
      symptomPattern: SymptomPattern.spots,
      name: 'Phyllosticta Leaf Spot',
      shortDescription: 'Minor leaf spotting',
      emoji: '🟢',
      icon: Icons.filter_vintage_rounded,
      accent: Color(0xFF3FA66B),
      typicalSeverity: DiseaseSeverity.low,
      overview:
          'A comparatively mild fungal spotting disease that mainly '
          'affects older leaves and rarely threatens overall plant '
          'health if managed early.',
      symptoms: [
        'Small circular tan spots with a darker margin',
        'Spots mainly on older, lower leaves',
        'Mild yellowing around individual spots',
      ],
      causes: [
        'High humidity combined with leaf surface moisture',
        'Weakened plants under nutrient stress',
      ],
      recommendations: [
        'Maintain balanced fertilisation',
        'Remove heavily spotted older leaves',
        'Monitor regularly during humid months',
      ],
    ),
  ];

  static Disease? byId(String id) {
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }
}
