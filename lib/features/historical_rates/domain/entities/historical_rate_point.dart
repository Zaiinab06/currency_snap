import 'package:equatable/equatable.dart';

/// Pure domain entity representing a single historical exchange rate point in time.
class RatePoint extends Equatable {
  final DateTime date;
  final double rate;
  final String baseCurrency;
  final String targetCurrency;

  const RatePoint({
    required this.date,
    required this.rate,
    this.baseCurrency = 'USD',
    this.targetCurrency = 'EUR',
  });

  /// Formatted short date for X-axis chart labels (e.g. "8/25", "8/26").
  String get formattedShortDate => '${date.month}/${date.day}';

  /// Formatted timestamp for interactive tooltip headers.
  String get formattedTimestamp => '${date.month}/${date.day}';

  @override
  List<Object?> get props => [date, rate, baseCurrency, targetCurrency];
}

/// Domain aliases for clean naming and backwards compatibility.
typedef HistoricalRatePoint = RatePoint;
typedef HistoricalRateEntity = RatePoint;
