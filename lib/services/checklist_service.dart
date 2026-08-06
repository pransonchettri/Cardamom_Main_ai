import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which weekly care tasks the user has checked off.
///
/// Automatically resets when a new week starts (a lightweight
/// "yyyy-Wnn" style stamp is compared on load), so the checklist is
/// always fresh for the current week rather than accumulating forever.
class ChecklistService extends ChangeNotifier {
  static const _kCheckedKey = 'checklist.checkedIds';
  static const _kWeekKey = 'checklist.weekId';

  Set<String> _checked = {};
  bool _loaded = false;

  bool get loaded => _loaded;
  int get checkedCount => _checked.length;

  bool isChecked(String id) => _checked.contains(id);

  String _currentWeekId() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final daysSinceStart = now.difference(startOfYear).inDays;
    final week = (daysSinceStart / 7).floor();
    return '${now.year}-W$week';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedWeek = prefs.getString(_kWeekKey);
    final thisWeek = _currentWeekId();

    if (storedWeek != thisWeek) {
      // A new week started since we last opened the app — start fresh.
      _checked = {};
      await prefs.setString(_kWeekKey, thisWeek);
      await prefs.setStringList(_kCheckedKey, const []);
    } else {
      _checked = (prefs.getStringList(_kCheckedKey) ?? const []).toSet();
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String taskId) async {
    if (_checked.contains(taskId)) {
      _checked.remove(taskId);
    } else {
      _checked.add(taskId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kCheckedKey, _checked.toList());
  }
}
