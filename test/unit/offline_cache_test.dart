import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_snap/core/errors/app_exceptions.dart';
import 'package:currency_snap/features/converter/data/datasources/currency_cache_datasource.dart';
import 'package:currency_snap/features/converter/data/datasources/currency_remote_datasource.dart';
import 'package:currency_snap/features/converter/data/models/currency_rate_model.dart';
import 'package:currency_snap/features/converter/data/repositories/converter_repository_impl.dart';
import 'package:currency_snap/features/historical_rates/data/datasources/historical_rates_remote_datasource.dart';
import 'package:currency_snap/features/historical_rates/data/repositories/historical_rates_repository_impl.dart';
import 'package:currency_snap/features/historical_rates/domain/entities/historical_rate_point.dart';

class MockFailingConverterRemoteDataSource
    implements CurrencyRemoteDataSource {
  @override
  Future<CurrencyRateModel> getLatestRates(String baseCurrency) async {
    throw const NetworkException('No internet connection.');
  }

  @override
  Future<CurrencyRateModel?> getHistoricalBaselineRates(
    String baseCurrency, {
    DateTime? date,
  }) async {
    throw const NetworkException('No internet connection.');
  }
}

class MockFailingHistoricalRemoteDataSource
    implements HistoricalRatesRemoteDataSource {
  @override
  Future<List<HistoricalRatePoint>> getTimeSeriesRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    throw const NetworkException('No internet connection.');
  }

  @override
  Future<HistoricalRatePoint> getRateForDate({
    required String fromCurrency,
    required String toCurrency,
    required DateTime date,
  }) async {
    throw const NetworkException('No internet connection.');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Authentic Rate Functionality', () {
    test('ConverterRepository falls back to authentic cached rates when offline',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cacheDataSource = CurrencyCacheDataSourceImpl(prefs);

      // Pre-cache authentic rates from a previous online sync session
      final syncTime = DateTime(2026, 8, 31, 15, 30);
      final authenticModel = CurrencyRateModel(
        baseCurrency: 'USD',
        rates: {
          'EUR': 0.915,
          'GBP': 0.772,
          'PKR': 278.40,
          'JPY': 148.50,
        },
        lastUpdated: syncTime,
      );
      await cacheDataSource.saveRates(authenticModel, syncTime: syncTime);

      final repository = ConverterRepositoryImpl(
        MockFailingConverterRemoteDataSource(),
        cacheDataSource,
      );

      final result = await repository.getRates('USD');

      expect(result.isFromCache, isTrue);
      expect(result.rates.rates['PKR'], 278.40);
      expect(result.rates.rates['EUR'], 0.915);
      expect(result.syncTime, syncTime);

      // Offline cross-currency conversion check: 100 EUR to PKR
      final eurToPkr = result.rates.convertBetween(
        fromCurrency: 'EUR',
        toCurrency: 'PKR',
        amount: 100,
      );
      // (100 / 0.915) * 278.40 = 30426.2295
      expect(eurToPkr, closeTo(30426.22, 0.05));
    });

    test('HistoricalRatesRepository retrieves authentic cached date points when offline',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cacheDataSource = CurrencyCacheDataSourceImpl(prefs);

      final now = DateTime.now();
      final dates = List.generate(
        7,
        (i) => DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - i)),
      );

      final authenticRates = [277.50, 277.60, 277.80, 277.95, 278.10, 278.25, 278.40];

      // Pre-cache individual authentic date keys (USD_PKR_YYYY_MM_DD)
      for (int i = 0; i < 7; i++) {
        await cacheDataSource.saveDatePoint(
          fromCurrency: 'USD',
          toCurrency: 'PKR',
          date: dates[i],
          rate: authenticRates[i],
        );
      }

      final repository = HistoricalRatesRepositoryImpl(
        MockFailingHistoricalRemoteDataSource(),
        cacheDataSource,
      );

      final offlinePoints = await repository.getHistoricalRates(
        fromCurrency: 'USD',
        toCurrency: 'PKR',
        timeframe: '7D',
        currentRate: 278.40,
      );

      expect(offlinePoints.length, 7);
      expect(offlinePoints.first.rate, 277.50);
      expect(offlinePoints.last.rate, 278.40);

      // Verify market metrics derived purely from offline dataset
      final rates = offlinePoints.map((e) => e.rate).toList();
      final high = rates.reduce((a, b) => a > b ? a : b);
      final low = rates.reduce((a, b) => a < b ? a : b);
      final avg = rates.reduce((a, b) => a + b) / rates.length;

      expect(high, 278.40);
      expect(low, 277.50);
      expect(avg, closeTo(277.94, 0.05));
    });
  });
}
