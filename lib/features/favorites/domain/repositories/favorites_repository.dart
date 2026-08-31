import '../entities/favorite_pair_entity.dart';

/// Abstract domain contract for favorite currency pair operations.
abstract class FavoritesRepository {
  Future<List<FavoritePairEntity>> getFavorites();
  Future<void> addFavorite(FavoritePairEntity pair);
  Future<void> removeFavorite(String id);
  Future<bool> isFavorite(String id);
}
