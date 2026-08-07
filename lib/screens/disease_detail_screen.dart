import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/models/disease.dart';
import 'package:plant_ai/services/favorites_service.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/widgets/disease_leaf_illustration.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final Disease disease;

  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesService>();
    final isFav = favorites.isFavorite(disease.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: context.isDark ? AppColors.charcoalBackground : AppColors.sageBackground,
            foregroundColor: context.primaryText,
            actions: [
              IconButton(
                tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                onPressed: () => favorites.toggle(disease.id),
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFav ? AppColors.warmAccentDeep : context.primaryText,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
              title: Text(
                disease.name,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [disease.accent.withOpacity(0.28), disease.accent.withOpacity(0.06)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: disease.accent.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: DiseaseLeafIllustration(
                      pattern: disease.symptomPattern,
                      accent: disease.accent,
                      size: 76,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: disease.typicalSeverity.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Typically ${disease.typicalSeverity.label.toLowerCase()} severity',
                          style: TextStyle(
                            color: disease.typicalSeverity.color,
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    disease.overview,
                    style: TextStyle(color: context.secondaryText, fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  _InfoBlock(
                    title: 'Symptoms',
                    icon: Icons.visibility_rounded,
                    items: disease.symptoms,
                    accent: disease.accent,
                  ),
                  const SizedBox(height: 16),
                  _InfoBlock(
                    title: 'Common causes',
                    icon: Icons.science_rounded,
                    items: disease.causes,
                    accent: AppColors.warmAccentDeep,
                  ),
                  const SizedBox(height: 16),
                  _InfoBlock(
                    title: 'Recommendations',
                    icon: Icons.checklist_rtl_rounded,
                    items: disease.recommendations,
                    accent: AppColors.emeraldLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final Color accent;

  const _InfoBlock({required this.title, required this.icon, required this.items, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 19),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: context.primaryText)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(width: 5, height: 5, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e, style: TextStyle(fontSize: 12.5, color: context.secondaryText, height: 1.4))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
