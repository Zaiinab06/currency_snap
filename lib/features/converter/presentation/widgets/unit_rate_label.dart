import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/currency_rate_entity.dart';

/// Displays the plain unit rate for the current pair, e.g.
/// "1 EUR = 324.457 PKR".
class UnitRateLabel extends StatelessWidget {
  final CurrencyRateEntity rates;
  final String fromCurrency;
  final String toCurrency;

  const UnitRateLabel({
    super.key,
    required this.rates,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final unitRate = rates.convertBetween(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: 1,
    );

    if (unitRate == null) return const SizedBox.shrink();

    return Text(
      '1 $fromCurrency = ${unitRate.toStringAsFixed(3)} $toCurrency',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
    );
  }
}
