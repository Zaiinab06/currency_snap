import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Central Dio instance used across the app for all HTTP calls.
/// Keeping this in one place means timeouts, headers, and interceptors
/// are configured once, not duplicated per API call.
class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Basic logging in debug builds only — helps verify requests/responses
    // while building, without leaking anything in release mode.
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: true, error: true),
    );

    return dio;
  }
}
