import '../entities/favorite_pair_entity.dart';
import '../repositories/favorites_repository.dart';

/// Use case to toggle, add, or remove favorite currency pairs.
class ToggleFavoriteUseCase {
  final FavoritesRepository repository;

  const ToggleFavoriteUseCase(this.repository);

  Future<bool> call(FavoritePairEntity pair) async {
    final exists = await repository.isFavorite(pair.id);
    if (exists) {
      await repository.removeFavorite(pair.id);
      return false;
    } else {
      await repository.addFavorite(pair);
      return true;
    }
  }

  Future<void> addFavorite(FavoritePairEntity pair) {
    return repository.addFavorite(pair);
  }

  Future<void> removeFavorite(String id) {
    return repository.removeFavorite(id);
  }
}
