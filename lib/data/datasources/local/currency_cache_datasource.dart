import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/currency_rate_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exceptions.dart';

/// Local data source responsible for persisting and retrieving cached currency exchange rates.
class CurrencyCacheDataSource {
  final SharedPreferences _prefs;

  CurrencyCacheDataSource(this._prefs);

  /// Persists [rates] to local storage along with the sync timestamp.
  Future<void> saveRates(CurrencyRateModel rates, {DateTime? syncTime}) async {
    final now = syncTime ?? DateTime.now();
    final jsonString = jsonEncode(rates.toCacheJson());
    await _prefs.setString(AppConstants.cacheKeyRates, jsonString);
    await _prefs.setString(AppConstants.cacheKeyTimestamp, now.toIso8601String());
  }

  /// Retrieves the cached exchange rates.
  ///
  /// Throws [NoCachedDataException] if no cached rates exist.
  Future<CurrencyRateModel> getCachedRates() async {
    final jsonString = _prefs.getString(AppConstants.cacheKeyRates);

    if (jsonString == null) {
      throw const NoCachedDataException(
        'No cached rates available yet. Connect to the internet once to '
        'fetch initial data.',
      );
    }

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return CurrencyRateModel.fromCacheJson(json);
  }

  /// Retrieves the last sync timestamp from local storage.
  DateTime? getLastSyncTime() {
    final timeStr = _prefs.getString(AppConstants.cacheKeyTimestamp);
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  /// Returns true if cached exchange rates exist in local storage.
  bool hasCachedRates() {
    return _prefs.containsKey(AppConstants.cacheKeyRates);
  }

  /// Clears all cached rates and timestamps from local storage.
  Future<void> clearCache() async {
    await _prefs.remove(AppConstants.cacheKeyRates);
    await _prefs.remove(AppConstants.cacheKeyTimestamp);
  }
}
