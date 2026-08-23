/// App-wide constants — API config, storage keys, and durations.
/// Keep magic strings/numbers out of the rest of the codebase.
class AppConstants {
  AppConstants._();

  // --- API ---
  // Free tier: https://www.exchangerate-api.com/
  static const String apiBaseUrl =
      'https://open.er-api.com/v6/latest'; // append /{baseCurrency}
  static const Duration apiTimeout = Duration(seconds: 10);

  // --- Local storage keys (SharedPreferences) ---
  static const String cacheKeyRates = 'cached_rates';
  static const String cacheKeyTimestamp = 'cached_rates_timestamp';
  static const String cacheKeyBaseCurrency = 'cached_base_currency';
  static const String prefKeyFavorites = 'favorite_pairs';
  static const String prefKeyDefaultCurrency = 'default_currency';
  static const String prefKeyThemeMode = 'theme_mode';

  // --- Defaults ---
  static const String defaultBaseCurrency = 'USD';
  static const String defaultTargetCurrency = 'PKR';

  // --- App info ---
  static const String appName = 'CurrencySnap';
  static const String appTagline = 'Convert smarter, wherever you are.';
}
