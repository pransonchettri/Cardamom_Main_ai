import 'package:flutter/material.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/widgets/care_checklist_card.dart';

class _CareSection {
  final String title;
  final IconData icon;
  final Color accent;
  final List<String> points;

  const _CareSection({required this.title, required this.icon, required this.accent, required this.points});
}

const _sections = [
  _CareSection(
    title: 'Lighting',
    icon: Icons.wb_sunny_rounded,
    accent: AppColors.warmAccentDeep,
    points: [
      'Cardamom prefers dappled, filtered shade rather than direct sun',
      'Aim for roughly 40–60% canopy shade in outdoor plantations',
      'Avoid deep, dense shade which encourages fungal growth',
      'Indoors, place near a bright window without harsh direct rays',
    ],
  ),
  _CareSection(
    title: 'Scanning tips',
    icon: Icons.center_focus_strong_rounded,
    accent: AppColors.emeraldLight,
    points: [
      'Use natural daylight rather than flash when possible',
      'Fill the frame with a single leaf or the affected area',
      'Hold the camera steady and keep the leaf flat',
      'Avoid heavy shadows falling across the scan area',
      'Take a few scans from slightly different angles if unsure',
    ],
  ),
  _CareSection(
    title: 'Symptoms to watch for',
    icon: Icons.remove_red_eye_rounded,
    accent: AppColors.danger,
    points: [
      'Unusual spots, lesions or discoloration on leaves',
      'Yellowing that spreads from the base of the plant',
      'Wilting despite normal watering',
      'Soft or mushy rhizome and root tissue',
      'Mottled or mosaic-like leaf patterns',
    ],
  ),
  _CareSection(
    title: 'General plant care',
    icon: Icons.local_florist_rounded,
    accent: AppColors.forest,
    points: [
      'Maintain well-drained, organically rich soil',
      'Water consistently but avoid waterlogging',
      'Space plants to allow good air circulation',
      'Remove fallen leaves and debris regularly',
      'Inspect plants weekly, especially during monsoon season',
    ],
  ),
];

class CareGuideScreen extends StatelessWidget {
  const CareGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant Care Guide', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Icon(Icons.eco_rounded, color: Colors.white, size: 30),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Healthy habits lead to healthier scans and healthier plants.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const CareChecklistCard(),
          const SizedBox(height: 20),
          ..._sections.map((s) => _CareSectionCard(section: s)),
        ],
      ),
    );
  }
}

class _CareSectionCard extends StatelessWidget {
  final _CareSection section;

  const _CareSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          shape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: section.accent.withOpacity(context.isDark ? 0.22 : 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(section.icon, color: section.accent),
          ),
          title: Text(section.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: context.primaryText)),
          iconColor: context.secondaryText,
          collapsedIconColor: context.secondaryText,
          children: section.points
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(color: section.accent, shape: BoxShape.circle),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(p, style: TextStyle(fontSize: 12.5, color: context.secondaryText, height: 1.4))),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
