import 'package:equatable/equatable.dart';

/// Pure domain entity representing an individual conversion history record.
class ConversionHistoryEntity extends Equatable {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double fromAmount;
  final double toAmount;
  final double rate;
  final DateTime timestamp;

  const ConversionHistoryEntity({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.rate,
    required this.timestamp,
  });

  /// Factory helper creating a domain record with generated id and current timestamp.
  factory ConversionHistoryEntity.create({
    required String fromCurrency,
    required String toCurrency,
    required double fromAmount,
    required double toAmount,
    required double rate,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    return ConversionHistoryEntity(
      id: '${fromCurrency}_${toCurrency}_${now.millisecondsSinceEpoch}',
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      fromAmount: fromAmount,
      toAmount: toAmount,
      rate: rate,
      timestamp: now,
    );
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
