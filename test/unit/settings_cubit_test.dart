import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_snap/core/constants/app_constants.dart';
import 'package:currency_snap/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:currency_snap/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:currency_snap/features/settings/domain/entities/settings_entity.dart';
import 'package:currency_snap/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:currency_snap/features/settings/presentation/cubit/settings_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsState', () {
    test('initial state defaults to Light theme and empty user display name', () {
      final state = SettingsState.initial();
      expect(state.themeMode, AppThemeMode.light);
      expect(state.flutterThemeMode, ThemeMode.light);
      expect(state.isDarkMode, isFalse);
      expect(state.defaultBaseCurrency, AppConstants.defaultBaseCurrency);
      expect(state.defaultTargetCurrency, AppConstants.defaultTargetCurrency);
      expect(state.userDisplayName, '');
    });

    test('isDarkMode getter accurately reflects themeMode', () {
      const darkState = SettingsState(
        themeMode: AppThemeMode.dark,
        defaultBaseCurrency: 'USD',
        defaultTargetCurrency: 'EUR',
      );
      expect(darkState.isDarkMode, isTrue);

      const lightState = SettingsState(
        themeMode: AppThemeMode.light,
        defaultBaseCurrency: 'USD',
        defaultTargetCurrency: 'EUR',
      );
      expect(lightState.isDarkMode, isFalse);

      const systemState = SettingsState(
        themeMode: AppThemeMode.system,
        defaultBaseCurrency: 'USD',
        defaultTargetCurrency: 'EUR',
      );
      expect(systemState.isDarkMode, isFalse);
    });

    test('AppThemeMode fromKey fallbacks to light mode', () {
      expect(AppThemeMode.fromKey(null), AppThemeMode.light);
      expect(AppThemeMode.fromKey(''), AppThemeMode.light);
      expect(AppThemeMode.fromKey('unknown'), AppThemeMode.light);
      expect(AppThemeMode.fromKey('light'), AppThemeMode.light);
      expect(AppThemeMode.fromKey('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromKey('system'), AppThemeMode.system);
    });
  });

  group('SettingsCubit', () {
    test('defaults to Light Mode if SharedPreferences has no saved theme preference', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepositoryImpl(
        SettingsLocalDataSourceImpl(prefs),
      );
      final cubit = SettingsCubit(repository);

      expect(cubit.state.themeMode, AppThemeMode.light);
      expect(cubit.state.flutterThemeMode, ThemeMode.light);
      expect(cubit.state.isDarkMode, isFalse);
      expect(cubit.state.userDisplayName, '');

      await cubit.close();
    });

    test('loads saved theme preference and display name when present in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefKeyThemeMode: 'dark',
        AppConstants.prefKeyUserDisplayName: 'Zainab',
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepositoryImpl(
        SettingsLocalDataSourceImpl(prefs),
      );
      final cubit = SettingsCubit(repository);

      expect(cubit.state.themeMode, AppThemeMode.dark);
      expect(cubit.state.flutterThemeMode, ThemeMode.dark);
      expect(cubit.state.isDarkMode, isTrue);
      expect(cubit.state.userDisplayName, 'Zainab');

      await cubit.close();
    });

    test('updateUserDisplayName updates state and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepositoryImpl(
        SettingsLocalDataSourceImpl(prefs),
      );
      final cubit = SettingsCubit(repository);

      expect(cubit.state.userDisplayName, '');

      cubit.updateUserDisplayName('Zainab');
      expect(cubit.state.userDisplayName, 'Zainab');
      expect(prefs.getString(AppConstants.prefKeyUserDisplayName), 'Zainab');

      await cubit.close();
    });

    test('updateThemeMode updates state and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepositoryImpl(
        SettingsLocalDataSourceImpl(prefs),
      );
      final cubit = SettingsCubit(repository);

      expect(cubit.state.themeMode, AppThemeMode.light);

      cubit.updateThemeMode(AppThemeMode.dark);
      expect(cubit.state.themeMode, AppThemeMode.dark);
      expect(cubit.state.flutterThemeMode, ThemeMode.dark);
      expect(prefs.getString(AppConstants.prefKeyThemeMode), 'dark');

      cubit.updateThemeMode(AppThemeMode.light);
      expect(cubit.state.themeMode, AppThemeMode.light);
      expect(cubit.state.flutterThemeMode, ThemeMode.light);
      expect(prefs.getString(AppConstants.prefKeyThemeMode), 'light');

      await cubit.close();
    });
  });
}
