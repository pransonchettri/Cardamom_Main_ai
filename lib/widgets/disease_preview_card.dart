import 'package:flutter/material.dart';
import 'package:plant_ai/models/disease.dart';
import 'package:plant_ai/theme/app_theme.dart';

class DiseasePreviewCard extends StatelessWidget {
  final Disease disease;
  final VoidCallback onTap;

  const DiseasePreviewCard({super.key, required this.disease, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 172,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: disease.accent.withOpacity(context.isDark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(disease.icon, color: disease.accent, size: 24),
              ),
              const Spacer(),
              Text(
                disease.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: context.primaryText),
              ),
              const SizedBox(height: 3),
              Text(
                disease.shortDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: context.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
