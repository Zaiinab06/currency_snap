import 'package:equatable/equatable.dart';

/// Data model representing currency exchange rates for a base currency.
class CurrencyRateModel extends Equatable {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastUpdated;

  const CurrencyRateModel({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  /// Creates a [CurrencyRateModel] from API response JSON.
  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    return CurrencyRateModel(
      baseCurrency: json['base_code'] as String? ?? 'USD',
      rates: rawRates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      lastUpdated: DateTime.now(),
    );
  }

  /// Creates a [CurrencyRateModel] from cached local JSON.
  factory CurrencyRateModel.fromCacheJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    return CurrencyRateModel(
      baseCurrency: json['baseCurrency'] as String? ?? 'USD',
      rates: rawRates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Serializes the model into a JSON-compatible map for caching.
  Map<String, dynamic> toCacheJson() {
    return {
      'baseCurrency': baseCurrency,
      'rates': rates,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Converts [amount] from [baseCurrency] to [targetCurrency].
  ///
  /// Returns null if [targetCurrency] is not available in the rates table.
  double? convert({required String targetCurrency, required double amount}) {
    final rate = rates[targetCurrency];
    if (rate == null) return null;
    return amount * rate;
  }

  @override
  List<Object?> get props => [baseCurrency, rates, lastUpdated];
}
