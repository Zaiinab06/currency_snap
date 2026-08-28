import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/favorite_pair_model.dart';
import '../../data/repositories/currency_repository.dart';
import 'favorites_state.dart';

/// Cubit managing the list of user-saved favorite currency pairs.
class FavoritesCubit extends Cubit<FavoritesState> {
  final CurrencyRepository _repository;

  FavoritesCubit(this._repository) : super(FavoritesState.initial());

  /// Loads all saved favorite currency pairs from storage.
  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    try {
      final favorites = await _repository.getFavorites();
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
  Future<void> removeFavorite(FavoritePairModel pair) async {
    try {
      await _repository.removeFavorite(pair.id);
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
  Future<void> addFavorite(FavoritePairModel pair) async {
    try {
      await _repository.addFavorite(pair);
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
}
