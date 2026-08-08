import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:plant_ai/screens/credits_screen.dart';
import 'package:plant_ai/screens/privacy_policy_screen.dart';
import 'package:plant_ai/screens/sign_in_screen.dart';
import 'package:plant_ai/services/auth_service.dart';
import 'package:plant_ai/services/history_service.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/utils/haptics.dart';
import 'package:plant_ai/widgets/banner_ad_card.dart';
import 'package:plant_ai/widgets/settings_tiles.dart';
import 'package:plant_ai/utils/app_route.dart';

// TODO: once this app has a real Play Store listing, swap this for the
// real package name if it changes from com.example.plant_ai.
const _kPlayStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.plant_ai';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearHistory(BuildContext context) async {
    final history = context.read<HistoryService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear scan history?'),
        content: const Text('This removes every saved scan from this device. This cannot be undone.'),
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
    if (confirmed == true) {
      history.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History cleared.')));
      }
    }
  }

  void _resetSettings(BuildContext context) {
    context.read<SettingsController>().resetToDefaults();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings restored to default.')));
  }

  Future<void> _rateApp(BuildContext context) async {
    final uri = Uri.parse(_kPlayStoreUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CardamomAI isn\'t published on the Play Store yet.')),
      );
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'I\'ve been using CardamomAI to check my cardamom plants for disease signs — '
            'worth a try if you grow cardamom too: $_kPlayStoreUrl',
        subject: 'CardamomAI — cardamom plant disease scanner',
      ),
    );
  }

  Future<void> _sendFeedback(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'pransonchettri7@gmail.com',
      query: 'subject=${Uri.encodeComponent('CardamomAI feedback')}',
    );
    final launched = await launchUrl(uri).catchError((_) => false);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email app found. Reach out at pransonchettri7@gmail.com.')),
      );
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CardamomAI',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.eco_rounded, color: Colors.white),
      ),
      applicationLegalese: 'By Pranson Chhetri',
      children: const [
        SizedBox(height: 12),
        Text(
          'CardamomAI is an AI-assisted cardamom plant disease detection app. '
          'Scans run a real on-device model (not a cloud service, not simulated) '
          'trained on a general plant-disease dataset — not cardamom specifically — '
          'so treat every result as a helpful pointer rather than a lab-confirmed '
          'diagnosis.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.eco_rounded, color: Colors.white, size: 29),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CardamomAI', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                    SizedBox(height: 3),
                    Text('Smart crop protection', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: context.primaryText)),
          const SizedBox(height: 9),
          const _AccountSection(),
          const SizedBox(height: 20),
          Text('Appearance', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: context.primaryText)),
          const SizedBox(height: 10),
          _ThemeModeSelector(settings: settings),
          const SizedBox(height: 20),
          Text('Scanning', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: context.primaryText)),
          const SizedBox(height: 9),
          SettingsSwitchTile(
            icon: Icons.bolt_rounded,
            title: 'Auto-analyze',
            subtitle: 'Start analysis automatically after capture',
            value: settings.autoAnalyze,
            onChanged: (v) {
              Haptics.selection(settings);
              settings.setAutoAnalyze(v);
            },
          ),
          SettingsSwitchTile(
            icon: Icons.percent_rounded,
            title: 'Show confidence',
            subtitle: 'Display the AI confidence percentage on results',
            value: settings.showConfidence,
            onChanged: (v) {
              Haptics.selection(settings);
              settings.setShowConfidence(v);
            },
          ),
          SettingsSwitchTile(
            icon: Icons.save_alt_rounded,
            title: 'Save scans',
            subtitle: 'Keep scan results in your history',
            value: settings.saveScans,
            onChanged: (v) {
              Haptics.selection(settings);
              settings.setSaveScans(v);
            },
          ),
          SettingsSwitchTile(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Scanning tips',
            subtitle: 'Show helpful scanning guidance around the app',
            value: settings.scanningTips,
            onChanged: (v) {
              Haptics.selection(settings);
              settings.setScanningTips(v);
            },
          ),
          const SizedBox(height: 20),
          Text('General', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: context.primaryText)),
          const SizedBox(height: 9),
          SettingsSwitchTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Manage app alerts',
            value: settings.notifications,
            onChanged: (v) {
              Haptics.selection(settings);
              settings.setNotifications(v);
            },
          ),
          SettingsSwitchTile(
            icon: Icons.vibration_rounded,
            title: 'Haptic feedback',
            subtitle: 'Use subtle interaction feedback',
            value: settings.haptics,
            onChanged: (v) {
              settings.setHaptics(v);
              if (v) Haptics.selection(settings);
            },
          ),
          const SizedBox(height: 20),
          Text('Data', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: context.primaryText)),
          const SizedBox(height: 9),
          SettingsActionTile(
            icon: Icons.delete_outline_rounded,
            title: 'Clear history',
            subtitle: 'Remove all saved scans',
            destructive: true,
            onTap: () => _confirmClearHistory(context),
          ),
          SettingsActionTile(
            icon: Icons.restart_alt_rounded,
            title: 'Reset settings',
            subtitle: 'Restore default preferences',
            onTap: () => _resetSettings(context),
          ),
          const SizedBox(height: 20),
          Text('Support us', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: context.primaryText)),
          const SizedBox(height: 9),
          SettingsActionTile(
            icon: Icons.star_rate_rounded,
            title: 'Rate CardamomAI',
            subtitle: 'Leave a rating on the Play Store',
            onTap: () => _rateApp(context),
          ),
          SettingsActionTile(
            icon: Icons.ios_share_rounded,
            title: 'Share with a friend',
            subtitle: 'Know another cardamom grower? Pass it along',
            onTap: () => _shareApp(context),
          ),
          SettingsActionTile(
            icon: Icons.feedback_outlined,
            title: 'Send feedback',
            subtitle: 'Report a bug or suggest an improvement',
            onTap: () => _sendFeedback(context),
          ),
          const SizedBox(height: 20),
          Text('About', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: context.primaryText)),
          const SizedBox(height: 9),
          SettingsActionTile(
            icon: Icons.info_outline_rounded,
            title: 'About CardamomAI',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAbout(context),
          ),
          SettingsActionTile(
            icon: Icons.groups_rounded,
            title: 'Credits',
            subtitle: 'Meet the people behind this app',
            onTap: () => Navigator.push(context, AppRoute.to(const CreditsScreen())),
          ),
          SettingsActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'What data CardamomAI does (and doesn\'t) use',
            onTap: () => Navigator.push(context, AppRoute.to(const PrivacyPolicyScreen())),
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.push(context, AppRoute.to(const CreditsScreen())),
              child: Text(
                'By Pranson Chhetri',
                style: TextStyle(fontSize: 10, color: context.secondaryText, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const BannerAdCard(),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final SettingsController settings;

  const _ThemeModeSelector({required this.settings});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
      (ThemeMode.system, Icons.brightness_auto_rounded, 'System'),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: options.map((opt) {
          final active = settings.themeMode == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                Haptics.selection(settings);
                settings.setThemeMode(opt.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? AppColors.forest : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  children: [
                    Icon(opt.$2, size: 19, color: active ? Colors.white : context.secondaryText),
                    const SizedBox(height: 5),
                    Text(
                      opt.$3,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: active ? Colors.white : context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  Future<void> _signOut(BuildContext context, AuthService auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in anytime — nothing on this device is removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed == true) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (!auth.isAvailable) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.mutedColor,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: context.secondaryText),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sign-in isn\'t set up for this build yet. Everything else works normally.',
                style: TextStyle(fontSize: 12, color: context.secondaryText),
              ),
            ),
          ],
        ),
      );
    }

    if (!auth.isSignedIn) {
      return SettingsActionTile(
        icon: Icons.login_rounded,
        title: 'Sign in',
        subtitle: 'Optional — with Google or your phone number',
        onTap: () => Navigator.push(context, AppRoute.to(const SignInScreen())),
      );
    }

    final user = auth.currentUser!;
    final label = user.displayName ?? user.email ?? user.phoneNumber ?? 'Signed in';

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: context.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 21,
          backgroundColor: AppColors.emeraldLight.withOpacity(0.16),
          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? const Icon(Icons.person_rounded, color: AppColors.emeraldLight)
              : null,
        ),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.primaryText)),
        subtitle: Text('Signed in', style: TextStyle(fontSize: 11.5, color: context.secondaryText)),
        trailing: TextButton(
          onPressed: () => _signOut(context, auth),
          child: const Text('Sign out', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
