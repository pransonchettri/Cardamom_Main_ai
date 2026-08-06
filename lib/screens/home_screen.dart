import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/data/diseases_data.dart';
import 'package:plant_ai/screens/care_guide_screen.dart';
import 'package:plant_ai/screens/disease_detail_screen.dart';
import 'package:plant_ai/screens/history_screen.dart';
import 'package:plant_ai/screens/library_screen.dart';
import 'package:plant_ai/screens/preview_screen.dart';
import 'package:plant_ai/screens/scan_screen.dart';
import 'package:plant_ai/services/favorites_service.dart';
import 'package:plant_ai/services/history_service.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/utils/app_route.dart';
import 'package:plant_ai/widgets/action_card.dart';
import 'package:plant_ai/widgets/app_logo.dart';
import 'package:plant_ai/widgets/disease_preview_card.dart';
import 'package:plant_ai/widgets/plant_health_card.dart';
import 'package:plant_ai/widgets/section_header.dart';
import 'package:plant_ai/widgets/tip_banner.dart';

const _dailyTips = [
  'Use a clear, well-lit photo and keep the affected area inside the scan frame.',
  'Natural daylight gives more accurate results than flash or indoor bulbs.',
  'Fill the frame with a single leaf rather than the whole plant for a sharper read.',
  'Scan a few different leaves if you\'re unsure — symptoms can vary across a plant.',
  'Avoid busy or cluttered backgrounds behind the leaf when you scan.',
  'Hold the camera steady for a second before capturing to avoid blur.',
  'Recheck plants weekly, especially right after heavy rain.',
];

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
      if (file == null || !context.mounted) return;
      Navigator.push(
        context,
        AppRoute.to(PreviewScreen(imagePath: file.path)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the gallery.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>();
    final settings = context.watch<SettingsController>();
    final favorites = context.watch<FavoritesService>();
    final diseases = DiseasesData.all.take(4).toList();
    final tip = _dailyTips[DateTime.now().day % _dailyTips.length];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Row(
          children: [
            const AppLogoMark(size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.1,
                      color: context.primaryText,
                    ),
                  ),
                  Text(
                    'Smart crop protection',
                    style: TextStyle(color: context.secondaryText, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      settings.notifications
                          ? 'No new notifications.'
                          : 'Notifications are turned off in Settings.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: Icon(
                settings.notifications ? Icons.notifications_none_rounded : Icons.notifications_off_outlined,
                color: context.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _HeroCard(onScan: () => Navigator.push(context, AppRoute.to(const ScanScreen()))),
        const SizedBox(height: 26),
        const SectionHeader(title: 'Quick actions'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.42,
          children: [
            _staggered(
              0,
              ActionCard(
                icon: Icons.star_rounded,
                title: 'Favorites',
                subtitle: '${favorites.ids.length} saved',
                iconColor: AppColors.warmAccentDeep,
                iconBackground: AppColors.warmAccent.withOpacity(context.isDark ? 0.18 : 0.14),
                onTap: () => Navigator.push(context, AppRoute.to(const LibraryScreen(startWithFavorites: true))),
              ),
            ),
            _staggered(
              1,
              ActionCard(
                icon: Icons.photo_library_rounded,
                title: 'Gallery',
                subtitle: 'Pick a photo',
                onTap: () => _pickFromGallery(context),
              ),
            ),
            _staggered(
              2,
              ActionCard(
                icon: Icons.history_rounded,
                title: 'History',
                subtitle: '${history.count} saved scan${history.count == 1 ? '' : 's'}',
                onTap: () => Navigator.push(context, AppRoute.to(const HistoryScreen())),
              ),
            ),
            _staggered(
              3,
              ActionCard(
                icon: Icons.health_and_safety_rounded,
                title: 'Care Guide',
                subtitle: 'Grow healthier',
                onTap: () => Navigator.push(context, AppRoute.to(const CareGuideScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        PlantHealthCard(latestScan: history.items.isEmpty ? null : history.items.first)
            .animate()
            .fadeIn(delay: 260.ms, duration: 380.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 28),
        SectionHeader(
          title: 'Common cardamom issues',
          actionLabel: 'See all',
          onAction: () => Navigator.push(context, AppRoute.to(const CareGuideScreen())),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 158,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: diseases.length,
            itemBuilder: (context, i) => DiseasePreviewCard(
              disease: diseases[i],
              onTap: () => Navigator.push(
                context,
                AppRoute.to(DiseaseDetailScreen(disease: diseases[i])),
              ),
            )
                .animate()
                .fadeIn(delay: (300 + i * 70).ms, duration: 340.ms)
                .slideX(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
          ),
        ),
        const SizedBox(height: 25),
        TipBanner(message: tip).animate().fadeIn(delay: 560.ms, duration: 380.ms),
      ],
    );
  }

  Widget _staggered(int index, Widget child) {
    return child
        .animate()
        .fadeIn(delay: (index * 60).ms, duration: 320.ms)
        .slideY(begin: 0.10, end: 0, curve: Curves.easeOutCubic);
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onScan;

  const _HeroCard({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            bottom: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 32),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.mint, size: 17),
                  SizedBox(width: 7),
                  Text(
                    'AI-POWERED ANALYSIS',
                    style: TextStyle(
                      color: AppColors.mint,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Is your cardamom\nplant healthy?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Scan a leaf or plant and check for possible disease signs in seconds.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onScan,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 7)),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_rounded, color: AppColors.forest, size: 20),
                      SizedBox(width: 9),
                      Text('Start a scan', style: TextStyle(color: AppColors.forest, fontWeight: FontWeight.w800)),
                      SizedBox(width: 14),
                      Icon(Icons.arrow_forward_rounded, color: AppColors.forest, size: 19),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
