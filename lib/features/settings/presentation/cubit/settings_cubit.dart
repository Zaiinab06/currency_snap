import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

/// Cubit managing application preferences, user profile display name, theme mode, and default currencies.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._settingsRepository) : super(SettingsState.initial()) {
    _loadSettings();
  }

  void _loadSettings() {
    final settings = _settingsRepository.getSettings();
    emit(SettingsState.fromEntity(settings));
  }

  /// Updates the user profile display name instantly and persists asynchronously.
  void updateUserDisplayName(String name) {
    emit(state.copyWith(userDisplayName: name));
    unawaited(_settingsRepository.updateUserDisplayName(name));
  }

  /// Updates the application theme mode instantly and persists asynchronously.
  void updateThemeMode(AppThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
    unawaited(_settingsRepository.updateThemeMode(mode));
  }

  /// Updates the default base currency instantly and persists asynchronously.
  void updateDefaultBaseCurrency(String currency) {
    emit(state.copyWith(defaultBaseCurrency: currency));
    unawaited(_settingsRepository.updateDefaultBaseCurrency(currency));
  }

  /// Updates the default target currency instantly and persists asynchronously.
  void updateDefaultTargetCurrency(String currency) {
    emit(state.copyWith(defaultTargetCurrency: currency));
    unawaited(_settingsRepository.updateDefaultTargetCurrency(currency));
  }

  /// Clears the local rates cache.
  Future<void> clearRatesCache() {
    return _settingsRepository.clearRatesCache();
  }
}
