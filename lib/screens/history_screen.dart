import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/models/disease.dart';
import 'package:plant_ai/models/scan_result.dart';
import 'package:plant_ai/screens/result_screen.dart';
import 'package:plant_ai/screens/scan_screen.dart';
import 'package:plant_ai/services/history_service.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/widgets/app_image.dart';
import 'package:plant_ai/widgets/empty_state.dart';
import 'package:plant_ai/widgets/stat_chip.dart';
import 'package:plant_ai/utils/app_route.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _confirmClear(BuildContext context, HistoryService history) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This will remove all saved scans from this device. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) history.clear();
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (!history.isEmpty)
            IconButton(
              tooltip: 'Clear history',
              onPressed: () => _confirmClear(context, history),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: history.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: EmptyState(
                  icon: Icons.history_rounded,
                  title: 'No saved scans yet',
                  message: 'Scans you save will appear here, so you can track your plant\'s health over time.',
                  actionLabel: 'Start a scan',
                  onAction: () => Navigator.push(context, AppRoute.to(const ScanScreen())),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: history.items.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _HistoryStatsRow(items: history.items),
                  );
                }
                return _HistoryTile(result: history.items[i - 1]);
              },
            ),
    );
  }
}

class _HistoryStatsRow extends StatelessWidget {
  final List<ScanResult> items;

  const _HistoryStatsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final healthyCount = items.where((e) => e.isHealthy).length;
    final healthyPercent = items.isEmpty ? 0 : ((healthyCount / items.length) * 100).round();

    final counts = <String, int>{};
    for (final item in items) {
      if (item.isHealthy) continue;
      counts[item.diseaseName] = (counts[item.diseaseName] ?? 0) + 1;
    }
    String mostCommon = '—';
    var topCount = 0;
    counts.forEach((name, count) {
      if (count > topCount) {
        topCount = count;
        mostCommon = name;
      }
    });

    return Row(
      children: [
        StatChip(icon: Icons.photo_camera_back_rounded, value: '${items.length}', label: 'Total scans'),
        const SizedBox(width: 10),
        StatChip(
          icon: Icons.eco_rounded,
          value: '$healthyPercent%',
          label: 'Healthy',
          color: AppColors.success,
        ),
        const SizedBox(width: 10),
        StatChip(
          icon: Icons.priority_high_rounded,
          value: mostCommon == '—' ? '—' : mostCommon.split(' ').first,
          label: 'Most common',
          color: AppColors.warmAccentDeep,
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ScanResult result;

  const _HistoryTile({required this.result});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: () => Navigator.push(context, AppRoute.to(ResultScreen(result: result))),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 52,
            height: 52,
            child: AppImage(
              path: result.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_) => Container(
                color: context.mutedColor,
                child: Icon(Icons.image_not_supported_rounded, color: context.secondaryText, size: 20),
              ),
            ),
          ),
        ),
        title: Text(result.diseaseName, style: TextStyle(fontWeight: FontWeight.w800, color: context.primaryText)),
        subtitle: Text(
          '${result.severity.label} severity · ${_formatDate(result.timestamp)}',
          style: TextStyle(fontSize: 11.5, color: context.secondaryText),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: result.severity.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            result.confidencePercent,
            style: TextStyle(color: result.severity.color, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ),
      ),
    );
  }
}
