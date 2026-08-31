import '../entities/favorite_pair_entity.dart';
import '../repositories/favorites_repository.dart';

/// Use case to retrieve all saved favorite currency pairs.
class GetFavoritesUseCase {
  final FavoritesRepository repository;

  const GetFavoritesUseCase(this.repository);

  Future<List<FavoritePairEntity>> call() {
    return repository.getFavorites();
  }
}
