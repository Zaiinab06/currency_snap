import '../../domain/entities/currency_rate_entity.dart';

/// Data model representing currency rates, extending [CurrencyRateEntity] with JSON serialization.
class CurrencyRateModel extends CurrencyRateEntity {
  const CurrencyRateModel({
    required super.baseCurrency,
    required super.rates,
    required super.lastUpdated,
  });

  /// Build from the raw API JSON response.
  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    DateTime timestamp;
    if (json.containsKey('time_last_update_unix')) {
      final unixSeconds = json['time_last_update_unix'] as num?;
      if (unixSeconds != null) {
        timestamp = DateTime.fromMillisecondsSinceEpoch(
          unixSeconds.toInt() * 1000,
          isUtc: true,
        ).toLocal();
      } else {
        timestamp = DateTime.now();
      }
    } else if (json.containsKey('lastUpdated')) {
      timestamp = DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now();
    } else {
      timestamp = DateTime.now();
    }

    return CurrencyRateModel(
      baseCurrency: json['base_code'] as String? ?? json['baseCurrency'] as String? ?? 'USD',
      rates: rawRates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      lastUpdated: timestamp,
    );
  }

  /// Build from a locally cached JSON blob.
  factory CurrencyRateModel.fromCacheJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final lastUpdatedStr = json['lastUpdated'] as String?;
    final lastUpdated = lastUpdatedStr != null
        ? (DateTime.tryParse(lastUpdatedStr) ?? DateTime.now())
        : DateTime.now();

    return CurrencyRateModel(
      baseCurrency: json['baseCurrency'] as String? ?? json['base_code'] as String? ?? 'USD',
      rates: rawRates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      lastUpdated: lastUpdated,
    );
  }

  /// Create model from domain entity.
  factory CurrencyRateModel.fromEntity(CurrencyRateEntity entity) {
    return CurrencyRateModel(
      baseCurrency: entity.baseCurrency,
      rates: entity.rates,
      lastUpdated: entity.lastUpdated,
    );
  }

  /// Serialize for local caching.
  Map<String, dynamic> toCacheJson() {
    return {
      'baseCurrency': baseCurrency,
      'rates': rates,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
