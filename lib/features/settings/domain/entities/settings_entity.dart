import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Available theme modes supported across CurrencySnap.
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
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      case 'light':
      default:
        return AppThemeMode.light;
    }
  }
}

/// Pure domain entity representing user preferences, display name, and theme settings.
class SettingsEntity extends Equatable {
  final AppThemeMode themeMode;
  final String defaultBaseCurrency;
  final String defaultTargetCurrency;
  final String userDisplayName;

  const SettingsEntity({
    required this.themeMode,
    required this.defaultBaseCurrency,
    required this.defaultTargetCurrency,
    this.userDisplayName = '',
  });

  ThemeMode get flutterThemeMode => themeMode.mode;
  bool get isDarkMode => themeMode == AppThemeMode.dark;

  factory SettingsEntity.initial() {
    return const SettingsEntity(
      themeMode: AppThemeMode.light,
      defaultBaseCurrency: AppConstants.defaultBaseCurrency,
      defaultTargetCurrency: AppConstants.defaultTargetCurrency,
      userDisplayName: '',
    );
  }

  SettingsEntity copyWith({
    AppThemeMode? themeMode,
    String? defaultBaseCurrency,
    String? defaultTargetCurrency,
    String? userDisplayName,
  }) {
    return SettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      defaultBaseCurrency: defaultBaseCurrency ?? this.defaultBaseCurrency,
      defaultTargetCurrency:
          defaultTargetCurrency ?? this.defaultTargetCurrency,
      userDisplayName: userDisplayName ?? this.userDisplayName,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        defaultBaseCurrency,
        defaultTargetCurrency,
        userDisplayName,
      ];
}
