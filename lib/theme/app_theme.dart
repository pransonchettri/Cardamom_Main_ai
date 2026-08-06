import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central colour palette for CardamomAI.
///
/// Sophisticated agricultural / AI aesthetic:
/// deep forest & emerald greens, sage / off-white surfaces,
/// dark charcoal for contrast + dark mode, with a small warm
/// accent used sparingly (never as a dominant colour).
class AppColors {
  AppColors._();

  // Core greens
  static const Color forestDeep = Color(0xFF0A2C1D);
  static const Color forest = Color(0xFF14532D);
  static const Color emerald = Color(0xFF1F8A54);
  static const Color emeraldLight = Color(0xFF3FA66B);
  static const Color mint = Color(0xFFC9F7D1);

  // Sage / off-white (light mode surfaces)
  static const Color sageBackground = Color(0xFFF4F7F2);
  static const Color sageCard = Color(0xFFFFFFFF);
  static const Color sageMuted = Color(0xFFE9F1EA);
  static const Color sageBorder = Color(0x14142B1E);

  // Charcoal (dark mode surfaces)
  static const Color charcoalBackground = Color(0xFF0F1512);
  static const Color charcoalCard = Color(0xFF1A211C);
  static const Color charcoalMuted = Color(0xFF232B25);
  static const Color charcoalBorder = Color(0x1FFFFFFF);

  // Warm accent - used sparingly (badges, warnings, highlights only)
  static const Color warmAccent = Color(0xFFE0A052);
  static const Color warmAccentDeep = Color(0xFFC97A3B);

  // Semantic
  static const Color success = Color(0xFF2F855A);
  static const Color warning = Color(0xFFD98E2E);
  static const Color danger = Color(0xFFCF4D3F);

  // Text
  static const Color textDarkPrimary = Color(0xFF14201A);
  static const Color textDarkSecondary = Color(0xFF5B6B60);
  static const Color textLightPrimary = Color(0xFFF3F7F4);
  static const Color textLightSecondary = Color(0xFFA9B8AE);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [forestDeep, forest, emeraldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [warmAccentDeep, warmAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.sageBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forest,
        brightness: Brightness.light,
        primary: AppColors.forest,
        secondary: AppColors.emeraldLight,
        tertiary: AppColors.warmAccent,
        surface: AppColors.sageCard,
      ),
      textTheme: GoogleFonts.manropeTextTheme().apply(
        bodyColor: AppColors.textDarkPrimary,
        displayColor: AppColors.textDarkPrimary,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.sageBackground,
        foregroundColor: AppColors.textDarkPrimary,
        centerTitle: false,
      ),
      splashFactory: InkSparkle.splashFactory,
      dividerColor: AppColors.sageBorder,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.charcoalBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emeraldLight,
        brightness: Brightness.dark,
        primary: AppColors.emeraldLight,
        secondary: AppColors.mint,
        tertiary: AppColors.warmAccent,
        surface: AppColors.charcoalCard,
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData(brightness: Brightness.dark).textTheme).apply(
        bodyColor: AppColors.textLightPrimary,
        displayColor: AppColors.textLightPrimary,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.charcoalBackground,
        foregroundColor: AppColors.textLightPrimary,
        centerTitle: false,
      ),
      splashFactory: InkSparkle.splashFactory,
      dividerColor: AppColors.charcoalBorder,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Small helper so widgets can pick the right surface colour
/// without importing Theme boilerplate everywhere.
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get cardColor => isDark ? AppColors.charcoalCard : AppColors.sageCard;
  Color get mutedColor => isDark ? AppColors.charcoalMuted : AppColors.sageMuted;
  Color get borderColor => isDark ? AppColors.charcoalBorder : AppColors.sageBorder;
  Color get primaryText => isDark ? AppColors.textLightPrimary : AppColors.textDarkPrimary;
  Color get secondaryText => isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary;
}
