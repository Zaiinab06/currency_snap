import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/currency_rate_entity.dart';
import '../../domain/repositories/converter_repository.dart';
import '../datasources/currency_cache_datasource.dart';
import '../datasources/currency_remote_datasource.dart';
import '../models/currency_rate_model.dart';

/// Implementation of [ConverterRepository] coordinating remote and cache datasources.
class ConverterRepositoryImpl implements ConverterRepository {
  final CurrencyRemoteDataSource _remoteDataSource;
  final CurrencyCacheDataSource _cacheDataSource;

  ConverterRepositoryImpl(this._remoteDataSource, this._cacheDataSource);

  @override
  Future<RateResultEntity> getRates(
    String baseCurrency, {
    bool forceRefresh = false,
  }) async {
    try {
      final cachedPrev = await _cacheDataSource.getPreviousRates();
      final freshRates = await _remoteDataSource.getLatestRates(baseCurrency);
      final syncTime = DateTime.now();

      // Attempt to query historical baseline from open Frankfurter time-series
      CurrencyRateModel? baselineRates;
      try {
        baselineRates =
            await _remoteDataSource.getHistoricalBaselineRates(baseCurrency);
      } catch (_) {}

      final effectivePreviousRates = baselineRates ?? cachedPrev;

      await _cacheDataSource.saveRates(freshRates, syncTime: syncTime);
      return RateResultEntity(
        rates: freshRates,
        previousRates: effectivePreviousRates,
        isFromCache: false,
        syncTime: syncTime,
      );
    } on ServerException catch (serverError) {
      try {
        final cachedRates = await _cacheDataSource.getCachedRates();
        final previousRates = await _cacheDataSource.getPreviousRates();
        final syncTime =
            _cacheDataSource.getLastSyncTime() ?? cachedRates.lastUpdated;
        return RateResultEntity(
          rates: cachedRates,
          previousRates: previousRates,
          isFromCache: true,
          syncTime: syncTime,
        );
      } on NoCachedDataException {
        throw ServerException(serverError.message);
      }
    } on NetworkException catch (networkError) {
      try {
        final cachedRates = await _cacheDataSource.getCachedRates();
        final previousRates = await _cacheDataSource.getPreviousRates();
        final syncTime =
            _cacheDataSource.getLastSyncTime() ?? cachedRates.lastUpdated;
        return RateResultEntity(
          rates: cachedRates,
          previousRates: previousRates,
          isFromCache: true,
          syncTime: syncTime,
        );
      } on NoCachedDataException {
        throw NetworkException(networkError.message);
      }
    } catch (e) {
      try {
        final cachedRates = await _cacheDataSource.getCachedRates();
        final previousRates = await _cacheDataSource.getPreviousRates();
        final syncTime =
            _cacheDataSource.getLastSyncTime() ?? cachedRates.lastUpdated;
        return RateResultEntity(
          rates: cachedRates,
          previousRates: previousRates,
          isFromCache: true,
          syncTime: syncTime,
        );
      } on NoCachedDataException {
        throw NetworkException('Unable to fetch live exchange rates: $e');
      }
    }
  }

  @override
  Future<void> clearCache() {
    return _cacheDataSource.clearCache();
  }
}
