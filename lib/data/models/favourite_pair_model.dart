import 'package:equatable/equatable.dart';

/// Represents a single saved currency pair in the Favorites screen,
/// e.g. USD -> PKR, with the rate captured at save/last-refresh time.
class FavoritePairModel extends Equatable {
  final String id; // stable id, e.g. "USD_PKR"
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime savedAt;

  const FavoritePairModel({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.savedAt,
  });

  /// Convenience constructor that derives a stable [id] from the pair.
  factory FavoritePairModel.create({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
  }) {
    return FavoritePairModel(
      id: '${fromCurrency}_$toCurrency',
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: rate,
      savedAt: DateTime.now(),
    );
  }

  factory FavoritePairModel.fromJson(Map<String, dynamic> json) {
    return FavoritePairModel(
      id: json['id'] as String,
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'rate': rate,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  /// Returns a copy with an updated rate (e.g. after a fresh fetch),
  /// keeping the original id/savedAt.
  FavoritePairModel copyWithRate(double newRate) {
    return FavoritePairModel(
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
