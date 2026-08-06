import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/screens/splash_screen.dart';
import 'package:plant_ai/services/checklist_service.dart';
import 'package:plant_ai/services/favorites_service.dart';
import 'package:plant_ai/services/history_service.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsController();
  final favorites = FavoritesService();
  final checklist = ChecklistService();
  await Future.wait([settings.load(), favorites.load(), checklist.load()]);

  runApp(CardamomAI(settings: settings, favorites: favorites, checklist: checklist));
}

class CardamomAI extends StatelessWidget {
  final SettingsController settings;
  final FavoritesService favorites;
  final ChecklistService checklist;

  const CardamomAI({
    super.key,
    required this.settings,
    required this.favorites,
    required this.checklist,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProvider<FavoritesService>.value(value: favorites),
        ChangeNotifierProvider<ChecklistService>.value(value: checklist),
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
