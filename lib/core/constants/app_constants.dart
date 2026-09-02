/// Application-wide constants including API configuration, storage keys, and defaults.
class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = 'https://open.er-api.com/v6/latest';
  static const String frankfurterBaseUrl = 'https://api.frankfurter.app';
  static const String jsdelivrApiBaseUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api';
  static const Duration apiTimeout = Duration(seconds: 10);

  static const String cacheKeyRates = 'cached_rates';
  static const String cacheKeyPreviousRates = 'cached_previous_rates';
  static const String cacheKeyRateSnapshots = 'cached_rate_snapshots';
  static const String cacheKeyTimestamp = 'cached_rates_timestamp';
  static const String cacheKeyBaseCurrency = 'cached_base_currency';
  static const String prefKeyFavorites = 'favorite_pairs';
  static const String prefKeyHistory = 'conversion_history';
  static const String prefKeyDefaultCurrency = 'default_currency';
  static const String prefKeyDefaultTargetCurrency = 'default_target_currency';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyUserDisplayName = 'user_display_name';

  static const String defaultBaseCurrency = 'USD';
  static const String defaultTargetCurrency = 'PKR';
  static const String defaultThemeMode = 'light';

  static const String appName = 'CurrencySnap';
  static const String appTagline = 'Convert smarter, wherever you are.';
}
