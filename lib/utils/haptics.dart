import 'package:flutter/services.dart';
import 'package:plant_ai/services/settings_controller.dart';

/// Thin wrapper around [HapticFeedback] that always checks the user's
/// preference first, so callers never need an `if (settings.haptics)`
/// check at every call site.
class Haptics {
  Haptics._();

  static void light(SettingsController settings) {
    if (settings.haptics) HapticFeedback.lightImpact();
  }

  static void medium(SettingsController settings) {
    if (settings.haptics) HapticFeedback.mediumImpact();
  }

  static void selection(SettingsController settings) {
    if (settings.haptics) HapticFeedback.selectionClick();
  }
}
