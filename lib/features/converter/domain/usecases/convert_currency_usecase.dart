import '../entities/currency_rate_entity.dart';

/// Pure domain use case to calculate converted currency amounts using rate cross-multiplication.
class ConvertCurrencyUseCase {
  const ConvertCurrencyUseCase();

  double? call({
    required CurrencyRateEntity rates,
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) {
    return rates.convertBetween(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
    );
  }
}
