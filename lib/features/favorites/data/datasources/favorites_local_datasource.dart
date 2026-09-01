import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/favorite_pair_model.dart';

/// Contract for favorites local data source.
abstract class FavoritesLocalDataSource {
  Future<List<FavoritePairModel>> getFavorites();
  Future<void> addFavorite(FavoritePairModel pair);
  Future<void> removeFavorite(String id);
  Future<bool> isFavorite(String id);
}

/// Local data source responsible for persisting and managing favorite currency pairs using structured Hive database caching.
class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final Box<Map>? _box;
  final SharedPreferences? _prefs;

  FavoritesLocalDataSourceImpl([this._box, this._prefs]);

  @override
  Future<List<FavoritePairModel>> getFavorites() async {
    if (_box != null && _box.isOpen) {
      if (_box.isNotEmpty) {
        return _box.values
            .map((item) =>
                FavoritePairModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      // Migrate from legacy SharedPreferences if present
      if (_prefs != null) {
        final jsonString = _prefs.getString(AppConstants.prefKeyFavorites);
        if (jsonString != null && jsonString.isNotEmpty) {
          try {
            final List<dynamic> decoded =
                jsonDecode(jsonString) as List<dynamic>;
            final list = decoded
                .map((item) =>
                    FavoritePairModel.fromJson(item as Map<String, dynamic>))
                .toList();
            for (final item in list) {
              await _box.put(item.id, item.toJson());
            }
            await _prefs.remove(AppConstants.prefKeyFavorites);
            return list;
          } catch (_) {}
        }
      }
      return [];
    }

    // Fallback if box is not passed
    if (_prefs != null) {
      final jsonString = _prefs.getString(AppConstants.prefKeyFavorites);
      if (jsonString == null) return [];
      try {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .map((item) =>
                FavoritePairModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> addFavorite(FavoritePairModel pair) async {
    if (_box != null && _box.isOpen) {
      await _box.put(pair.id, pair.toJson());
      return;
    }
    final current = await getFavorites();
    final updated = current.where((p) => p.id != pair.id).toList()..add(pair);
    await _saveAllPrefs(updated);
  }

  @override
  Future<void> removeFavorite(String id) async {
    if (_box != null && _box.isOpen) {
      await _box.delete(id);
      return;
    }
    final current = await getFavorites();
    final updated = current.where((p) => p.id != id).toList();
    await _saveAllPrefs(updated);
  }

  @override
  Future<bool> isFavorite(String id) async {
    if (_box != null && _box.isOpen) {
      return _box.containsKey(id);
    }
    final current = await getFavorites();
    return current.any((p) => p.id == id);
  }

  Future<void> _saveAllPrefs(List<FavoritePairModel> pairs) async {
    if (_prefs != null) {
      final jsonString = jsonEncode(pairs.map((p) => p.toJson()).toList());
      await _prefs.setString(AppConstants.prefKeyFavorites, jsonString);
    }
  }
}
