import 'package:equatable/equatable.dart';
import '../../domain/entities/currency_rate_entity.dart';

/// Base state for currency conversion.
abstract class ConvertState extends Equatable {
  const ConvertState();

  @override
  List<Object?> get props => [];
}

/// Initial state prior to fetching exchange rates.
class ConvertInitial extends ConvertState {
  const ConvertInitial();
}

/// State indicating exchange rates are currently loading.
class ConvertLoading extends ConvertState {
  const ConvertLoading();
}

/// State representing successfully loaded exchange rates and conversion calculations.
class ConvertLoaded extends ConvertState {
  final CurrencyRateEntity rates;
  final CurrencyRateEntity? previousRates;
  final bool isFromCache;
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double? convertedAmount;
  final bool isRefreshing;
  final DateTime lastSyncTime;

  DateTime get lastUpdated => lastSyncTime;

  ConvertLoaded({
    required this.rates,
    this.previousRates,
    required this.isFromCache,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.convertedAmount,
    this.isRefreshing = false,
    DateTime? lastSyncTime,
    DateTime? lastUpdated,
  }) : lastSyncTime = lastSyncTime ?? lastUpdated ?? rates.lastUpdated;

  /// The direct exchange rate from [fromCurrency] to [toCurrency].
  double? get currentRate => rates.rates[toCurrency];

  ConvertLoaded copyWith({
    CurrencyRateEntity? rates,
    CurrencyRateEntity? previousRates,
    bool? isFromCache,
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    double? convertedAmount,
    bool? isRefreshing,
    DateTime? lastSyncTime,
    DateTime? lastUpdated,
  }) {
    return ConvertLoaded(
      rates: rates ?? this.rates,
      previousRates: previousRates ?? this.previousRates,
      isFromCache: isFromCache ?? this.isFromCache,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastSyncTime: lastSyncTime ?? lastUpdated ?? this.lastSyncTime,
    );
  }

  @override
  List<Object?> get props => [
        rates,
        previousRates,
        isFromCache,
        fromCurrency,
        toCurrency,
        amount,
        convertedAmount,
        isRefreshing,
        lastSyncTime,
      ];
}

/// State indicating a failure to load exchange rates.
class ConvertError extends ConvertState {
  final String message;
  const ConvertError(this.message);

  @override
  List<Object?> get props => [message];
}
