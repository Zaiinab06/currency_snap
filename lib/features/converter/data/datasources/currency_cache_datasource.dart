import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../models/currency_rate_model.dart';

/// Contract for local currency cache data source.
abstract class CurrencyCacheDataSource {
  Future<void> saveRates(CurrencyRateModel rates, {DateTime? syncTime});
  Future<CurrencyRateModel> getCachedRates();
  Future<CurrencyRateModel?> getPreviousRates();
  DateTime? getLastSyncTime();
  bool hasCachedRates();
  Future<void> clearCache();
  List<double> getHistoricalPoints({
    required String fromCurrency,
    required String toCurrency,
    required String timeframe,
    required double currentRate,
  });
}

/// Local data source responsible for persisting and retrieving cached currency exchange rates.
class CurrencyCacheDataSourceImpl implements CurrencyCacheDataSource {
  final SharedPreferences _prefs;

  CurrencyCacheDataSourceImpl(this._prefs);

  @override
  Future<void> saveRates(CurrencyRateModel rates, {DateTime? syncTime}) async {
    final now = syncTime ?? DateTime.now();

    // 1. Move existing rates to previous rates before updating
    final existingJsonString = _prefs.getString(AppConstants.cacheKeyRates);
    if (existingJsonString != null) {
      await _prefs.setString(
        AppConstants.cacheKeyPreviousRates,
        existingJsonString,
      );
    }

    // 2. Append to historical snapshots list (pruning to max 60 snapshots)
    try {
      final snapshotsRaw =
          _prefs.getStringList(AppConstants.cacheKeyRateSnapshots) ?? [];
      final newSnapshot = jsonEncode({
        'timestamp': now.toIso8601String(),
        'base': rates.baseCurrency,
        'rates': rates.rates,
      });

      final updatedSnapshots = List<String>.from(snapshotsRaw)..add(newSnapshot);
      if (updatedSnapshots.length > 60) {
        updatedSnapshots.removeRange(0, updatedSnapshots.length - 60);
      }
      await _prefs.setStringList(
        AppConstants.cacheKeyRateSnapshots,
        updatedSnapshots,
      );
    } catch (_) {}

    // 3. Save fresh rates and timestamp
    final jsonString = jsonEncode(rates.toCacheJson());
    await _prefs.setString(AppConstants.cacheKeyRates, jsonString);
    await _prefs.setString(
      AppConstants.cacheKeyTimestamp,
      now.toIso8601String(),
    );
  }

  @override
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

  @override
  Future<CurrencyRateModel?> getPreviousRates() async {
    final jsonString = _prefs.getString(AppConstants.cacheKeyPreviousRates);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CurrencyRateModel.fromCacheJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  DateTime? getLastSyncTime() {
    final timeStr = _prefs.getString(AppConstants.cacheKeyTimestamp);
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  @override
  bool hasCachedRates() {
    return _prefs.containsKey(AppConstants.cacheKeyRates);
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(AppConstants.cacheKeyRates);
    await _prefs.remove(AppConstants.cacheKeyPreviousRates);
    await _prefs.remove(AppConstants.cacheKeyRateSnapshots);
    await _prefs.remove(AppConstants.cacheKeyTimestamp);
  }

  @override
  List<double> getHistoricalPoints({
    required String fromCurrency,
    required String toCurrency,
    required String timeframe,
    required double currentRate,
  }) {
    final int requiredCount = switch (timeframe) {
      '24H' => 5,
      '1M' => 5,
      '1Y' => 5,
      '7D' => 7,
      _ => 7,
    };

    final snapshotsRaw =
        _prefs.getStringList(AppConstants.cacheKeyRateSnapshots) ?? [];

    final List<double> extractedRates = [];

    for (final snapString in snapshotsRaw) {
      try {
        final Map<String, dynamic> snap = jsonDecode(snapString);
        final base = snap['base'] as String? ?? 'USD';
        final ratesMap = (snap['rates'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, (v as num).toDouble()),
            ) ??
            {};

        if (fromCurrency == toCurrency) {
          extractedRates.add(1.0);
          continue;
        }

        final fromRate =
            fromCurrency == base ? 1.0 : ratesMap[fromCurrency];
        final toRate = toCurrency == base ? 1.0 : ratesMap[toCurrency];

        if (fromRate != null && toRate != null && fromRate > 0) {
          final computed = (1.0 / fromRate) * toRate;
          extractedRates.add(computed);
        }
      } catch (_) {}
    }

    // Ensure the latest point is currentRate
    if (extractedRates.isEmpty || extractedRates.last != currentRate) {
      extractedRates.add(currentRate);
    }

    if (extractedRates.length >= requiredCount) {
      return extractedRates.sublist(extractedRates.length - requiredCount);
    }

    // If fewer real historical snapshots are recorded yet,
    // interpolate gracefully from the earliest known recorded rate to currentRate
    final startRate = extractedRates.first;
    final List<double> interpolated = [];
    final steps = requiredCount - 1;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final point = startRate + (currentRate - startRate) * t;
      interpolated.add(point);
    }
    return interpolated;
  }
}
