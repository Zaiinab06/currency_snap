import '../../domain/entities/favorite_pair_entity.dart';

/// Data model for favorite currency pairs, extending [FavoritePairEntity] with JSON serialization.
class FavoritePairModel extends FavoritePairEntity {
  const FavoritePairModel({
    required super.id,
    required super.fromCurrency,
    required super.toCurrency,
    required super.rate,
    required super.savedAt,
  });

  /// Factory constructor to create a new model.
  factory FavoritePairModel.create({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    DateTime? savedAt,
  }) {
    return FavoritePairModel(
      id: '${fromCurrency}_$toCurrency',
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: rate,
      savedAt: savedAt ?? DateTime.now(),
    );
  }

  /// Deserializes model from JSON.
  factory FavoritePairModel.fromJson(Map<String, dynamic> json) {
    return FavoritePairModel(
      id: json['id'] as String,
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  /// Converts a domain [FavoritePairEntity] to [FavoritePairModel].
  factory FavoritePairModel.fromEntity(FavoritePairEntity entity) {
    return FavoritePairModel(
      id: entity.id,
      fromCurrency: entity.fromCurrency,
      toCurrency: entity.toCurrency,
      rate: entity.rate,
      savedAt: entity.savedAt,
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

  @override
  FavoritePairModel copyWithRate(double newRate) {
    return FavoritePairModel(
      id: id,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: newRate,
      savedAt: savedAt,
    );
  }
}
