import 'package:flutter/material.dart';
import 'package:plant_ai/models/scan_result.dart';

/// In-memory store of past scan results.
///
/// Kept intentionally simple (a List in memory) so the History and
/// Home screens have real data to render today. The public API
/// (add / clear / list) is the seam a persistent store (SQLite,
/// Hive, a backend, etc.) can plug into later without any UI changes.
class HistoryService extends ChangeNotifier {
  final List<ScanResult> _items = [];

  List<ScanResult> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get count => _items.length;

  void add(ScanResult result) {
    _items.insert(0, result);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
