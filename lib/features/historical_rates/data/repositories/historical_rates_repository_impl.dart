import 'package:flutter/foundation.dart';
import '../../../converter/data/datasources/currency_cache_datasource.dart';
import '../../domain/entities/historical_rate_point.dart';
import '../../domain/repositories/historical_rates_repository.dart';
import '../datasources/historical_rates_remote_datasource.dart';

/// Implementation coordinating real multi-date API queries and aligning the latest chronological point with live current rate.
class HistoricalRatesRepositoryImpl implements HistoricalRatesRepository {
  final HistoricalRatesRemoteDataSource _remoteDataSource;
  final CurrencyCacheDataSource _cacheDataSource;

  HistoricalRatesRepositoryImpl(
    this._remoteDataSource,
    this._cacheDataSource,
  );

  @override
  Future<List<HistoricalRatePoint>> getHistoricalRates({
    required String fromCurrency,
    required String toCurrency,
    required String timeframe,
    double? currentRate,
  }) async {
    final now = DateTime.now();

    final List<DateTime> targetDates = switch (timeframe) {
      '24H' => [
          now.subtract(const Duration(days: 3)),
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 1)),
          now,
        ],
      '7D' => List.generate(
          7,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 6 - i)),
        ),
      '1M' => List.generate(
          6,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: (5 - i) * 6)),
        ),
      '1Y' => List.generate(
          7,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: (6 - i) * 52)),
        ),
      _ => List.generate(
          7,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 6 - i)),
        ),
    };

    final List<HistoricalRatePoint> resultPoints = [];

    for (final date in targetDates) {
      // 1. Check unique date-level cache key (e.g. USD_PKR_2026_08_25)
      final cachedRate = _cacheDataSource.getCachedDatePoint(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        date: date,
      );

      if (cachedRate != null &&
          cachedRate.isFinite &&
          !cachedRate.isNaN &&
          cachedRate > 0) {
        resultPoints.add(HistoricalRatePoint(
          date: date,
          rate: cachedRate,
          baseCurrency: fromCurrency,
          targetCurrency: toCurrency,
        ));
        continue;
      }

      // 2. Fetch authentic rate for this specific date
      try {
        final remotePoint = await _remoteDataSource.getRateForDate(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          date: date,
        );

        if (remotePoint.rate.isFinite &&
            !remotePoint.rate.isNaN &&
            remotePoint.rate > 0) {
          final pointWithCurrencies = HistoricalRatePoint(
            date: remotePoint.date,
            rate: remotePoint.rate,
            baseCurrency: fromCurrency,
            targetCurrency: toCurrency,
          );
          resultPoints.add(pointWithCurrencies);
          await _cacheDataSource.saveDatePoint(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            date: date,
            rate: remotePoint.rate,
          );
        }
      } catch (e) {
        debugPrint('Unable to fetch rate for date $date: $e');
      }
    }

    if (resultPoints.isEmpty) {
      throw Exception(
        'Failed to load authentic historical data for $fromCurrency/$toCurrency ($timeframe)',
      );
    }

    // Sort chronologically
    resultPoints.sort((a, b) => a.date.compareTo(b.date));

    // Deduplicate matching calendar dates
    final Map<String, HistoricalRatePoint> uniqueByDate = {};
    for (final p in resultPoints) {
      uniqueByDate[_formatDate(p.date)] = p;
    }

    final validatedList = uniqueByDate.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Guarantee 100% synchronicity: align the latest point with the live current rate
    if (currentRate != null &&
        currentRate.isFinite &&
        !currentRate.isNaN &&
        currentRate > 0 &&
        validatedList.isNotEmpty) {
      final lastIndex = validatedList.length - 1;
      final lastPoint = validatedList[lastIndex];
      validatedList[lastIndex] = HistoricalRatePoint(
        date: lastPoint.date,
        rate: currentRate,
        baseCurrency: fromCurrency,
        targetCurrency: toCurrency,
      );
    }

    return validatedList;
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
