import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/historical_rate_point.dart';
import '../../domain/usecases/get_historical_rates_usecase.dart';
import 'rates_state.dart';

/// Cubit managing authentic historical rates state, connectivity auto-retry, and deriving all metrics strictly from one unified ratePoints list.
class RatesCubit extends Cubit<RatesState> {
  final GetHistoricalRatesUseCase _getHistoricalRatesUseCase;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  String? _lastFromCurrency;
  String? _lastToCurrency;
  String? _lastTimeframe;
  double? _lastCurrentRate;

  RatesCubit(
    this._getHistoricalRatesUseCase, {
    Connectivity? connectivity,
  })  : _connectivity = connectivity ?? Connectivity(),
        super(RatesInitial()) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    try {
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen((results) {
        final hasConnection =
            results.any((result) => result != ConnectivityResult.none);
        if (hasConnection &&
            state is RatesError &&
            _lastFromCurrency != null &&
            _lastToCurrency != null) {
          loadHistoricalRates(
            fromCurrency: _lastFromCurrency!,
            toCurrency: _lastToCurrency!,
            timeframe: _lastTimeframe ?? '7D',
            currentRate: _lastCurrentRate,
          );
        }
      });
    } catch (e) {
      debugPrint('Connectivity listener registration failed: $e');
    }
  }

  /// Alias for loadHistoricalRates matching event naming conventions
  Future<void> fetchHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required String timeframe,
    double? currentRate,
  }) =>
      loadHistoricalRates(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        timeframe: timeframe,
        currentRate: currentRate,
      );

  /// Positional helper for fetching historical rates
  Future<void> fetchHistoricalRatesForPair(
    String base,
    String target,
    String timeframe, [
    double? currentRate,
  ]) =>
      loadHistoricalRates(
        fromCurrency: base,
        toCurrency: target,
        timeframe: timeframe,
        currentRate: currentRate,
      );

  /// Retry fetching the last requested currency pair and timeframe, immediately emitting RatesLoading
  Future<void> retry() {
    emit(RatesLoading());
    return loadHistoricalRates(
      fromCurrency: _lastFromCurrency ?? 'USD',
      toCurrency: _lastToCurrency ?? 'PKR',
      timeframe: _lastTimeframe ?? '7D',
      currentRate: _lastCurrentRate,
    );
  }

  Future<void> loadHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required String timeframe,
    double? currentRate,
  }) async {
    _lastFromCurrency = fromCurrency;
    _lastToCurrency = toCurrency;
    _lastTimeframe = timeframe;
    _lastCurrentRate = currentRate;

    emit(RatesLoading());
    try {
      final rawPoints = await _getHistoricalRatesUseCase(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        timeframe: timeframe,
        currentRate: currentRate,
      );

      if (rawPoints.isEmpty) {
        emit(const RatesError(
          'Unable to load historical rates.\nPlease check your connection and try again.',
        ));
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
          isCached: points[lastIdx].isCached,
        );
      }

      final isCached = points.any((p) => p.isCached);

      emit(HistoricalRatesLoaded(
        ratePoints: points,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        timeframe: timeframe,
        isCached: isCached,
      ));
    } catch (e) {
      final rawMsg = e.toString();
      final cleanMsg = rawMsg
          .replaceFirst(RegExp(r'^[A-Za-z0-9_]*Exception:\s*'), '')
          .replaceFirst(RegExp(r'^NoCachedData[A-Za-z]*:?\s*'), '')
          .trim();
      emit(RatesError(
        cleanMsg.isNotEmpty &&
                !cleanMsg.startsWith('Instance of') &&
                !cleanMsg.contains('NoCachedData') &&
                !cleanMsg.contains('SocketException')
            ? cleanMsg
            : 'Unable to load historical rates.\nPlease check your connection and try again.',
      ));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
