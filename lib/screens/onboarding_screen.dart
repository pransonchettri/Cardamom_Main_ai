import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/screens/root_shell.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/widgets/app_logo.dart';
import 'package:plant_ai/widgets/floating_decor.dart';
import 'package:plant_ai/utils/app_route.dart';

class _OnboardPage {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardPage({required this.icon, required this.title, required this.description});
}

const _pages = [
  _OnboardPage(
    icon: Icons.camera_alt_rounded,
    title: 'Scan any cardamom leaf',
    description: 'Point your camera at a leaf or capsule and get an instant, on-device style read on its health.',
  ),
  _OnboardPage(
    icon: Icons.psychology_rounded,
    title: 'AI-assisted analysis',
    description: 'CardamomAI checks for common disease patterns and gives you confidence, severity and next steps.',
  ),
  _OnboardPage(
    icon: Icons.menu_book_rounded,
    title: 'Learn as you grow',
    description: 'Browse a library of common cardamom diseases and a care guide to help prevent problems early.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _finish() {
    context.read<SettingsController>().setHasOnboarded(true);
    Navigator.of(context).pushReplacement(
      AppRoute.to(const RootShell()),
    );
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastPage = _index == _pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            const FloatingDecor(),
            SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text('Skip', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (i == 0) const AppLogoMark(size: 64, iconScale: 0.5),
                          if (i == 0) const SizedBox(height: 22),
                          Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
                            ),
                            child: Icon(page.icon, color: Colors.white, size: 46),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.55),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.forest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    ),
                    child: Text(
                      lastPage ? 'Get started' : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }
}
