import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/historical_rate_point.dart';

/// Contract for fetching remote time-series historical rate data for date ranges and individual calendar dates.
abstract class HistoricalRatesRemoteDataSource {
  Future<List<HistoricalRatePoint>> getTimeSeriesRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<HistoricalRatePoint> getRateForDate({
    required String fromCurrency,
    required String toCurrency,
    required DateTime date,
  });
}

/// Implementation querying open historical currency endpoints with full currency coverage and detailed logging.
class HistoricalRatesRemoteDataSourceImpl
    implements HistoricalRatesRemoteDataSource {
  final Dio _dio;

  HistoricalRatesRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ?? DioClient.instance;

  @override
  Future<List<HistoricalRatePoint>> getTimeSeriesRates({
    required String fromCurrency,
    required String toCurrency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final fromUpper = fromCurrency.toUpperCase();
    final toUpper = toCurrency.toUpperCase();
    final startStr = _formatDate(startDate);
    final endStr = _formatDate(endDate);

    // 1. Primary time-series endpoint: Frankfurter range API (fast, single HTTP request for supported pairs)
    final frankfurterRangeUrl =
        'https://api.frankfurter.app/$startStr..$endStr?from=$fromUpper&to=$toUpper';

    debugPrint('Historical range API URL: $frankfurterRangeUrl');

    try {
      final response = await _dio.get(
        frankfurterRangeUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;

        if (data is Map) {
          final ratesMap = data['rates'];
          if (ratesMap is Map && ratesMap.isNotEmpty) {
            final List<HistoricalRatePoint> rangePoints = [];
            ratesMap.forEach((dateKey, val) {
              if (val is Map) {
                final rateNum = val[toUpper];
                final parsedDate = DateTime.tryParse(dateKey.toString());
                if (rateNum is num &&
                    rateNum.toDouble() > 0 &&
                    parsedDate != null) {
                  rangePoints.add(HistoricalRatePoint(
                    date: DateTime(
                        parsedDate.year, parsedDate.month, parsedDate.day),
                    rate: rateNum.toDouble(),
                    baseCurrency: fromCurrency,
                    targetCurrency: toCurrency,
                  ));
                }
              }
            });

            if (rangePoints.isNotEmpty) {
              rangePoints.sort((a, b) => a.date.compareTo(b.date));
              return rangePoints;
            }
          }
        }
      }
    } catch (e) {
      debugPrint(
          'Frankfurter range API unavailable or unsupported for $fromUpper/$toUpper: $e');
    }

    // 2. Open Currency Universal API with parallel genuine date fetching
    final totalDays = endDate.difference(startDate).inDays;
    final List<DateTime> dates = List.generate(
      totalDays + 1,
      (i) => startDate.add(Duration(days: i)),
    );

    final futures = dates.map((date) => getRateForDate(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          date: date,
        ).then<HistoricalRatePoint?>((p) => p).catchError((e) {
          debugPrint('Failed to fetch rate for $date: $e');
          return null;
        }));

    final fetched = await Future.wait(futures);
    final List<HistoricalRatePoint> points =
        fetched.whereType<HistoricalRatePoint>().toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (points.isNotEmpty) {
      return points;
    }

    throw Exception(
      'Unable to fetch historical time-series for $fromCurrency/$toCurrency between $startStr and $endStr',
    );
  }

  @override
  Future<HistoricalRatePoint> getRateForDate({
    required String fromCurrency,
    required String toCurrency,
    required DateTime date,
  }) async {
    final dateStr = _formatDate(date);
    final fromLower = fromCurrency.toLowerCase();
    final toLower = toCurrency.toLowerCase();
    final toUpper = toCurrency.toUpperCase();

    // 1. Primary endpoint: Universal open currency API supporting 160+ currencies directly
    final primaryUrl =
        'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$dateStr/v1/currencies/$fromLower.json';

    debugPrint('Historical request date: $dateStr');
    debugPrint('Historical API URL: $primaryUrl');

    try {
      final response = await _dio.get(
        primaryUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;

        if (data is Map<String, dynamic> || data is Map) {
          final map = Map<String, dynamic>.from(data as Map);
          final table = map[fromLower];
          if (table is Map) {
            final rateNum = table[toLower];
            if (rateNum is num && rateNum.toDouble() > 0) {
              final model = HistoricalRatePoint(
                date: DateTime(date.year, date.month, date.day),
                rate: rateNum.toDouble(),
                baseCurrency: fromCurrency,
                targetCurrency: toCurrency,
              );
              debugPrint(
                'DATE: ${model.date} | BASE: $fromCurrency | TARGET: $toCurrency | RATE: ${model.rate}',
              );
              return model;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Primary historical API failed for $dateStr: $e');
    }

    // 1b. Intermediate USD anchor fallback on universal open currency API (e.g. JPY/CAD via USD)
    final anchorUrl =
        'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$dateStr/v1/currencies/usd.json';

    try {
      final response = await _dio.get(
        anchorUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;

        if (data is Map<String, dynamic> || data is Map) {
          final map = Map<String, dynamic>.from(data as Map);
          final usdTable = map['usd'];
          if (usdTable is Map) {
            final toNum = usdTable[toLower];
            final fromNum = fromLower == 'usd' ? 1.0 : usdTable[fromLower];
            if (toNum is num &&
                fromNum is num &&
                fromNum.toDouble() > 0 &&
                toNum.toDouble() > 0) {
              final calculatedRate = toNum.toDouble() / fromNum.toDouble();
              final model = HistoricalRatePoint(
                date: DateTime(date.year, date.month, date.day),
                rate: calculatedRate,
                baseCurrency: fromCurrency,
                targetCurrency: toCurrency,
              );
              debugPrint(
                'DATE: ${model.date} | BASE: $fromCurrency | TARGET: $toCurrency | CALCULATED RATE: ${model.rate}',
              );
              return model;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Anchor historical API failed for $dateStr: $e');
    }

    // 2. Secondary endpoint: Frankfurter historical date endpoint
    final secondaryUrl =
        'https://api.frankfurter.app/$dateStr?from=${fromCurrency.toUpperCase()}&to=$toUpper';

    debugPrint('Historical request date: $dateStr (secondary)');
    debugPrint('Historical API URL: $secondaryUrl');

    try {
      final response = await _dio.get(
        secondaryUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;

        if (data is Map<String, dynamic> || data is Map) {
          final map = Map<String, dynamic>.from(data as Map);
          final ratesObj = map['rates'];
          if (ratesObj is Map) {
            final rateNum = ratesObj[toUpper];
            if (rateNum is num && rateNum.toDouble() > 0) {
              final model = HistoricalRatePoint(
                date: DateTime(date.year, date.month, date.day),
                rate: rateNum.toDouble(),
                baseCurrency: fromCurrency,
                targetCurrency: toCurrency,
              );
              debugPrint(
                'DATE: ${model.date} | BASE: $fromCurrency | TARGET: $toCurrency | RATE: ${model.rate}',
              );
              return model;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Secondary historical API failed for $dateStr: $e');
    }

    throw Exception(
      'Historical rate for $fromCurrency/$toCurrency on $dateStr could not be fetched from remote APIs',
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
