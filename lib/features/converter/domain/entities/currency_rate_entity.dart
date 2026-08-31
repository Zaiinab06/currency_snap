import 'package:equatable/equatable.dart';

/// Pure domain entity representing currency exchange rates.
class CurrencyRateEntity extends Equatable {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastUpdated;

  const CurrencyRateEntity({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  /// Convert [amount] from [baseCurrency] into [targetCurrency].
  /// Returns null if the target currency isn't in the rate table.
  double? convert({required String targetCurrency, required double amount}) {
    final rate = rates[targetCurrency];
    if (rate == null) return null;
    return amount * rate;
  }

  /// Converts [amount] from [fromCurrency] to [toCurrency], using the anchor base as a pivot.
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

  /// Derives dynamic [CurrencyPairRate] models for a list of base/quote pairs.
  /// Compares with [previousRates] when available to calculate real percentage changes;
  /// otherwise defaults cleanly to 0.0 without fake mock numbers.
  List<CurrencyPairRate> getPopularPairs(
    List<(String, String)> pairs, {
    CurrencyRateEntity? previousRates,
  }) {
    return pairs.map((pair) {
      final base = pair.$1;
      final quote = pair.$2;
      final rate = convertBetween(
            fromCurrency: base,
            toCurrency: quote,
            amount: 1.0,
          ) ??
          1.0;

      double percentChange = 0.0;
      if (previousRates != null) {
        final prevRate = previousRates.convertBetween(
          fromCurrency: base,
          toCurrency: quote,
          amount: 1.0,
        );
        if (prevRate != null && prevRate > 0) {
          percentChange = ((rate - prevRate) / prevRate) * 100.0;
        }
      }

      return CurrencyPairRate(
        baseCurrency: base,
        quoteCurrency: quote,
        rate: rate,
        percentChange: double.parse(percentChange.toStringAsFixed(2)),
      );
    }).toList();
  }

  @override
  List<Object?> get props => [baseCurrency, rates, lastUpdated];
}

/// Represents a dynamic currency pair with its computed rate and percent delta.
class CurrencyPairRate extends Equatable {
  final String baseCurrency;
  final String quoteCurrency;
  final double rate;
  final double percentChange;

  const CurrencyPairRate({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rate,
    required this.percentChange,
  });

  bool get isPositive => percentChange >= 0;

  @override
  List<Object?> get props => [baseCurrency, quoteCurrency, rate, percentChange];
}

/// Domain wrapper containing rate entity, previous rates, caching status, and sync timestamp.
class RateResultEntity extends Equatable {
  final CurrencyRateEntity rates;
  final CurrencyRateEntity? previousRates;
  final bool isFromCache;
  final DateTime syncTime;

  const RateResultEntity({
    required this.rates,
    this.previousRates,
    required this.isFromCache,
    required this.syncTime,
  });

  @override
  List<Object?> get props => [rates, previousRates, isFromCache, syncTime];
}
