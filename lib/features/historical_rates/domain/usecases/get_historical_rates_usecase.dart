import '../entities/historical_rate_point.dart';
import '../repositories/historical_rates_repository.dart';

/// Use case retrieving real time-series exchange rate history points.
class GetHistoricalRatesUseCase {
  final HistoricalRatesRepository _repository;

  const GetHistoricalRatesUseCase(this._repository);

  Future<List<HistoricalRatePoint>> call({
    required String fromCurrency,
    required String toCurrency,
    required String timeframe,
    double? currentRate,
  }) {
    return _repository.getHistoricalRates(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      timeframe: timeframe,
      currentRate: currentRate,
    );
  }
}
