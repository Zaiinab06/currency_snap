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
      lastUpdated: _parseApiTimestamp(json['time_last_update_unix']),
    );
  }

  /// The API gives a Unix timestamp (seconds) for when rates were last
  /// refreshed on their end — this is the real "last updated" time,
  /// not the moment this device happened to fetch it.
  static DateTime _parseApiTimestamp(dynamic unixSeconds) {
    if (unixSeconds is int) {
      return DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    }
    return DateTime.now();
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

  /// Converts [amount] from [fromCurrency] to [toCurrency], where both
  /// may be different from this model's [baseCurrency]. Uses the anchor
  /// base as a pivot (cross-rate), so a single fetched rate table can
  /// price ANY pair without a new API call per currency change.
  ///
  /// Formula: amount_in_base = amount / rate[fromCurrency]
  ///          result = amount_in_base * rate[toCurrency]
  double? convertBetween({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) {
    if (fromCurrency == toCurrency) return amount;

    final fromRate = fromCurrency == baseCurrency ? 1.0 : rates[fromCurrency];
    final toRate = toCurrency == baseCurrency ? 1.0 : rates[toCurrency];
    if (fromRate == null || toRate == null || fromRate == 0) return null;

    final amountInBase = amount / fromRate;
    return amountInBase * toRate;
  }

  @override
  List<Object?> get props => [baseCurrency, rates, lastUpdated];
}
