import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favorite_pair_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import 'favorites_state.dart';

/// Cubit managing the list of user-saved favorite currency pairs.
class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesUseCase _getFavoritesUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  FavoritesCubit(
    this._getFavoritesUseCase,
    this._toggleFavoriteUseCase,
  ) : super(FavoritesState.initial());

  /// Convenience factory from repository.
  factory FavoritesCubit.fromRepository(FavoritesRepository repository) {
    return FavoritesCubit(
      GetFavoritesUseCase(repository),
      ToggleFavoriteUseCase(repository),
    );
  }

  /// Loads all saved favorite currency pairs from storage.
  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    try {
      final favorites = await _getFavoritesUseCase();
      emit(
        state.copyWith(
          status: FavoritesStatus.success,
          favorites: favorites,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          errorMessage: 'Failed to load favorite pairs.',
        ),
      );
    }
  }

  /// Removes a favorite currency pair and reloads the updated list.
  Future<void> removeFavorite(FavoritePairEntity pair) async {
    try {
      await _toggleFavoriteUseCase.removeFavorite(pair.id);
      await loadFavorites();
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          errorMessage: 'Failed to remove favorite pair.',
        ),
      );
    }
  }

  /// Adds or updates a favorite currency pair and reloads the list.
  Future<void> addFavorite(FavoritePairEntity pair) async {
    try {
      await _toggleFavoriteUseCase.addFavorite(pair);
      await loadFavorites();
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          errorMessage: 'Failed to save favorite pair.',
        ),
      );
    }
  }

  /// Checks whether a currency pair is currently saved in favorites.
  bool isFavorite(String fromCurrency, String toCurrency) {
    return state.favorites.any(
      (pair) =>
          pair.fromCurrency.toUpperCase() == fromCurrency.toUpperCase() &&
          pair.toCurrency.toUpperCase() == toCurrency.toUpperCase(),
    );
  }

  /// Toggles favorite status for a given currency pair and returns the new status (true if added, false if removed).
  Future<bool> toggleFavorite(
    String fromCurrency,
    String toCurrency, {
    double rate = 1.0,
  }) async {
    final existingIndex = state.favorites.indexWhere(
      (pair) =>
          pair.fromCurrency.toUpperCase() == fromCurrency.toUpperCase() &&
          pair.toCurrency.toUpperCase() == toCurrency.toUpperCase(),
    );

    if (existingIndex >= 0) {
      final pair = state.favorites[existingIndex];
      await removeFavorite(pair);
      return false;
    } else {
      final newPair = FavoritePairEntity.create(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        rate: rate,
      );
      await addFavorite(newPair);
      return true;
    }
  }
}
