import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/currency_rate_model.dart';

/// Contract for remote currency rate data source.
abstract class CurrencyRemoteDataSource {
  Future<CurrencyRateModel> getLatestRates(String baseCurrency);
  Future<CurrencyRateModel?> getHistoricalBaselineRates(
    String baseCurrency, {
    DateTime? date,
  });
}

/// Remote data source responsible for fetching live exchange rates and historical 24h baseline rates.
class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final Dio _dio;

  CurrencyRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? DioClient.instance;

  @override
  Future<CurrencyRateModel> getLatestRates(String baseCurrency) async {
    final effectiveBase = baseCurrency.trim().isEmpty
        ? AppConstants.defaultBaseCurrency
        : baseCurrency.trim().toUpperCase();

    try {
      final response = await _dio.get('/$effectiveBase');

      if (response.statusCode != 200 || response.data == null) {
        if (response.statusCode == 403) {
          throw const ServerException(
            'API Key Invalid or Quota Exceeded (403)',
          );
        }
        throw NetworkException(
          'Unexpected response (status: ${response.statusCode})',
        );
      }

      final data = response.data;
      if (data is String) {
        final parsed = jsonDecode(data) as Map<String, dynamic>;
        return CurrencyRateModel.fromJson(parsed);
      } else if (data is Map<String, dynamic>) {
        return CurrencyRateModel.fromJson(data);
      } else if (data is Map) {
        return CurrencyRateModel.fromJson(Map<String, dynamic>.from(data));
      }

      return CurrencyRateModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw const ServerException(
          'API Key Invalid or Quota Exceeded (403)',
        );
      }
      throw NetworkException(_mapDioError(e));
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw DataParsingException('Failed to parse rate data: $e');
    }
  }

  @override
  Future<CurrencyRateModel?> getHistoricalBaselineRates(
    String baseCurrency, {
    DateTime? date,
  }) async {
    final effectiveBase = baseCurrency.trim().isEmpty
        ? AppConstants.defaultBaseCurrency
        : baseCurrency.trim().toUpperCase();

    final baselineDate =
        date ?? DateTime.now().subtract(const Duration(days: 1));
    final year = baselineDate.year.toString().padLeft(4, '0');
    final month = baselineDate.month.toString().padLeft(2, '0');
    final day = baselineDate.day.toString().padLeft(2, '0');
    final dateStr = '$year-$month-$day';

    try {
      final response = await _dio.get(
        '${AppConstants.frankfurterBaseUrl}/$dateStr',
        queryParameters: {'from': effectiveBase},
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;

        if (data is Map<String, dynamic> || data is Map) {
          final map = Map<String, dynamic>.from(data as Map);
          final ratesRaw = map['rates'] as Map?;
          if (ratesRaw != null && ratesRaw.isNotEmpty) {
            final ratesMap = ratesRaw.map(
              (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
            );

            return CurrencyRateModel(
              baseCurrency: (map['base'] as String?) ?? effectiveBase,
              rates: ratesMap,
              lastUpdated:
                  DateTime.tryParse(map['date'] as String? ?? '') ?? baselineDate,
            );
          }
        }
      }
    } catch (_) {
      // Graceful fallback to local cache when open historical baseline endpoint is unreachable
    }
    return null;
  }

  String _mapDioError(DioException e) {
    if (e.response?.statusCode == 403) {
      return 'API Key Invalid or Quota Exceeded (403)';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Check your connection.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}).';
      default:
        return e.message ?? 'Something went wrong while fetching rates.';
    }
  }
}
