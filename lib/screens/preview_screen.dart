import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/screens/analysis_screen.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/utils/haptics.dart';
import 'package:plant_ai/widgets/app_image.dart';
import 'package:plant_ai/utils/app_route.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  int? _countdown;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsController>();
      if (settings.autoAnalyze) {
        _startCountdown();
      }
    });
  }

  Future<void> _startCountdown() async {
    setState(() => _countdown = 3);
    for (var i = 3; i >= 1; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _cancelled) return;
      setState(() => _countdown = i - 1);
    }
    if (!mounted || _cancelled) return;
    _goToAnalysis();
  }

  void _cancelCountdown() {
    setState(() {
      _cancelled = true;
      _countdown = null;
    });
  }

  void _goToAnalysis() {
    Navigator.push(
      context,
      AppRoute.to(AnalysisScreen(imagePath: widget.imagePath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review scan', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: AppImage(
                          path: widget.imagePath,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_) => Container(
                            color: context.mutedColor,
                            child: const Center(child: Icon(Icons.image_not_supported_rounded, size: 60)),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 320.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
                    if (_countdown != null)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _countdown! > 0 ? '${_countdown!}' : 'Go',
                                  key: ValueKey(_countdown),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 54,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ).animate(key: ValueKey('c-$_countdown')).scale(
                                      begin: const Offset(0.6, 0.6),
                                      end: const Offset(1, 1),
                                      duration: 300.ms,
                                      curve: Curves.easeOutBack,
                                    ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Auto-analyzing…',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 18),
                                TextButton(
                                  onPressed: _cancelCountdown,
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.15),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Make sure the leaf is clear and the affected area is visible.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.secondaryText),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Haptics.light(settings);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Retake', style: TextStyle(fontWeight: FontWeight.w800)),
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
                          _cancelled = true;
                          _goToAnalysis();
                        },
                        icon: const Icon(Icons.psychology_rounded),
                        label: const Text('Analyze with CardamomAI', style: TextStyle(fontWeight: FontWeight.w800)),
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
      ),
    );
  }
}
