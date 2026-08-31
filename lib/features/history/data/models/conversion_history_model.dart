import '../../domain/entities/conversion_history_entity.dart';

/// Data model representing conversion history records, extending [ConversionHistoryEntity].
class ConversionHistoryModel extends ConversionHistoryEntity {
  const ConversionHistoryModel({
    required super.id,
    required super.fromCurrency,
    required super.toCurrency,
    required super.fromAmount,
    required super.toAmount,
    required super.rate,
    required super.timestamp,
  });

  /// Factory helper to create a record with auto-generated id and current timestamp.
  factory ConversionHistoryModel.create({
    required String fromCurrency,
    required String toCurrency,
    required double fromAmount,
    required double toAmount,
    required double rate,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    return ConversionHistoryModel(
      id: '${fromCurrency}_${toCurrency}_${now.millisecondsSinceEpoch}',
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      fromAmount: fromAmount,
      toAmount: toAmount,
      rate: rate,
      timestamp: now,
    );
  }

  /// Deserializes model from JSON map.
  factory ConversionHistoryModel.fromJson(Map<String, dynamic> json) {
    return ConversionHistoryModel(
      id: json['id'] as String? ?? '',
      fromCurrency: json['fromCurrency'] as String? ?? 'USD',
      toCurrency: json['toCurrency'] as String? ?? 'EUR',
      fromAmount: (json['fromAmount'] as num?)?.toDouble() ?? 0.0,
      toAmount: (json['toAmount'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts domain entity to data model.
  factory ConversionHistoryModel.fromEntity(ConversionHistoryEntity entity) {
    return ConversionHistoryModel(
      id: entity.id,
      fromCurrency: entity.fromCurrency,
      toCurrency: entity.toCurrency,
      fromAmount: entity.fromAmount,
      toAmount: entity.toAmount,
      rate: entity.rate,
      timestamp: entity.timestamp,
    );
  }

  /// Serializes model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'fromAmount': fromAmount,
      'toAmount': toAmount,
      'rate': rate,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
