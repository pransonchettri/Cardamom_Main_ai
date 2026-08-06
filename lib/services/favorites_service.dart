import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which diseases the user has starred in the Library so they
/// can jump back to the ones they care about most.
///
/// Persisted as a simple string set in SharedPreferences, keyed by
/// [Disease.id].
class FavoritesService extends ChangeNotifier {
  static const _kKey = 'favorites.diseaseIds';

  Set<String> _ids = {};
  bool _loaded = false;

  bool get loaded => _loaded;
  Set<String> get ids => Set.unmodifiable(_ids);

  bool isFavorite(String diseaseId) => _ids.contains(diseaseId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _ids = (prefs.getStringList(_kKey) ?? const []).toSet();
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String diseaseId) async {
    if (_ids.contains(diseaseId)) {
      _ids.remove(diseaseId);
    } else {
      _ids.add(diseaseId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kKey, _ids.toList());
  }
}
