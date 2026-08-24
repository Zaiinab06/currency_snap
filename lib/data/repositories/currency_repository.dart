import 'package:currency_snap/data/models/favourite_pair_model.dart';

import '../models/currency_rate_model.dart';
import '../datasources/remote/currency_remote_datasource.dart';
import '../datasources/local/currency_cache_datasource.dart';
import '../datasources/local/favorites_local_datasource.dart';
import '../../core/errors/app_exceptions.dart';

/// Wraps a rate result together with whether it came from the network
/// or from local cache. The UI/Cubit uses [isFromCache] to decide
/// whether to show the "last updated" offline indicator.
class RateResult {
  final CurrencyRateModel rates;
  final bool isFromCache;

  const RateResult({required this.rates, required this.isFromCache});
}

/// Single source of truth for currency rate data.
class CurrencyRepository {
  final CurrencyRemoteDataSource _remoteDataSource;
  final CurrencyCacheDataSource _cacheDataSource;
  final FavoritesLocalDataSource _favoritesDataSource;

  CurrencyRepository(
    this._remoteDataSource,
    this._cacheDataSource,
    this._favoritesDataSource,
  );

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

  Future<void> clearCache() {
    return _cacheDataSource.clearCache();
  }
}
