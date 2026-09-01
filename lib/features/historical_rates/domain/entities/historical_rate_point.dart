import 'package:equatable/equatable.dart';

/// Pure domain entity representing a single historical exchange rate point in time.
class RatePoint extends Equatable {
  final DateTime date;
  final double rate;
  final String baseCurrency;
  final String targetCurrency;
  final bool isCached;

  const RatePoint({
    required this.date,
    required this.rate,
    this.baseCurrency = 'USD',
    this.targetCurrency = 'EUR',
    this.isCached = false,
  });

  /// Formatted short date for X-axis chart labels (e.g. "8/25", "8/26").
  String get formattedShortDate => '${date.month}/${date.day}';

  /// Formatted timestamp for interactive tooltip headers.
  String get formattedTimestamp => '${date.month}/${date.day}';

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'rate': rate,
        'baseCurrency': baseCurrency,
        'targetCurrency': targetCurrency,
        'isCached': isCached,
      };

  factory RatePoint.fromJson(Map<String, dynamic> json) => RatePoint(
        date: DateTime.parse(json['date'] as String),
        rate: (json['rate'] as num).toDouble(),
        baseCurrency: json['baseCurrency'] as String? ?? 'USD',
        targetCurrency: json['targetCurrency'] as String? ?? 'EUR',
        isCached: json['isCached'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [date, rate, baseCurrency, targetCurrency, isCached];
}

/// Domain aliases for clean naming and backwards compatibility.
typedef HistoricalRatePoint = RatePoint;
typedef HistoricalRateEntity = RatePoint;
