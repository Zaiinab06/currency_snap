import 'package:equatable/equatable.dart';
import '../../data/models/favorite_pair_model.dart';

/// Status representing the lifecycle of favorites loading and operations.
enum FavoritesStatus { initial, loading, success, failure }

/// State representing the saved favorite currency pairs.
class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<FavoritePairModel> favorites;
  final String? errorMessage;

  const FavoritesState({
    required this.status,
    required this.favorites,
    this.errorMessage,
  });

  /// Initial state before any favorites are loaded.
  factory FavoritesState.initial() {
    return const FavoritesState(
      status: FavoritesStatus.initial,
      favorites: [],
      errorMessage: null,
    );
  }

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoritePairModel>? favorites,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, favorites, errorMessage];
}
