import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_snap/bloc/settings/settings_cubit.dart';
import 'package:currency_snap/bloc/settings/settings_state.dart';
import 'package:currency_snap/core/constants/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsState', () {
    test('initial state defaults to Obsidian Dark theme', () {
      final state = SettingsState.initial();
      expect(state.themeMode, AppThemeMode.dark);
      expect(state.flutterThemeMode, ThemeMode.dark);
      expect(state.isDarkMode, isTrue);
      expect(state.defaultBaseCurrency, AppConstants.defaultBaseCurrency);
      expect(state.defaultTargetCurrency, AppConstants.defaultTargetCurrency);
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

    test('AppThemeMode fromKey fallbacks to dark mode', () {
      expect(AppThemeMode.fromKey(null), AppThemeMode.dark);
      expect(AppThemeMode.fromKey(''), AppThemeMode.dark);
      expect(AppThemeMode.fromKey('unknown'), AppThemeMode.dark);
      expect(AppThemeMode.fromKey('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromKey('light'), AppThemeMode.light);
      expect(AppThemeMode.fromKey('system'), AppThemeMode.system);
    });
  });

  group('SettingsCubit', () {
    test('defaults to Dark Mode if SharedPreferences has no saved theme preference', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = SettingsCubit(prefs);

      expect(cubit.state.themeMode, AppThemeMode.dark);
      expect(cubit.state.flutterThemeMode, ThemeMode.dark);
      expect(cubit.state.isDarkMode, isTrue);

      await cubit.close();
    });

    test('loads saved theme preference when present in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefKeyThemeMode: 'light',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = SettingsCubit(prefs);

      expect(cubit.state.themeMode, AppThemeMode.light);
      expect(cubit.state.flutterThemeMode, ThemeMode.light);
      expect(cubit.state.isDarkMode, isFalse);

      await cubit.close();
    });

    test('updateThemeMode updates state and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = SettingsCubit(prefs);

      expect(cubit.state.themeMode, AppThemeMode.dark);

      cubit.updateThemeMode(AppThemeMode.light);
      expect(cubit.state.themeMode, AppThemeMode.light);
      expect(cubit.state.flutterThemeMode, ThemeMode.light);
      expect(prefs.getString(AppConstants.prefKeyThemeMode), 'light');

      cubit.updateThemeMode(AppThemeMode.dark);
      expect(cubit.state.themeMode, AppThemeMode.dark);
      expect(cubit.state.flutterThemeMode, ThemeMode.dark);
      expect(prefs.getString(AppConstants.prefKeyThemeMode), 'dark');

      await cubit.close();
    });
  });
}
