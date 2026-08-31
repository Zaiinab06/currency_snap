import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_snap/features/converter/data/datasources/currency_cache_datasource.dart';
import 'package:currency_snap/features/converter/data/models/currency_rate_model.dart';
import 'package:currency_snap/features/converter/domain/entities/currency_rate_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrencyRateEntity Dynamic Math', () {
    final liveRates = CurrencyRateEntity(
      baseCurrency: 'USD',
      rates: const {
        'EUR': 0.90,
        'GBP': 0.80,
        'PKR': 280.0,
        'JPY': 150.0,
      },
      lastUpdated: DateTime(2026, 8, 31),
    );

    test('converts correctly between any pair using anchor base', () {
      // 100 EUR to GBP -> (100 / 0.90) * 0.80 = 88.888...
      final eurToGbp = liveRates.convertBetween(
        fromCurrency: 'EUR',
        toCurrency: 'GBP',
        amount: 100,
      );
      expect(eurToGbp, closeTo(88.888, 0.001));

      // Same currency conversion returns exact amount
      final usdToUsd = liveRates.convertBetween(
        fromCurrency: 'USD',
        toCurrency: 'USD',
        amount: 50,
      );
      expect(usdToUsd, 50.0);
    });

    test('getPopularPairs calculates real percent change when previousRates exists', () {
      final prevRates = CurrencyRateEntity(
        baseCurrency: 'USD',
        rates: const {
          'EUR': 0.88, // rate increased from 0.88 to 0.90 (+2.27%)
          'GBP': 0.80,
          'PKR': 280.0,
          'JPY': 150.0,
        },
        lastUpdated: DateTime(2026, 8, 30),
      );

      final popularPairs = liveRates.getPopularPairs(
        [('USD', 'EUR'), ('USD', 'GBP')],
        previousRates: prevRates,
      );

      expect(popularPairs.length, 2);
      expect(popularPairs[0].baseCurrency, 'USD');
      expect(popularPairs[0].quoteCurrency, 'EUR');
      expect(popularPairs[0].rate, 0.90);
      expect(popularPairs[0].percentChange, closeTo(2.27, 0.01));
      expect(popularPairs[0].isPositive, isTrue);

      expect(popularPairs[1].quoteCurrency, 'GBP');
      expect(popularPairs[1].percentChange, 0.0);
    });

    test('getPopularPairs cleanly defaults to 0.0% delta when no previousRates exists', () {
      final popularPairs = liveRates.getPopularPairs(
        [('USD', 'EUR'), ('USD', 'PKR')],
        previousRates: null,
      );

      expect(popularPairs[0].percentChange, 0.0);
      expect(popularPairs[1].percentChange, 0.0);
    });
  });

  group('CurrencyCacheDataSource Historical Snapshots', () {
    test('stores previous rates and appends historical snapshots on saveRates', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cacheSource = CurrencyCacheDataSourceImpl(prefs);

      final firstModel = CurrencyRateModel(
        baseCurrency: 'USD',
        rates: {'EUR': 0.90, 'GBP': 0.79},
        lastUpdated: DateTime(2026, 8, 30, 10, 0),
      );
      await cacheSource.saveRates(firstModel);

      expect(await cacheSource.getPreviousRates(), isNull);

      final secondModel = CurrencyRateModel(
        baseCurrency: 'USD',
        rates: {'EUR': 0.92, 'GBP': 0.80},
        lastUpdated: DateTime(2026, 8, 31, 10, 0),
      );
      await cacheSource.saveRates(secondModel);

      final prev = await cacheSource.getPreviousRates();
      expect(prev, isNotNull);
      expect(prev!.rates['EUR'], 0.90);

      final current = await cacheSource.getCachedRates();
      expect(current.rates['EUR'], 0.92);

      final points = cacheSource.getHistoricalPoints(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        timeframe: '7D',
        currentRate: 0.92,
      );
      expect(points.length, 7);
      expect(points.last, 0.92);
    });
  });
}
