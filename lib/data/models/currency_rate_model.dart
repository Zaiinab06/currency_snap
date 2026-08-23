import 'package:equatable/equatable.dart';

/// Represents a set of exchange rates for a given base currency,
/// as returned by the API (or restored from local cache).
///
/// Example API shape (open.er-api.com):
/// {
///   "base_code": "USD",
///   "rates": { "EUR": 0.92, "GBP": 0.79, "PKR": 278.5, ... },
///   "time_last_update_utc": "..."
/// }
class CurrencyRateModel extends Equatable {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastUpdated;

  const CurrencyRateModel({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  /// Build from the raw API JSON response.
  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    return CurrencyRateModel(
      baseCurrency: json['base_code'] as String? ?? 'USD',
      rates: rawRates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      // API gives a formatted string; when parsing live, "now" is accurate.
      lastUpdated: DateTime.now(),
    );
  }

  /// Build from a locally cached JSON blob (has its own stored timestamp).
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

  /// Serialize for local caching (SharedPreferences, as a JSON string).
  Map<String, dynamic> toCacheJson() {
    return {
      'baseCurrency': baseCurrency,
      'rates': rates,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Convert [amount] from [baseCurrency] into [targetCurrency].
  /// Returns null if the target currency isn't in the rate table.
  double? convert({required String targetCurrency, required double amount}) {
    final rate = rates[targetCurrency];
    if (rate == null) return null;
    return amount * rate;
  }

  @override
  List<Object?> get props => [baseCurrency, rates, lastUpdated];
}
