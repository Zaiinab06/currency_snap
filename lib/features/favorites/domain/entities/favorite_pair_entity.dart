import 'package:equatable/equatable.dart';

/// Pure domain entity representing a user-saved favorite currency pair.
class FavoritePairEntity extends Equatable {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime savedAt;

  const FavoritePairEntity({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.savedAt,
  });

  /// Factory helper generating identifier from currencies.
  factory FavoritePairEntity.create({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    DateTime? savedAt,
  }) {
    return FavoritePairEntity(
      id: '${fromCurrency}_$toCurrency',
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: rate,
      savedAt: savedAt ?? DateTime.now(),
    );
  }

  /// Returns a copy of this pair with an updated exchange [newRate].
  FavoritePairEntity copyWithRate(double newRate) {
    return FavoritePairEntity(
      id: id,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: newRate,
      savedAt: savedAt,
    );
  }

  @override
  List<Object?> get props => [id, fromCurrency, toCurrency, rate, savedAt];
}
