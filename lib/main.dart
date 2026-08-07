import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/firebase_options.dart';
import 'package:plant_ai/screens/splash_screen.dart';
import 'package:plant_ai/services/ad_service.dart';
import 'package:plant_ai/services/auth_service.dart';
import 'package:plant_ai/services/checklist_service.dart';
import 'package:plant_ai/services/favorites_service.dart';
import 'package:plant_ai/services/history_service.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is entirely optional at runtime — every core feature of
  // CardamomAI (scanning, library, history, care guide) works with no
  // Firebase involvement at all. If `flutterfire configure` hasn't
  // been run yet for this project, this simply fails quietly and
  // AuthService reports sign-in as unavailable rather than the app
  // crashing on startup.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // Not configured yet - continue without Firebase.
  }

  await AdService.initialize();

  final settings = SettingsController();
  final favorites = FavoritesService();
  final checklist = ChecklistService();
  final auth = AuthService();
  await Future.wait([settings.load(), favorites.load(), checklist.load()]);

  runApp(CardamomAI(settings: settings, favorites: favorites, checklist: checklist, auth: auth));
}

class CardamomAI extends StatelessWidget {
  final SettingsController settings;
  final FavoritesService favorites;
  final ChecklistService checklist;
  final AuthService auth;

  const CardamomAI({
    super.key,
    required this.settings,
    required this.favorites,
    required this.checklist,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProvider<FavoritesService>.value(value: favorites),
        ChangeNotifierProvider<ChecklistService>.value(value: checklist),
        ChangeNotifierProvider<AuthService>.value(value: auth),
        ChangeNotifierProvider<HistoryService>(create: (_) => HistoryService()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CardamomAI',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
