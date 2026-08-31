import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/settings_entity.dart';

/// State representing user settings, theme preferences, default currencies, and profile display name.
class SettingsState extends Equatable {
  final AppThemeMode themeMode;
  final String defaultBaseCurrency;
  final String defaultTargetCurrency;
  final String userDisplayName;

  const SettingsState({
    required this.themeMode,
    required this.defaultBaseCurrency,
    required this.defaultTargetCurrency,
    this.userDisplayName = '',
  });

  /// Returns the corresponding Flutter [ThemeMode] enum.
  ThemeMode get flutterThemeMode => themeMode.mode;

  /// Whether Deep Plum / Dark mode is currently active.
  bool get isDarkMode => themeMode == AppThemeMode.dark;

  factory SettingsState.initial() {
    return const SettingsState(
      themeMode: AppThemeMode.light,
      defaultBaseCurrency: AppConstants.defaultBaseCurrency,
      defaultTargetCurrency: AppConstants.defaultTargetCurrency,
      userDisplayName: '',
    );
  }

  factory SettingsState.fromEntity(SettingsEntity entity) {
    return SettingsState(
      themeMode: entity.themeMode,
      defaultBaseCurrency: entity.defaultBaseCurrency,
      defaultTargetCurrency: entity.defaultTargetCurrency,
      userDisplayName: entity.userDisplayName,
    );
  }

  SettingsState copyWith({
    AppThemeMode? themeMode,
    String? defaultBaseCurrency,
    String? defaultTargetCurrency,
    String? userDisplayName,
  }) {
    return SettingsState(
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
