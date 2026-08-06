import 'package:flutter/material.dart';
import 'package:plant_ai/models/disease.dart';
import 'package:plant_ai/models/scan_result.dart';
import 'package:plant_ai/theme/app_theme.dart';

class PlantHealthCard extends StatelessWidget {
  final ScanResult? latestScan;

  const PlantHealthCard({super.key, this.latestScan});

  @override
  Widget build(BuildContext context) {
    final hasScan = latestScan != null;
    final value = hasScan ? latestScan!.confidence : 0.0;
    final color = hasScan ? latestScan!.severity.color : AppColors.emeraldLight;
    final title = hasScan ? latestScan!.diseaseName : 'No scans yet';
    final subtitle = hasScan
        ? (latestScan!.isHealthy
            ? 'Your last scan looked healthy.'
            : 'Detected in your most recent scan.')
        : 'Scan a leaf to see plant health here.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 66,
            height: 66,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: hasScan ? value : 1,
                  strokeWidth: 6.5,
                  backgroundColor: context.mutedColor,
                  valueColor: AlwaysStoppedAnimation(hasScan ? color : context.mutedColor),
                ),
                hasScan
                    ? Text(
                        latestScan!.confidencePercent,
                        style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13),
                      )
                    : Icon(Icons.eco_outlined, color: context.secondaryText, size: 22),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plant health',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.primaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: context.secondaryText, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
