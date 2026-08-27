import 'package:equatable/equatable.dart';

/// Data model representing an individual conversion history record.
class ConversionHistoryModel extends Equatable {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double fromAmount;
  final double toAmount;
  final double rate;
  final DateTime timestamp;

  const ConversionHistoryModel({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.rate,
    required this.timestamp,
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

  @override
  List<Object?> get props => [
        id,
        fromCurrency,
        toCurrency,
        fromAmount,
        toAmount,
        rate,
        timestamp,
      ];
}
