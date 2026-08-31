import '../../domain/entities/favorite_pair_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../models/favorite_pair_model.dart';

/// Implementation of [FavoritesRepository] mapping between domain entities and data models.
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _localDataSource;

  FavoritesRepositoryImpl(this._localDataSource);

  @override
  Future<List<FavoritePairEntity>> getFavorites() async {
    final models = await _localDataSource.getFavorites();
    return models;
  }

  @override
  Future<void> addFavorite(FavoritePairEntity pair) async {
    final model = pair is FavoritePairModel
        ? pair
        : FavoritePairModel.fromEntity(pair);
    await _localDataSource.addFavorite(model);
  }

  @override
  Future<void> removeFavorite(String id) {
    return _localDataSource.removeFavorite(id);
  }

  @override
  Future<bool> isFavorite(String id) {
    return _localDataSource.isFavorite(id);
  }
}
