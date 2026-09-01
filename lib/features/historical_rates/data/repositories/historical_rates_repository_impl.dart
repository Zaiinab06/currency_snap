import 'package:flutter/foundation.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../converter/data/datasources/currency_cache_datasource.dart';
import '../../domain/entities/historical_rate_point.dart';
import '../../domain/repositories/historical_rates_repository.dart';
import '../datasources/historical_rates_remote_datasource.dart';

/// Implementation coordinating real multi-date API queries, local caching fallback, and aligning the latest chronological point with live current rate.
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
          31,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 30 - i)),
        ),
      '1Y' => List.generate(
          12,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: (11 - i) * 30)),
        ),
      _ => List.generate(
          7,
          (i) => DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 6 - i)),
        ),
    };

    final List<HistoricalRatePoint> resultPoints = [];
    bool remoteFailed = false;

    // 1. Genuine remote API query for authentic time-series rates
    try {
      final startDate = targetDates.first;
      final endDate = targetDates.last;

      if (timeframe == '1M' || timeframe == '7D') {
        final remoteSeries = await _remoteDataSource.getTimeSeriesRates(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          startDate: startDate,
          endDate: endDate,
        );

        for (final point in remoteSeries) {
          if (point.rate.isFinite && !point.rate.isNaN && point.rate > 0) {
            resultPoints.add(point);
            await _cacheDataSource.saveDatePoint(
              fromCurrency: fromCurrency,
              toCurrency: toCurrency,
              date: point.date,
              rate: point.rate,
            );
          }
        }
      } else {
        // Query specific dates (24H and 1Y)
        for (final date in targetDates) {
          try {
            final remotePoint = await _remoteDataSource.getRateForDate(
              fromCurrency: fromCurrency,
              toCurrency: toCurrency,
              date: date,
            );

            if (remotePoint.rate.isFinite &&
                !remotePoint.rate.isNaN &&
                remotePoint.rate > 0) {
              resultPoints.add(remotePoint);
              await _cacheDataSource.saveDatePoint(
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
                date: date,
                rate: remotePoint.rate,
              );
            }
          } catch (_) {
            remoteFailed = true;
          }
        }
      }
    } catch (e) {
      remoteFailed = true;
      debugPrint('Remote historical API failed: $e');
    }

    // 2. Offline-First Fallback: load authentic cached historical series for ${base}_${target}_${timeframe}
    if (resultPoints.isEmpty || (remoteFailed && resultPoints.length < targetDates.length)) {
      final cachedSeries = _cacheDataSource.getCachedHistoricalRatePoints(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        timeframe: timeframe,
      );
      if (cachedSeries != null && cachedSeries.isNotEmpty) {
        if (resultPoints.isEmpty) {
          resultPoints.addAll(cachedSeries);
        } else {
          // Merge missing dates from authentic cached series
          final existingDateKeys =
              resultPoints.map((p) => _formatDate(p.date)).toSet();
          for (final cachedPoint in cachedSeries) {
            if (!existingDateKeys.contains(_formatDate(cachedPoint.date))) {
              resultPoints.add(cachedPoint);
            }
          }
        }
      }
    }

    // 3. Fallback to individual authentic date-level cache entries if series cache was not found
    if (resultPoints.isEmpty) {
      for (final date in targetDates) {
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
            isCached: true,
          ));
        }
      }
    }

    // 4. If NO authentic local cache exists at all for that pair/timeframe, throw NoCachedDataException
    if (resultPoints.isEmpty) {
      throw const NoCachedDataException(
        'Unable to load historical rates. Please check your connection.',
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
        isCached: lastPoint.isCached,
      );
    }

    // Save full series if remote was successful to ensure offline availability for this pair + timeframe
    if (!remoteFailed && validatedList.isNotEmpty) {
      await _cacheDataSource.saveHistoricalRatePoints(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        timeframe: timeframe,
        points: validatedList,
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
