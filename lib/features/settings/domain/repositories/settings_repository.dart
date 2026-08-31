import '../entities/settings_entity.dart';

/// Abstract domain contract for application settings and preferences.
abstract class SettingsRepository {
  SettingsEntity getSettings();
  Future<void> updateThemeMode(AppThemeMode mode);
  Future<void> updateDefaultBaseCurrency(String currency);
  Future<void> updateDefaultTargetCurrency(String currency);
  Future<void> updateUserDisplayName(String name);
  Future<void> clearRatesCache();
}
