import '../entities/currency_rate_entity.dart';

/// Abstract domain contract for currency rate operations.
abstract class ConverterRepository {
  /// Retrieves exchange rates for [baseCurrency], optionally forcing a network refresh.
  Future<RateResultEntity> getRates(
    String baseCurrency, {
    bool forceRefresh = false,
  });

  /// Clears local rate cache.
  Future<void> clearCache();
}
