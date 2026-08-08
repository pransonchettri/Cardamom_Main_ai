import 'package:flutter/material.dart';
import 'package:plant_ai/theme/app_theme.dart';

class _PolicySection {
  final String title;
  final IconData icon;
  final String body;

  const _PolicySection({required this.title, required this.icon, required this.body});
}

const _sections = [
  _PolicySection(
    title: 'Scan photos',
    icon: Icons.camera_alt_rounded,
    body: 'Photos you scan are analyzed entirely on your device and stored only in this '
        'app\'s local history on your phone. They are never uploaded to a server as part '
        'of getting a result.',
  ),
  _PolicySection(
    title: 'Account info (optional)',
    icon: Icons.person_rounded,
    body: 'Signing in is entirely optional. If you choose to sign in with Google or your '
        'phone number, Firebase Authentication (a Google service) handles verifying your '
        'identity and stores basic account info (name, email, or phone number) tied to '
        'your account. Every core feature — scanning, library, history, care guide — works '
        'fully without signing in.',
  ),
  _PolicySection(
    title: 'Ads',
    icon: Icons.ads_click_rounded,
    body: 'This app shows ads via Google AdMob, which may collect device and advertising '
        'identifiers to serve and measure ads, per Google\'s own privacy policy. CardamomAI '
        'does not itself sell or share your data with advertisers beyond what AdMob '
        'requires to function.',
  ),
  _PolicySection(
    title: 'Your controls',
    icon: Icons.tune_rounded,
    body: 'You can clear your saved scan history at any time from Settings, sign out '
        'whenever you like, and turn off notifications and haptics — all from the '
        'Settings screen, with immediate effect.',
  ),
  _PolicySection(
    title: 'Contact',
    icon: Icons.mail_outline_rounded,
    body: 'Questions about this policy or your data can be sent to '
        'pransonchettri7@gmail.com.',
  ),
];

/// A plain-language privacy summary shown in-app. Before a real Play
/// Store submission, this same text should also be published at a
/// public URL (e.g. a free GitHub Pages page) — Play Console requires
/// a hosted privacy policy link, not just an in-app screen.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'CardamomAI keeps things simple: your scans stay on your device, '
                    'and account sign-in is always optional.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._sections.map((s) => _SectionCard(section: s)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _PolicySection section;

  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(section.icon, color: AppColors.emeraldLight, size: 19),
              const SizedBox(width: 9),
              Text(section.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: context.primaryText)),
            ],
          ),
          const SizedBox(height: 10),
          Text(section.body, style: TextStyle(fontSize: 12.5, color: context.secondaryText, height: 1.5)),
        ],
      ),
    );
  }
}
