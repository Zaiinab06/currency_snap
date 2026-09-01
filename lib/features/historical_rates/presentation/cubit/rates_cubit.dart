import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/historical_rate_point.dart';
import '../../domain/usecases/get_historical_rates_usecase.dart';
import 'rates_state.dart';

/// Cubit managing authentic historical rates state and deriving all metrics strictly from one unified ratePoints list.
class RatesCubit extends Cubit<RatesState> {
  final GetHistoricalRatesUseCase _getHistoricalRatesUseCase;

  RatesCubit(this._getHistoricalRatesUseCase) : super(RatesInitial());

  Future<void> loadHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required String timeframe,
    double? currentRate,
  }) async {
    emit(RatesLoading());
    try {
      final rawPoints = await _getHistoricalRatesUseCase(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        timeframe: timeframe,
        currentRate: currentRate,
      );

      if (rawPoints.isEmpty) {
        emit(const RatesError('No historical rates available.'));
        return;
      }

      final List<RatePoint> points = List<RatePoint>.from(rawPoints)
        ..sort((a, b) => a.date.compareTo(b.date));

      // Merge the live current rate directly into the final element of ratePoints
      if (currentRate != null &&
          currentRate.isFinite &&
          !currentRate.isNaN &&
          currentRate > 0 &&
          points.isNotEmpty) {
        final lastIdx = points.length - 1;
        points[lastIdx] = RatePoint(
          date: points[lastIdx].date,
          rate: currentRate,
          baseCurrency: fromCurrency,
          targetCurrency: toCurrency,
        );
      }

      emit(HistoricalRatesLoaded(
        ratePoints: points,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        timeframe: timeframe,
      ));
    } catch (e) {
      emit(RatesError(e.toString()));
    }
  }
}
