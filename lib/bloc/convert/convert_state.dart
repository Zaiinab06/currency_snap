import 'package:equatable/equatable.dart';
import '../../data/models/currency_rate_model.dart';

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
  final CurrencyRateModel rates;
  final bool isFromCache;
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double? convertedAmount;

  const ConvertLoaded({
    required this.rates,
    required this.isFromCache,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.convertedAmount,
  });

  /// The direct exchange rate from [fromCurrency] to [toCurrency].
  double? get currentRate => rates.rates[toCurrency];

  ConvertLoaded copyWith({
    CurrencyRateModel? rates,
    bool? isFromCache,
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    double? convertedAmount,
  }) {
    return ConvertLoaded(
      rates: rates ?? this.rates,
      isFromCache: isFromCache ?? this.isFromCache,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
    );
  }

  @override
  List<Object?> get props => [
    rates,
    isFromCache,
    fromCurrency,
    toCurrency,
    amount,
    convertedAmount,
  ];
}

/// State indicating a failure to load exchange rates.
class ConvertError extends ConvertState {
  final String message;
  const ConvertError(this.message);

  @override
  List<Object?> get props => [message];
}
