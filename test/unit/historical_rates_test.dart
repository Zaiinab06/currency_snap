import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_snap/features/converter/data/datasources/currency_cache_datasource.dart';
import 'package:currency_snap/features/historical_rates/data/datasources/historical_rates_remote_datasource.dart';
import 'package:currency_snap/features/historical_rates/data/repositories/historical_rates_repository_impl.dart';
import 'package:currency_snap/features/historical_rates/domain/entities/historical_rate_point.dart';

class MockHistoricalRatesRemoteDataSource
    implements HistoricalRatesRemoteDataSource {
  final bool shouldFail;
  final List<HistoricalRatePoint> dummyPoints;

  MockHistoricalRatesRemoteDataSource({
    this.shouldFail = false,
    this.dummyPoints = const [],
  });

  @override
  Future<List<HistoricalRatePoint>> getTimeSeriesRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (shouldFail) {
      throw Exception('Remote API Failure');
    }
    return dummyPoints;
  }

  @override
  Future<HistoricalRatePoint> getRateForDate({
    required String fromCurrency,
    required String toCurrency,
    required DateTime date,
  }) async {
    if (shouldFail) throw Exception('Remote API Failure');
    final match = dummyPoints.cast<HistoricalRatePoint?>().firstWhere(
          (p) =>
              p?.date.year == date.year &&
              p?.date.month == date.month &&
              p?.date.day == date.day,
          orElse: () => null,
        );
    if (match != null) return match;
    throw Exception('No data for $date');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoricalRatesRepositoryImpl', () {
    test('returns remote time-series points when remote API succeeds', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cacheSource = CurrencyCacheDataSourceImpl(prefs);

      final now = DateTime.now();
      final remotePoints = List.generate(
        7,
        (i) => HistoricalRatePoint(
          date: now.subtract(Duration(days: 6 - i)),
          rate: 0.90 + (i * 0.005),
        ),
      );

      final repository = HistoricalRatesRepositoryImpl(
        MockHistoricalRatesRemoteDataSource(dummyPoints: remotePoints),
        cacheSource,
      );

      final result = await repository.getHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        timeframe: '7D',
        currentRate: 0.93,
      );

      expect(result.length, 7);
      expect(result.first.rate, 0.90);
      expect(result.last.rate, 0.93);
    });

    test('authentically handles USD/PKR 7D points with exact metrics calculation', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cacheSource = CurrencyCacheDataSourceImpl(prefs);

      final now = DateTime.now();
      final pkrPoints = [
        HistoricalRatePoint(date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)), rate: 277.50),
        HistoricalRatePoint(date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 5)), rate: 277.65),
        HistoricalRatePoint(date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 4)), rate: 277.80),
        HistoricalRatePoint(date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 3)), rate: 277.75),
        HistoricalRatePoint(date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 2)), rate: 277.90),
        HistoricalRatePoint(date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)), rate: 278.10),
        HistoricalRatePoint(date: DateTime(now.year, now.month, now.day), rate: 278.25),
      ];

      final repository = HistoricalRatesRepositoryImpl(
        MockHistoricalRatesRemoteDataSource(dummyPoints: pkrPoints),
        cacheSource,
      );

      final result = await repository.getHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'PKR',
        timeframe: '7D',
        currentRate: 278.25,
      );

      expect(result.length, 7);
      final rates = result.map((e) => e.rate).toList();
      final high = rates.reduce((a, b) => a > b ? a : b);
      final low = rates.reduce((a, b) => a < b ? a : b);
      final avg = rates.reduce((a, b) => a + b) / rates.length;
      final current = rates.last;

      expect(high, 278.25);
      expect(low, 277.50);
      expect(avg, closeTo(277.85, 0.01));
      expect(current, 278.25);
    });

    test('throws exception without synthetic fallback when remote API fails and cache is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cacheSource = CurrencyCacheDataSourceImpl(prefs);

      final repository = HistoricalRatesRepositoryImpl(
        MockHistoricalRatesRemoteDataSource(shouldFail: true),
        cacheSource,
      );

      expect(
        () => repository.getHistoricalRates(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          timeframe: '7D',
          currentRate: 0.92,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
