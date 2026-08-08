import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_ai/models/scan_result.dart';

/// Persisted store of past scan results, most recent first.
///
/// Saved as a single JSON-encoded string in SharedPreferences (same
/// approach as [FavoritesService]/[SettingsController]) — no database
/// dependency needed for what is, realistically, at most a few hundred
/// small text records. Capped at [_kMaxItems] so history can't grow
/// without bound on a device that's never cleared it.
class HistoryService extends ChangeNotifier {
  static const _kKey = 'history.scans.v1';
  static const _kMaxItems = 200;

  final List<ScanResult> _items = [];
  bool _loaded = false;

  List<ScanResult> get items => List.unmodifiable(_items);

  bool get loaded => _loaded;

  bool get isEmpty => _items.isEmpty;

  int get count => _items.length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List;
        _items
          ..clear()
          ..addAll(
            decoded
                .whereType<Map<String, dynamic>>()
                .map(ScanResult.fromJson)
                .whereType<ScanResult>(),
          );
      } catch (_) {
        // Corrupt/unreadable saved history shouldn't block the app from
        // starting — just start with an empty list instead.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, encoded);
  }

  void add(ScanResult result) {
    _items.insert(0, result);
    if (_items.length > _kMaxItems) {
      _items.removeRange(_kMaxItems, _items.length);
    }
    notifyListeners();
    unawaited(_persist());
  }

  void clear() {
    _items.clear();
    notifyListeners();
    unawaited(_persist());
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    unawaited(_persist());
  }
}
