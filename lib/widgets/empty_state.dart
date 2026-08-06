import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:plant_ai/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.mutedColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.emeraldLight, size: 32),
          ).animate().scale(
                duration: 420.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.7, 0.7),
                end: const Offset(1, 1),
              ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: context.primaryText),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.secondaryText, fontSize: 12.5, height: 1.5),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 380.ms);
  }
}
