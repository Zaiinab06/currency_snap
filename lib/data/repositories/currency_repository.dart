import '../models/currency_rate_model.dart';
import '../models/favorite_pair_model.dart';
import '../models/conversion_history_model.dart';
import '../datasources/remote/currency_remote_datasource.dart';
import '../datasources/local/currency_cache_datasource.dart';
import '../datasources/local/favorites_local_datasource.dart';
import '../datasources/local/history_local_datasource.dart';
import '../../core/errors/app_exceptions.dart';

/// Wraps a rate result together with whether it came from the network
/// or from local cache, along with the device sync timestamp.
class RateResult {
  final CurrencyRateModel rates;
  final bool isFromCache;
  final DateTime syncTime;

  const RateResult({
    required this.rates,
    required this.isFromCache,
    required this.syncTime,
  });
}

/// Single source of truth for currency rate data, favorites, and conversion history.
class CurrencyRepository {
  final CurrencyRemoteDataSource _remoteDataSource;
  final CurrencyCacheDataSource _cacheDataSource;
  final FavoritesLocalDataSource _favoritesDataSource;
  final HistoryLocalDataSource _historyDataSource;

  CurrencyRepository(
    this._remoteDataSource,
    this._cacheDataSource,
    this._favoritesDataSource,
    this._historyDataSource,
  );

  Future<RateResult> getRates(String baseCurrency, {bool forceRefresh = false}) async {
    try {
      final freshRates = await _remoteDataSource.getLatestRates(baseCurrency);
      final syncTime = DateTime.now();
      await _cacheDataSource.saveRates(freshRates, syncTime: syncTime);
      return RateResult(
        rates: freshRates,
        isFromCache: false,
        syncTime: syncTime,
      );
    } on NetworkException {
      try {
        final cachedRates = await _cacheDataSource.getCachedRates();
        final syncTime = _cacheDataSource.getLastSyncTime() ?? cachedRates.lastUpdated;
        return RateResult(
          rates: cachedRates,
          isFromCache: true,
          syncTime: syncTime,
        );
      } on NoCachedDataException {
        rethrow;
      }
    }
  }

  // Favorites
  Future<List<FavoritePairModel>> getFavorites() {
    return _favoritesDataSource.getFavorites();
  }

  Future<void> addFavorite(FavoritePairModel pair) {
    return _favoritesDataSource.addFavorite(pair);
  }

  Future<void> removeFavorite(String id) {
    return _favoritesDataSource.removeFavorite(id);
  }

  Future<bool> isFavorite(String id) {
    return _favoritesDataSource.isFavorite(id);
  }

  // Conversion History
  Future<List<ConversionHistoryModel>> getHistory() {
    return _historyDataSource.getHistory();
  }

  Future<void> addHistory(ConversionHistoryModel item) {
    return _historyDataSource.addHistory(item);
  }

  Future<void> deleteHistoryItem(String id) {
    return _historyDataSource.deleteHistoryItem(id);
  }

  Future<void> clearHistory() {
    return _historyDataSource.clearHistory();
  }

  // Cache
  Future<void> clearCache() {
    return _cacheDataSource.clearCache();
  }
}
