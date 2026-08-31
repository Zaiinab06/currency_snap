import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Implementation of [SettingsRepository] interacting with local datasource.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  SettingsEntity getSettings() {
    return _localDataSource.getSettings();
  }

  @override
  Future<void> updateThemeMode(AppThemeMode mode) {
    return _localDataSource.saveThemeMode(mode.key);
  }

  @override
  Future<void> updateDefaultBaseCurrency(String currency) {
    return _localDataSource.saveDefaultBaseCurrency(currency);
  }

  @override
  Future<void> updateDefaultTargetCurrency(String currency) {
    return _localDataSource.saveDefaultTargetCurrency(currency);
  }

  @override
  Future<void> updateUserDisplayName(String name) {
    return _localDataSource.saveUserDisplayName(name);
  }

  @override
  Future<void> clearRatesCache() {
    return _localDataSource.clearRatesCache();
  }
}
