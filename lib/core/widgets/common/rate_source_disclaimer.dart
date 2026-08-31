import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class RateSourceDisclaimer extends StatelessWidget {
  const RateSourceDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Rates provided by ExchangeRate-API · Mid-market reference',
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
    );
  }
}
