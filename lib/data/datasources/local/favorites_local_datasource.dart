import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/favourite_pair_model.dart';
import '../../../core/constants/app_constants.dart';

/// Local data source responsible for persisting and managing favorite currency pairs.
class FavoritesLocalDataSource {
  final SharedPreferences _prefs;

  FavoritesLocalDataSource(this._prefs);

  /// Retrieves all saved favorite pairs.
  Future<List<FavoritePairModel>> getFavorites() async {
    final jsonString = _prefs.getString(AppConstants.prefKeyFavorites);
    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => FavoritePairModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Saves or updates a favorite currency pair.
  Future<void> addFavorite(FavoritePairModel pair) async {
    final current = await getFavorites();
    final updated = current.where((p) => p.id != pair.id).toList()..add(pair);
    await _saveAll(updated);
  }

  /// Removes the favorite pair identified by [id].
  Future<void> removeFavorite(String id) async {
    final current = await getFavorites();
    final updated = current.where((p) => p.id != id).toList();
    await _saveAll(updated);
  }

  /// Checks whether a currency pair identified by [id] is marked as favorite.
  Future<bool> isFavorite(String id) async {
    final current = await getFavorites();
    return current.any((p) => p.id == id);
  }

  Future<void> _saveAll(List<FavoritePairModel> pairs) async {
    final jsonString = jsonEncode(pairs.map((p) => p.toJson()).toList());
    await _prefs.setString(AppConstants.prefKeyFavorites, jsonString);
  }
}
