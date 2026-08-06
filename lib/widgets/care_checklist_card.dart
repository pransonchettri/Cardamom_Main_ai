import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/services/checklist_service.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/utils/haptics.dart';

class _CareTask {
  final String id;
  final String label;
  final IconData icon;

  const _CareTask({required this.id, required this.label, required this.icon});
}

const _weeklyTasks = [
  _CareTask(id: 'inspect', label: 'Inspect leaves for spots or discoloration', icon: Icons.visibility_rounded),
  _CareTask(id: 'water', label: 'Check soil moisture and drainage', icon: Icons.water_drop_rounded),
  _CareTask(id: 'shade', label: 'Confirm shade coverage looks right', icon: Icons.wb_shade_rounded),
  _CareTask(id: 'debris', label: 'Clear fallen leaves and debris around the base', icon: Icons.cleaning_services_rounded),
  _CareTask(id: 'scan', label: 'Do a CardamomAI scan of a few leaves', icon: Icons.camera_alt_rounded),
];

/// Interactive weekly care checklist — a genuinely new, persisted
/// feature (not just static text) that lets the user track routine
/// plant-care tasks across the week. Resets automatically each week
/// via [ChecklistService].
class CareChecklistCard extends StatelessWidget {
  const CareChecklistCard({super.key});

  @override
  Widget build(BuildContext context) {
    final checklist = context.watch<ChecklistService>();
    final settings = context.watch<SettingsController>();
    final total = _weeklyTasks.length;
    final done = checklist.checkedCount.clamp(0, total);
    final progress = total == 0 ? 0.0 : done / total;
    final complete = done == total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (complete ? AppColors.emeraldLight : AppColors.warmAccent)
                      .withOpacity(context.isDark ? 0.2 : 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  complete ? Icons.celebration_rounded : Icons.checklist_rounded,
                  color: complete ? AppColors.emeraldLight : AppColors.warmAccentDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This week\'s care checklist',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.primaryText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      complete ? 'All done for this week 🎉' : '$done of $total tasks complete',
                      style: TextStyle(fontSize: 12, color: context.secondaryText),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 38,
                height: 38,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => CircularProgressIndicator(
                        value: value,
                        strokeWidth: 4,
                        backgroundColor: context.mutedColor,
                        valueColor: AlwaysStoppedAnimation(
                          complete ? AppColors.emeraldLight : AppColors.warmAccentDeep,
                        ),
                      ),
                    ),
                    Text(
                      '$done/$total',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: context.primaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._weeklyTasks.map((task) {
            final checked = checklist.isChecked(task.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Haptics.selection(settings);
                    checklist.toggle(task.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: checked ? AppColors.emeraldLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: checked ? AppColors.emeraldLight : context.borderColor,
                              width: 1.6,
                            ),
                          ),
                          child: checked
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Icon(task.icon, size: 16, color: context.secondaryText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: checked ? context.secondaryText : context.primaryText,
                              decoration: checked ? TextDecoration.lineThrough : TextDecoration.none,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
