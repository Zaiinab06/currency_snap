import '../entities/historical_rate_point.dart';

/// Contract for fetching real time-series exchange rate history across multiple timeframes.
abstract class HistoricalRatesRepository {
  Future<List<HistoricalRatePoint>> getHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required String timeframe,
    double? currentRate,
  });
}
