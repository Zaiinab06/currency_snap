import 'package:equatable/equatable.dart';
import '../../domain/entities/historical_rate_point.dart';

/// Base state for Rates & Historical Analytics.
abstract class RatesState extends Equatable {
  const RatesState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized rates state.
class RatesInitial extends RatesState {}

/// Loading state while authentic time-series rates are fetched.
class RatesLoading extends RatesState {}

/// Single Source of Truth loaded state holding the authentic ratePoints list.
/// All metrics (current, high, low, average, percentChange) are derived exclusively from ratePoints.
class HistoricalRatesLoaded extends RatesState {
  final List<RatePoint> ratePoints; // sorted oldest -> newest
  final String fromCurrency;
  final String toCurrency;
  final String timeframe;
  final bool isCached;

  HistoricalRatesLoaded({
    List<RatePoint>? ratePoints,
    List<RatePoint>? rates,
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
    this.timeframe = '7D',
    this.isCached = false,
  }) : ratePoints = List.unmodifiable(
          List<RatePoint>.from(ratePoints ?? rates ?? const [])
            ..sort((a, b) => a.date.compareTo(b.date)),
        );

  /// Backwards-compatible alias for ratePoints list.
  List<RatePoint> get rates => ratePoints;

  /// Current rate: rate of the LAST chronological item in ratePoints.
  double get current => ratePoints.isNotEmpty ? ratePoints.last.rate : 0.0;

  /// Highest rate in the active time-series dataset.
  double get high => ratePoints.isNotEmpty
      ? ratePoints.map((p) => p.rate).reduce((a, b) => a > b ? a : b)
      : 0.0;

  /// Lowest rate in the active time-series dataset.
  double get low => ratePoints.isNotEmpty
      ? ratePoints.map((p) => p.rate).reduce((a, b) => a < b ? a : b)
      : 0.0;

  /// Average rate across the entire active time-series dataset.
  double get average => ratePoints.isNotEmpty
      ? ratePoints.map((p) => p.rate).reduce((a, b) => a + b) / ratePoints.length
      : 0.0;

  /// Percentage change from the first historical point to the current point.
  double get percentChange =>
      (ratePoints.length >= 2 && ratePoints.first.rate > 0)
          ? ((current - ratePoints.first.rate) / ratePoints.first.rate) * 100.0
          : 0.0;

  /// Rounded 2-decimal delta for UI display badges.
  double get delta => double.parse(percentChange.toStringAsFixed(2));

  /// Direction of percent change.
  bool get isPositive => percentChange >= 0;

  @override
  List<Object?> get props => [
        ratePoints,
        fromCurrency,
        toCurrency,
        timeframe,
        isCached,
      ];
}

/// Error state if authentic data fetching fails.
class RatesError extends RatesState {
  final String message;

  const RatesError(this.message);

  @override
  List<Object?> get props => [message];
}

typedef RatesLoadingState = RatesLoading;
typedef RatesErrorState = RatesError;
typedef RatesLoadedState = HistoricalRatesLoaded;
typedef RatesInitialState = RatesInitial;
