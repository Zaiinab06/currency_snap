import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:currency_snap/core/utils/currency_formatter.dart';
import 'package:currency_snap/features/historical_rates/domain/entities/historical_rate_point.dart';
import 'package:currency_snap/features/historical_rates/domain/repositories/historical_rates_repository.dart';
import 'package:currency_snap/features/historical_rates/domain/usecases/get_historical_rates_usecase.dart';
import 'package:currency_snap/features/historical_rates/presentation/cubit/rates_cubit.dart';
import 'package:currency_snap/features/historical_rates/presentation/cubit/rates_state.dart';
import 'package:currency_snap/features/historical_rates/presentation/widgets/rate_chart_widget.dart';

class MockConnectivity implements Connectivity {
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  void emitConnectivity(List<ConnectivityResult> results) {
    _controller.add(results);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [ConnectivityResult.wifi];

  void dispose() {
    _controller.close();
  }
}

class MockHistoricalRatesRepository implements HistoricalRatesRepository {
  final List<HistoricalRatePoint> dummyPoints;
  bool shouldFail;

  MockHistoricalRatesRepository({
    this.dummyPoints = const [],
    this.shouldFail = false,
  });

  @override
  Future<List<HistoricalRatePoint>> getHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required String timeframe,
    double? currentRate,
  }) async {
    if (shouldFail) {
      throw Exception('API error');
    }
    return dummyPoints;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HistoricalRatesLoaded Single Source of Truth Architecture', () {
    test('accurately derives high, low, average, current, and percentChange from ratePoints', () {
      final now = DateTime.now();
      final rates = [
        RatePoint(date: now.subtract(const Duration(days: 6)), rate: 277.30),
        RatePoint(date: now.subtract(const Duration(days: 5)), rate: 277.50),
        RatePoint(date: now.subtract(const Duration(days: 4)), rate: 277.80),
        RatePoint(date: now.subtract(const Duration(days: 3)), rate: 277.40),
        RatePoint(date: now.subtract(const Duration(days: 2)), rate: 278.10),
        RatePoint(date: now.subtract(const Duration(days: 1)), rate: 277.90),
        RatePoint(date: now, rate: 278.25),
      ];

      final state = HistoricalRatesLoaded(
        ratePoints: rates,
        fromCurrency: 'USD',
        toCurrency: 'PKR',
        timeframe: '7D',
      );

      expect(state.high, 278.25);
      expect(state.low, 277.30);
      expect(state.average, closeTo(277.75, 0.01));
      expect(state.current, 278.25);
      expect(state.delta, closeTo(0.34, 0.01));
      expect(state.isPositive, isTrue);

      // Verify chart's last spot is strictly identical to state.current
      final spots = RateChartWidget.buildSpots(state.ratePoints);
      expect(spots.last.y, state.current);
      expect(spots.last.y, 278.25);
    });

    test('verifies data consistency across 5 diverse currency magnitudes (0.0034, 1.79, 64.9, 277.55, 1509.47)', () {
      final testCases = [
        // 1. Very small magnitude (< 0.01)
        (
          'USD',
          'VND',
          [0.0031, 0.0033, 0.0032, 0.0035, 0.0034],
          '0.0035',
          '0.0031',
          '0.0034',
        ),
        // 2. Small magnitude (< 10, e.g. USD/ANG)
        (
          'USD',
          'ANG',
          [1.7850, 1.7890, 1.7900, 1.7880, 1.7910],
          '1.7910',
          '1.7850',
          '1.7910',
        ),
        // 3. Medium magnitude (USD/AFN ~64-65)
        (
          'USD',
          'AFN',
          [64.50, 64.65, 64.78, 64.82, 64.90],
          '64.90',
          '64.50',
          '64.90',
        ),
        // 4. Standard magnitude (USD/PKR ~277)
        (
          'USD',
          'PKR',
          [277.30, 277.50, 277.80, 277.40, 277.55],
          '277.80',
          '277.30',
          '277.55',
        ),
        // 5. Very large magnitude (USD/ARS ~1509)
        (
          'USD',
          'ARS',
          [1500.20, 1505.40, 1514.53, 1508.10, 1509.47],
          '1,514.53',
          '1,500.20',
          '1,509.47',
        ),
      ];

      final now = DateTime.now();
      for (final tc in testCases) {
        final from = tc.$1;
        final to = tc.$2;
        final rawRates = tc.$3;
        final expectedHighFormatted = tc.$4;
        final expectedLowFormatted = tc.$5;
        final expectedCurrentFormatted = tc.$6;

        final ratePoints = rawRates.asMap().entries.map((e) {
          return RatePoint(
            date: now.subtract(Duration(days: rawRates.length - 1 - e.key)),
            rate: e.value,
            baseCurrency: from,
            targetCurrency: to,
          );
        }).toList();

        final state = HistoricalRatesLoaded(
          ratePoints: ratePoints,
          fromCurrency: from,
          toCurrency: to,
        );

        final spots = RateChartWidget.buildSpots(state.ratePoints);

        // Chart last spot y MUST equal state.current
        expect(spots.last.y, state.current);

        // Formatted values must be completely consistent
        expect(CurrencyFormatter.formatRateDynamic(state.high), expectedHighFormatted);
        expect(CurrencyFormatter.formatRateDynamic(state.low), expectedLowFormatted);
        expect(CurrencyFormatter.formatRateDynamic(state.current), expectedCurrentFormatted);
        expect(CurrencyFormatter.formatRateDynamic(spots.last.y), expectedCurrentFormatted);
      }
    });

    test('handles empty dataset safely with fallback metrics', () {
      final state = HistoricalRatesLoaded(
        ratePoints: const [],
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );

      expect(state.high, 0.0);
      expect(state.low, 0.0);
      expect(state.average, 0.0);
      expect(state.current, 0.0);
      expect(state.delta, 0.0);
      expect(state.isPositive, isTrue);
    });
  });

  group('RatesCubit', () {
    test('emits RatesLoading and HistoricalRatesLoaded merging live current rate', () async {
      final now = DateTime.now();
      final points = [
        HistoricalRatePoint(date: now.subtract(const Duration(days: 1)), rate: 0.90),
        HistoricalRatePoint(date: now, rate: 0.91),
      ];
      final repository = MockHistoricalRatesRepository(dummyPoints: points);
      final useCase = GetHistoricalRatesUseCase(repository);
      final cubit = RatesCubit(useCase);

      expect(cubit.state, isA<RatesInitial>());

      final future = cubit.loadHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        timeframe: '7D',
        currentRate: 0.92, // live rate
      );

      await future;

      expect(cubit.state, isA<HistoricalRatesLoaded>());
      final loaded = cubit.state as HistoricalRatesLoaded;
      expect(loaded.ratePoints.length, 2);
      expect(loaded.high, 0.92);
      expect(loaded.low, 0.90);
      expect(loaded.current, 0.92);

      // Verify chart spot y equals loaded.current
      final spots = RateChartWidget.buildSpots(loaded.ratePoints);
      expect(spots.last.y, loaded.current);
    });

    test('emits RatesLoading and RatesError on repository failure', () async {
      final repository = MockHistoricalRatesRepository(shouldFail: true);
      final useCase = GetHistoricalRatesUseCase(repository);
      final cubit = RatesCubit(useCase);

      await cubit.loadHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        timeframe: '7D',
      );

      expect(cubit.state, isA<RatesError>());
      final error = cubit.state as RatesError;
      expect(error.message, contains('API error'));
    });

    test('automatically retries fetching historical rates when connectivity is restored', () async {
      final now = DateTime.now();
      final points = [
        HistoricalRatePoint(date: now.subtract(const Duration(days: 1)), rate: 0.90),
        HistoricalRatePoint(date: now, rate: 0.91),
      ];
      final mockConnectivity = MockConnectivity();
      final repository = MockHistoricalRatesRepository(
        dummyPoints: points,
        shouldFail: true,
      );
      final useCase = GetHistoricalRatesUseCase(repository);
      final cubit = RatesCubit(useCase, connectivity: mockConnectivity);

      // 1. Initial attempt fails
      await cubit.loadHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        timeframe: '7D',
      );
      expect(cubit.state, isA<RatesError>());

      // 2. Fix repository failure and restore connectivity
      repository.shouldFail = false;
      mockConnectivity.emitConnectivity([ConnectivityResult.wifi]);

      // Allow microtask / event loop to process
      await pumpEventQueue();

      expect(cubit.state, isA<HistoricalRatesLoaded>());
      final loaded = cubit.state as HistoricalRatesLoaded;
      expect(loaded.ratePoints.length, 2);
      expect(loaded.fromCurrency, 'USD');
      expect(loaded.toCurrency, 'EUR');

      await cubit.close();
      mockConnectivity.dispose();
    });

    test('retry method immediately emits RatesLoading and re-fetches historical rates', () async {
      final now = DateTime.now();
      final points = [
        HistoricalRatePoint(date: now.subtract(const Duration(days: 1)), rate: 0.90),
        HistoricalRatePoint(date: now, rate: 0.91),
      ];
      final repository = MockHistoricalRatesRepository(
        dummyPoints: points,
        shouldFail: true,
      );
      final useCase = GetHistoricalRatesUseCase(repository);
      final cubit = RatesCubit(useCase);

      // Initial attempt fails
      await cubit.loadHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        timeframe: '7D',
      );
      expect(cubit.state, isA<RatesError>());

      // Fix failure and call retry
      repository.shouldFail = false;
      final retryFuture = cubit.retry();
      // Should immediately be in loading state
      expect(cubit.state, isA<RatesLoading>());

      await retryFuture;
      expect(cubit.state, isA<HistoricalRatesLoaded>());
      final loaded = cubit.state as HistoricalRatesLoaded;
      expect(loaded.ratePoints.length, 2);

      await cubit.close();
    });
  });
}
