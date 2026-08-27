import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import 'settings_state.dart';

/// Cubit managing application preferences, theme mode, and default currencies.
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(SettingsState.initial()) {
    _loadSettings();
  }

  void _loadSettings() {
    final savedThemeKey = _prefs.getString(AppConstants.prefKeyThemeMode);
    final themeMode = AppThemeMode.fromKey(savedThemeKey);

    final savedBase = _prefs.getString(AppConstants.prefKeyDefaultCurrency) ??
        AppConstants.defaultBaseCurrency;
    final savedTarget =
        _prefs.getString(AppConstants.prefKeyDefaultTargetCurrency) ??
            AppConstants.defaultTargetCurrency;

    emit(
      SettingsState(
        themeMode: themeMode,
        defaultBaseCurrency: savedBase,
        defaultTargetCurrency: savedTarget,
      ),
    );
  }

  /// Updates the application theme mode instantly and persists asynchronously.
  void updateThemeMode(AppThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
    unawaited(_prefs.setString(AppConstants.prefKeyThemeMode, mode.key));
  }

  /// Updates the default base currency instantly and persists asynchronously.
  void updateDefaultBaseCurrency(String currency) {
    emit(state.copyWith(defaultBaseCurrency: currency));
    unawaited(_prefs.setString(AppConstants.prefKeyDefaultCurrency, currency));
  }

  /// Updates the default target currency instantly and persists asynchronously.
  void updateDefaultTargetCurrency(String currency) {
    emit(state.copyWith(defaultTargetCurrency: currency));
    unawaited(
      _prefs.setString(AppConstants.prefKeyDefaultTargetCurrency, currency),
    );
  }
}
