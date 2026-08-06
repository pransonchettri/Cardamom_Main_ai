import 'package:flutter/material.dart';
import 'package:plant_ai/theme/app_theme.dart';

class TipBanner extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const TipBanner({
    super.key,
    this.title = 'Scanning tip',
    required this.message,
    this.icon = Icons.tips_and_updates_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.warmAccent.withOpacity(context.isDark ? 0.14 : 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.warmAccent.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.warmAccentDeep, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: context.primaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: context.secondaryText, fontSize: 12.5, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
