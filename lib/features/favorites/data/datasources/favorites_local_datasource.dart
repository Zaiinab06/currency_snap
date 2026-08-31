import 'dart:convert';
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

/// Local data source responsible for persisting and managing favorite currency pairs.
class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences _prefs;

  FavoritesLocalDataSourceImpl(this._prefs);

  @override
  Future<List<FavoritePairModel>> getFavorites() async {
    final jsonString = _prefs.getString(AppConstants.prefKeyFavorites);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => FavoritePairModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addFavorite(FavoritePairModel pair) async {
    final current = await getFavorites();
    final updated = current.where((p) => p.id != pair.id).toList()..add(pair);
    await _saveAll(updated);
  }

  @override
  Future<void> removeFavorite(String id) async {
    final current = await getFavorites();
    final updated = current.where((p) => p.id != id).toList();
    await _saveAll(updated);
  }

  @override
  Future<bool> isFavorite(String id) async {
    final current = await getFavorites();
    return current.any((p) => p.id == id);
  }

  Future<void> _saveAll(List<FavoritePairModel> pairs) async {
    final jsonString = jsonEncode(pairs.map((p) => p.toJson()).toList());
    await _prefs.setString(AppConstants.prefKeyFavorites, jsonString);
  }
}
