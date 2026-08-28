import 'package:equatable/equatable.dart';

/// Data model representing a saved favorite currency pair.
class FavoritePairModel extends Equatable {
  final String id;
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

  /// Creates a [FavoritePairModel] generating an identifier from currencies.
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

  /// Deserializes a [FavoritePairModel] from JSON.
  factory FavoritePairModel.fromJson(Map<String, dynamic> json) {
    return FavoritePairModel(
      id: json['id'] as String,
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  /// Serializes the model into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'rate': rate,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  /// Returns a copy of this pair with an updated exchange [newRate].
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
