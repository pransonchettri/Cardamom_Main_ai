import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/data/diseases_data.dart';
import 'package:plant_ai/models/disease.dart';
import 'package:plant_ai/models/scan_result.dart';
import 'package:plant_ai/screens/disease_detail_screen.dart';
import 'package:plant_ai/screens/scan_screen.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/utils/haptics.dart';
import 'package:plant_ai/widgets/app_image.dart';
import 'package:plant_ai/utils/app_route.dart';

class ResultScreen extends StatelessWidget {
  final ScanResult result;

  const ResultScreen({super.key, required this.result});

  void _scanAgain(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(AppRoute.to(const ScanScreen()));
  }

  void _done(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final severity = result.severity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result', style: TextStyle(fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: AppImage(
                    path: result.imagePath,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_) => Container(
                      height: 220,
                      color: context.mutedColor,
                      child: const Center(child: Icon(Icons.image_not_supported_rounded, size: 48)),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: result.isInconclusive
                      ? const _InconclusiveBadge()
                      : _SeverityBadge(severity: severity),
                ),
              ],
            ).animate().fadeIn(duration: 360.ms),
            if (result.isHealthy) ...[
              const SizedBox(height: 16),
              const _HealthyCelebration(),
            ],
            const SizedBox(height: 16),
            _AISourceBadge(result: result),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.diseaseName,
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: context.primaryText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.isInconclusive
                            ? 'Try retaking the photo for a clearer result.'
                            : result.isHealthy
                                ? 'No signs of disease were detected.'
                                : 'Possible signs detected in this scan.',
                        style: TextStyle(color: context.secondaryText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (settings.showConfidence && !result.isInconclusive)
                  Column(
                    children: [
                      SizedBox(
                        width: 58,
                        height: 58,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: result.confidence,
                              strokeWidth: 6,
                              backgroundColor: context.mutedColor,
                              valueColor: AlwaysStoppedAnimation(severity.color),
                            ),
                            Text(
                              result.confidencePercent,
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: severity.color),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Confidence', style: TextStyle(fontSize: 10, color: context.secondaryText)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (result.secondaryDiseaseName != null) ...[
              _SecondOpinionNote(alternativeName: result.secondaryDiseaseName!),
              const SizedBox(height: 16),
            ],
            _ResultSection(
              title: 'Symptoms observed',
              icon: Icons.visibility_rounded,
              items: result.symptoms,
            ),
            const SizedBox(height: 16),
            _ResultSection(
              title: 'Recommendations',
              icon: Icons.checklist_rtl_rounded,
              items: result.recommendations,
              accent: AppColors.warmAccentDeep,
            ),
            if (result.diseaseId != null) ...[
              const SizedBox(height: 12),
              _LibraryLinkTile(diseaseId: result.diseaseId!),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.mutedColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: context.secondaryText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.isSimulated
                          ? 'This result is simulated for preview purposes (real on-device analysis isn\'t available in this environment).'
                          : 'This uses a general plant-disease model trained on common crops, not cardamom specifically. Treat this as a helpful pointer, not a confirmed diagnosis.',
                      style: TextStyle(fontSize: 11.5, color: context.secondaryText, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _done(context),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.primaryText,
                        side: BorderSide(color: context.borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () {
                        Haptics.medium(settings);
                        _scanAgain(context);
                      },
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Scan again', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.forest,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final DiseaseSeverity severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: severity.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            '${severity.label} severity',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _SecondOpinionNote extends StatelessWidget {
  final String alternativeName;

  const _SecondOpinionNote({required this.alternativeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.warmAccent.withOpacity(context.isDark ? 0.12 : 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warmAccent.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.balance_rounded, size: 17, color: AppColors.warmAccentDeep),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This was a close call — $alternativeName showed a similar pattern match. Worth comparing both in the Library.',
              style: TextStyle(fontSize: 11.5, color: context.secondaryText, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _InconclusiveBadge extends StatelessWidget {
  const _InconclusiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline_rounded, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text('Not recognized', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _AISourceBadge extends StatelessWidget {
  final ScanResult result;

  const _AISourceBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    final isReal = !result.isSimulated;
    final color = isReal ? AppColors.emeraldLight : AppColors.warmAccentDeep;
    final icon = isReal ? Icons.memory_rounded : Icons.science_outlined;
    final label = isReal ? 'On-device AI' : 'Simulated preview';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 10.5)),
            ],
          ),
        ),
        if (isReal && result.diseaseId != null && !result.isInconclusive)
          Text(
            'Matched by general leaf-pattern AI, not cardamom-specific',
            style: TextStyle(fontSize: 10, color: context.secondaryText, fontStyle: FontStyle.italic),
          ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final Color? accent;

  const _ResultSection({required this.title, required this.icon, required this.items, this.accent});

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.emeraldLight;
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
              Icon(icon, color: color, size: 19),
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
                    child: Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(e, style: TextStyle(fontSize: 12.5, color: context.secondaryText, height: 1.4)),
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

class _HealthyCelebration extends StatelessWidget {
  const _HealthyCelebration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.emeraldLight.withOpacity(0.18), AppColors.emeraldLight.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emeraldLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.emeraldLight, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
          )
              .animate()
              .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(1, 1),
                duration: 480.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .shake(hz: 2, duration: 400.ms, curve: Curves.easeInOut),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Looking healthy!',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.primaryText),
                ),
                const SizedBox(height: 3),
                Text(
                  'Keep up your current care routine.',
                  style: TextStyle(fontSize: 12, color: context.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}

class _LibraryLinkTile extends StatelessWidget {
  final String diseaseId;

  const _LibraryLinkTile({required this.diseaseId});

  @override
  Widget build(BuildContext context) {
    final disease = DiseasesData.byId(diseaseId);
    if (disease == null) return const SizedBox.shrink();

    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context, AppRoute.to(DiseaseDetailScreen(disease: disease))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: disease.accent.withOpacity(context.isDark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(disease.icon, color: disease.accent, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Learn more about ${disease.name} in the Library',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: context.primaryText),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}
