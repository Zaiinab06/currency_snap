import 'package:dio/dio.dart';
import '../../models/currency_rate_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/errors/app_exceptions.dart';

/// Fetches live exchange rate data from the API.
/// Knows nothing about caching or favorites — its only job is the network call.
class CurrencyRemoteDataSource {
  final Dio _dio;

  CurrencyRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// Fetches latest rates for [baseCurrency] (e.g. "USD").
  /// Throws [NetworkException] on connectivity/server failure,
  /// or [DataParsingException] if the response shape is unexpected.
  Future<CurrencyRateModel> getLatestRates(String baseCurrency) async {
    try {
      final response = await _dio.get('/$baseCurrency');

      if (response.statusCode != 200 || response.data == null) {
        throw NetworkException(
          'Unexpected response (status: ${response.statusCode})',
        );
      }

      return CurrencyRateModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Covers: no internet, timeout, connection refused, 4xx/5xx, etc.
      throw NetworkException(_mapDioError(e));
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw DataParsingException('Failed to parse rate data: $e');
    }
  }

  String _mapDioError(DioException e) {
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
