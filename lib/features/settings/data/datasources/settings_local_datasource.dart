import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/settings_entity.dart';

/// Contract for settings local data source.
abstract class SettingsLocalDataSource {
  SettingsEntity getSettings();
  Future<void> saveThemeMode(String modeKey);
  Future<void> saveDefaultBaseCurrency(String currency);
  Future<void> saveDefaultTargetCurrency(String currency);
  Future<void> saveUserDisplayName(String name);
  Future<void> clearRatesCache();
}

/// Local data source responsible for persisting and reading user settings and preferences.
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _prefs;

  SettingsLocalDataSourceImpl(this._prefs);

  @override
  SettingsEntity getSettings() {
    final savedThemeKey = _prefs.getString(AppConstants.prefKeyThemeMode);
    final savedIsDarkBool = _prefs.getBool('is_dark_theme');
    final AppThemeMode themeMode;
    if (savedThemeKey != null && savedThemeKey.isNotEmpty) {
      themeMode = AppThemeMode.fromKey(savedThemeKey);
    } else if (savedIsDarkBool != null) {
      themeMode = savedIsDarkBool ? AppThemeMode.dark : AppThemeMode.light;
    } else {
      themeMode = AppThemeMode.light;
    }

    final savedBase = _prefs.getString(AppConstants.prefKeyDefaultCurrency) ??
        AppConstants.defaultBaseCurrency;
    final savedTarget =
        _prefs.getString(AppConstants.prefKeyDefaultTargetCurrency) ??
            AppConstants.defaultTargetCurrency;
    final savedName =
        _prefs.getString(AppConstants.prefKeyUserDisplayName) ?? '';

    return SettingsEntity(
      themeMode: themeMode,
      defaultBaseCurrency: savedBase,
      defaultTargetCurrency: savedTarget,
      userDisplayName: savedName,
    );
  }

  @override
  Future<void> saveThemeMode(String modeKey) async {
    await _prefs.setString(AppConstants.prefKeyThemeMode, modeKey);
  }

  @override
  Future<void> saveDefaultBaseCurrency(String currency) async {
    await _prefs.setString(AppConstants.prefKeyDefaultCurrency, currency);
  }

  @override
  Future<void> saveDefaultTargetCurrency(String currency) async {
    await _prefs.setString(AppConstants.prefKeyDefaultTargetCurrency, currency);
  }

  @override
  Future<void> saveUserDisplayName(String name) async {
    await _prefs.setString(AppConstants.prefKeyUserDisplayName, name);
  }

  @override
  Future<void> clearRatesCache() async {
    await _prefs.remove(AppConstants.cacheKeyRates);
    await _prefs.remove(AppConstants.cacheKeyPreviousRates);
    await _prefs.remove(AppConstants.cacheKeyRateSnapshots);
    await _prefs.remove(AppConstants.cacheKeyTimestamp);
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('historical_series_') || RegExp(r'^[A-Z]{3}_[A-Z]{3}_\d{4}').hasMatch(key)) {
        await _prefs.remove(key);
      }
    }
  }
}
