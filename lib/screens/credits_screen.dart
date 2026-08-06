import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/utils/haptics.dart';
import 'package:plant_ai/widgets/app_logo.dart';
import 'package:plant_ai/widgets/floating_decor.dart';

/// A dedicated, celebratory screen crediting everyone behind CardamomAI.
///
/// Purely presentational — no state, no navigation side effects beyond
/// the back button — so it's kept as a single self-contained file.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            const FloatingDecor(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 40),
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    const AppLogoMark(size: 84, iconScale: 0.5)
                        .animate()
                        .scale(
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1, 1),
                          duration: 650.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 22),
                    const Text(
                      'CardamomAI',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                    ).animate().fadeIn(delay: 150.ms, duration: 450.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 6),
                    Text(
                      'Smart crop protection',
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12.5, letterSpacing: 0.4),
                    ).animate().fadeIn(delay: 220.ms, duration: 450.ms),
                    const SizedBox(height: 30),
                    _GrowingDivider(delay: 300.ms),
                    const SizedBox(height: 30),
                    Text(
                      'CREATED BY',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                      ),
                    ).animate().fadeIn(delay: 420.ms, duration: 400.ms),
                    const SizedBox(height: 14),
                    const _CreditCard(
                      icon: Icons.emoji_events_rounded,
                      iconColor: AppColors.warmAccent,
                      name: 'Pranson Chettri',
                      role: '9th Grade Student',
                      meta: 'KPTGSS',
                      delay: 500,
                      featured: true,
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'GUIDED BY',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                    const SizedBox(height: 14),
                    const _CreditCard(
                      icon: Icons.school_rounded,
                      iconColor: AppColors.mint,
                      name: 'Mr Arpan Sharma',
                      role: 'ICT Guide Teacher',
                      meta: 'KPTGSS',
                      delay: 780,
                    ),
                    const SizedBox(height: 12),
                    const _CreditCard(
                      icon: Icons.school_rounded,
                      iconColor: AppColors.mint,
                      name: 'Mr Buddha Rai',
                      role: 'Supporting Teacher',
                      meta: 'KPTGSS',
                      delay: 900,
                    ),
                    const SizedBox(height: 40),
                    _GrowingDivider(delay: 1050.ms),
                    const SizedBox(height: 24),
                    const _HeartFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String role;
  final String meta;
  final int delay;
  final bool featured;

  const _CreditCard({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.role,
    required this.meta,
    required this.delay,
    this.featured = false,
  });

  @override
  State<_CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<_CreditCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final size = widget.featured ? 60.0 : 50.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light(settings);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: widget.featured ? 22 : 16, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(widget.featured ? 0.14 : 0.09),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(widget.featured ? 0.3 : 0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.22),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.iconColor.withOpacity(0.4), width: 1.4),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: widget.featured ? 28 : 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: widget.featured ? 18 : 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.role,
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  widget.meta,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: widget.delay.ms, duration: 450.ms)
        .slideX(begin: 0.08, end: 0, delay: widget.delay.ms, duration: 450.ms, curve: Curves.easeOutCubic);
  }
}

class _GrowingDivider extends StatelessWidget {
  final Duration delay;

  const _GrowingDivider({required this.delay});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      width: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.white.withOpacity(0.6), Colors.transparent],
          ),
        ),
      ),
    ).animate().scaleX(begin: 0, end: 1, delay: delay, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

class _HeartFooter extends StatelessWidget {
  const _HeartFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Built with', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
            const SizedBox(width: 6),
            const Icon(Icons.favorite_rounded, color: Color(0xFFFF8A80), size: 14)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.3, 1.3),
                  duration: 700.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(width: 6),
            Text('using Flutter', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Version 1.0.0',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10.5, fontWeight: FontWeight.w600),
        ),
      ],
    ).animate().fadeIn(delay: 1150.ms, duration: 500.ms);
  }
}
