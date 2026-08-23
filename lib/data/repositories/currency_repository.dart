import '../models/currency_rate_model.dart';
import '../models/favourite_pair_model.dart';
import '../datasources/remote/currency_remote_datasource.dart';
import '../datasources/local/currency_cache_datasource.dart';
import '../datasources/local/favorites_local_datasource.dart';
import '../../core/errors/app_exceptions.dart';

/// Encapsulates currency rate data along with its source origin (remote vs cache).
class RateResult {
  final CurrencyRateModel rates;
  final bool isFromCache;

  const RateResult({required this.rates, required this.isFromCache});
}

/// Repository coordinating currency exchange rates and user favorites across remote and local sources.
class CurrencyRepository {
  final CurrencyRemoteDataSource _remoteDataSource;
  final CurrencyCacheDataSource _cacheDataSource;
  final FavoritesLocalDataSource _favoritesDataSource;

  CurrencyRepository(
    this._remoteDataSource,
    this._cacheDataSource,
    this._favoritesDataSource,
  );

  /// Retrieves rates for [baseCurrency], fetching from remote API with fallback to local cache.
  Future<RateResult> getRates(String baseCurrency) async {
    try {
      final freshRates = await _remoteDataSource.getLatestRates(baseCurrency);
      await _cacheDataSource.saveRates(freshRates);
      return RateResult(rates: freshRates, isFromCache: false);
    } on NetworkException {
      try {
        final cachedRates = await _cacheDataSource.getCachedRates();
        return RateResult(rates: cachedRates, isFromCache: true);
      } on NoCachedDataException {
        rethrow;
      }
    }
  }

  /// Retrieves all saved favorite currency pairs.
  Future<List<FavoritePairModel>> getFavorites() {
    return _favoritesDataSource.getFavorites();
  }

  /// Adds or updates a favorite currency pair.
  Future<void> addFavorite(FavoritePairModel pair) {
    return _favoritesDataSource.addFavorite(pair);
  }

  /// Removes a favorite currency pair by [id].
  Future<void> removeFavorite(String id) {
    return _favoritesDataSource.removeFavorite(id);
  }

  /// Checks if a pair identified by [id] is marked as favorite.
  Future<bool> isFavorite(String id) {
    return _favoritesDataSource.isFavorite(id);
  }

  /// Clears cached exchange rates from storage.
  Future<void> clearCache() {
    return _cacheDataSource.clearCache();
  }
}
