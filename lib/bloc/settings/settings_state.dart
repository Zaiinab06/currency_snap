import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Available theme modes supported across CurrencySnap: System, Light, Dark (default).
enum AppThemeMode {
  system('system', 'System', ThemeMode.system),
  light('light', 'Light', ThemeMode.light),
  dark('dark', 'Dark', ThemeMode.dark);

  final String key;
  final String label;
  final ThemeMode mode;

  const AppThemeMode(this.key, this.label, this.mode);

  static AppThemeMode fromKey(String? key) {
    switch (key) {
      case 'system':
        return AppThemeMode.system;
      case 'light':
        return AppThemeMode.light;
      case 'dark':
      default:
        return AppThemeMode.dark;
    }
  }
}

/// State representing user settings, theme preferences, and default currencies.
class SettingsState extends Equatable {
  final AppThemeMode themeMode;
  final String defaultBaseCurrency;
  final String defaultTargetCurrency;

  const SettingsState({
    required this.themeMode,
    required this.defaultBaseCurrency,
    required this.defaultTargetCurrency,
  });

  /// Returns the corresponding Flutter [ThemeMode] enum.
  ThemeMode get flutterThemeMode => themeMode.mode;

  factory SettingsState.initial() {
    return const SettingsState(
      themeMode: AppThemeMode.dark,
      defaultBaseCurrency: AppConstants.defaultBaseCurrency,
      defaultTargetCurrency: AppConstants.defaultTargetCurrency,
    );
  }

  SettingsState copyWith({
    AppThemeMode? themeMode,
    String? defaultBaseCurrency,
    String? defaultTargetCurrency,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      defaultBaseCurrency: defaultBaseCurrency ?? this.defaultBaseCurrency,
      defaultTargetCurrency:
          defaultTargetCurrency ?? this.defaultTargetCurrency,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        defaultBaseCurrency,
        defaultTargetCurrency,
      ];
}
