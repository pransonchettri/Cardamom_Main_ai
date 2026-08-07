import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds all user-facing app preferences and persists them to disk.
///
/// This is a plain [ChangeNotifier] provided at the root of the app so
/// any screen can read current settings or toggle them, and the whole
/// app (theme included) reacts immediately.
class SettingsController extends ChangeNotifier {
  static const _kThemeMode = 'settings.themeMode';
  static const _kAutoAnalyze = 'settings.autoAnalyze';
  static const _kShowConfidence = 'settings.showConfidence';
  static const _kSaveScans = 'settings.saveScans';
  static const _kNotifications = 'settings.notifications';
  static const _kHaptics = 'settings.haptics';
  static const _kScanningTips = 'settings.scanningTips';
  static const _kHasOnboarded = 'settings.hasOnboarded';
  static const _kHasSeenSignIn = 'settings.hasSeenSignIn';

  ThemeMode _themeMode = ThemeMode.system;
  bool _autoAnalyze = false;
  bool _showConfidence = true;
  bool _saveScans = true;
  bool _notifications = true;
  bool _haptics = true;
  bool _scanningTips = true;
  bool _hasOnboarded = false;
  bool _hasSeenSignIn = false;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get autoAnalyze => _autoAnalyze;
  bool get showConfidence => _showConfidence;
  bool get saveScans => _saveScans;
  bool get notifications => _notifications;
  bool get haptics => _haptics;
  bool get scanningTips => _scanningTips;
  bool get hasOnboarded => _hasOnboarded;
  bool get hasSeenSignIn => _hasSeenSignIn;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_kThemeMode);
    if (modeIndex != null && modeIndex >= 0 && modeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[modeIndex];
    }
    _autoAnalyze = prefs.getBool(_kAutoAnalyze) ?? _autoAnalyze;
    _showConfidence = prefs.getBool(_kShowConfidence) ?? _showConfidence;
    _saveScans = prefs.getBool(_kSaveScans) ?? _saveScans;
    _notifications = prefs.getBool(_kNotifications) ?? _notifications;
    _haptics = prefs.getBool(_kHaptics) ?? _haptics;
    _scanningTips = prefs.getBool(_kScanningTips) ?? _scanningTips;
    _hasOnboarded = prefs.getBool(_kHasOnboarded) ?? _hasOnboarded;
    _hasSeenSignIn = prefs.getBool(_kHasSeenSignIn) ?? _hasSeenSignIn;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setHasSeenSignIn(bool value) async {
    _hasSeenSignIn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasSeenSignIn, value);
  }

  Future<void> setHasOnboarded(bool value) async {
    _hasOnboarded = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasOnboarded, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeMode, mode.index);
  }

  Future<void> setAutoAnalyze(bool value) async {
    _autoAnalyze = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoAnalyze, value);
  }

  Future<void> setShowConfidence(bool value) async {
    _showConfidence = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowConfidence, value);
  }

  Future<void> setSaveScans(bool value) async {
    _saveScans = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSaveScans, value);
  }

  Future<void> setNotifications(bool value) async {
    _notifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
  }

  Future<void> setHaptics(bool value) async {
    _haptics = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHaptics, value);
  }

  Future<void> setScanningTips(bool value) async {
    _scanningTips = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kScanningTips, value);
  }

  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _autoAnalyze = false;
    _showConfidence = true;
    _saveScans = true;
    _notifications = true;
    _haptics = true;
    _scanningTips = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kThemeMode);
    await prefs.remove(_kAutoAnalyze);
    await prefs.remove(_kShowConfidence);
    await prefs.remove(_kSaveScans);
    await prefs.remove(_kNotifications);
    await prefs.remove(_kHaptics);
    await prefs.remove(_kScanningTips);
  }
}
