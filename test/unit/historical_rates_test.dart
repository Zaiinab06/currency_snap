import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_snap/features/converter/data/datasources/currency_cache_datasource.dart';
import 'package:currency_snap/features/historical_rates/data/datasources/historical_rates_remote_datasource.dart';
import 'package:currency_snap/features/historical_rates/data/repositories/historical_rates_repository_impl.dart';
import 'package:currency_snap/features/historical_rates/domain/entities/historical_rate_point.dart';
import 'package:currency_snap/features/historical_rates/presentation/widgets/rate_chart_widget.dart';

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
    final sDate = DateTime(startDate.year, startDate.month, startDate.day);
    final eDate = DateTime(endDate.year, endDate.month, endDate.day);
    return dummyPoints.where((p) {
      final pDate = DateTime(p.date.year, p.date.month, p.date.day);
      return (pDate.isAtSameMomentAs(sDate) || pDate.isAfter(sDate)) &&
          (pDate.isAtSameMomentAs(eDate) || pDate.isBefore(eDate));
    }).toList();
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

    test('1M timeframe calculates start date as 30 days back and returns points spanning the full 30-day window', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cacheSource = CurrencyCacheDataSourceImpl(prefs);

      final now = DateTime.now();
      final monthPoints = List.generate(
        31,
        (i) => HistoricalRatePoint(
          date: DateTime(now.year, now.month, now.day).subtract(Duration(days: 30 - i)),
          rate: 1.05 + (i * 0.001),
        ),
      );

      final repository = HistoricalRatesRepositoryImpl(
        MockHistoricalRatesRemoteDataSource(dummyPoints: monthPoints),
        cacheSource,
      );

      final result = await repository.getHistoricalRates(
        fromCurrency: 'EUR',
        toCurrency: 'USD',
        timeframe: '1M',
        currentRate: 1.08,
      );

      expect(result.length, 31);
      final startDate = result.first.date;
      final expectedStartDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
      expect(startDate.year, expectedStartDate.year);
      expect(startDate.month, expectedStartDate.month);
      expect(startDate.day, expectedStartDate.day);
      expect(result.last.rate, 1.08);

      // Verify X-axis label indices calculation for 31 points
      final labelIndices = RateChartWidget.calculateVisibleLabelIndices(result.length);
      expect(labelIndices.length, 5);
      expect(labelIndices.contains(0), isTrue); // First point (e.g. 8/2)
      expect(labelIndices.contains(result.length - 1), isTrue); // Last point (e.g. 9/1)
    });

    test('verifies each timeframe (24H, 7D, 1M, 1Y) loads its respective full date span', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cacheSource = CurrencyCacheDataSourceImpl(prefs);

      final now = DateTime.now();
      // Generate comprehensive dataset for past 400 days
      final allPoints = List.generate(
        400,
        (i) => HistoricalRatePoint(
          date: DateTime(now.year, now.month, now.day).subtract(Duration(days: 399 - i)),
          rate: 100.0 + (i * 0.1),
        ),
      );

      final repository = HistoricalRatesRepositoryImpl(
        MockHistoricalRatesRemoteDataSource(dummyPoints: allPoints),
        cacheSource,
      );

      // 24H
      final h24 = await repository.getHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'JPY',
        timeframe: '24H',
      );
      expect(h24.length, 4);

      // 7D
      final d7 = await repository.getHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'JPY',
        timeframe: '7D',
      );
      expect(d7.length, 7);

      // 1M
      final m1 = await repository.getHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'JPY',
        timeframe: '1M',
      );
      expect(m1.length, 31);
      expect(m1.first.date.difference(DateTime(now.year, now.month, now.day)).inDays.abs(), 30);

      // 1Y
      final y1 = await repository.getHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'JPY',
        timeframe: '1Y',
      );
      expect(y1.length, 12);
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
