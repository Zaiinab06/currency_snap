import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/rates_cubit.dart';
import '../cubit/rates_state.dart';
import '../widgets/market_metrics_card.dart';
import '../widgets/rate_chart_widget.dart';
import '../widgets/rates_error_widget.dart';

/// Screen displaying interactive 7-day rate trend and dynamic high/low stats based on real API time-series points.
class HistoricalRateChartScreen extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double currentRate;

  const HistoricalRateChartScreen({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.currentRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isDark = !isLight;
    final scaffoldBg =
        isLight ? const Color(0xFFF9FAFB) : AppColors.scaffoldBackground;
    final surfaceColor =
        isLight ? Colors.white : AppColors.darkCardSurface;
    final cardBorderColor = isLight
        ? const Color(0xFFF3F4F6)
        : AppColors.darkBorder;
    final labelMutedColor =
        isLight ? const Color(0xFF6B7280) : AppColors.textSecondary;

    return BlocProvider(
      create: (context) => di.sl<RatesCubit>()
        ..loadHistoricalRates(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          timeframe: '7D',
          currentRate: currentRate,
        ),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.chevron_back,
              color: isLight ? const Color(0xFF111827) : Colors.white,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            '$fromCurrency to $toCurrency Trend',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: -0.4,
              color: isLight ? const Color(0xFF111827) : Colors.white,
            ),
          ),
        ),
        body: BlocBuilder<RatesCubit, RatesState>(
          builder: (context, state) {
            if (state is RatesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF4B72)),
              );
            }

            if (state is RatesError) {
              return RatesErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<RatesCubit>().retry();
                },
              );
            }

            final loadedState = state is HistoricalRatesLoaded
                ? state
                : HistoricalRatesLoaded(
                    ratePoints: const [],
                    fromCurrency: fromCurrency,
                    toCurrency: toCurrency,
                    timeframe: '7D',
                  );

            if (loadedState.rates.isEmpty) {
              return Center(
                child: Text(
                  'No historical rate data available.',
                  style: TextStyle(color: labelMutedColor),
                ),
              );
            }

            final deltaStr =
                '${loadedState.isPositive ? '+' : ''}${loadedState.delta.toStringAsFixed(2)}%';

            return SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: isDark
                        ? AppColors.neonCardDecoration(
                            color: surfaceColor,
                            borderColor: cardBorderColor,
                            glow: true,
                            borderRadius: 20,
                          )
                        : BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: cardBorderColor, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Current Rate',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: labelMutedColor,
                                        ),
                                      ),
                                      if (loadedState.isCached) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: isLight
                                                ? const Color(0xFFFEF3C7)
                                                : const Color(0xFFD97706)
                                                    .withValues(alpha: 0.22),
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                            border: Border.all(
                                              color: isLight
                                                  ? const Color(0xFFFDE68A)
                                                  : const Color(0xFFD97706)
                                                      .withValues(alpha: 0.40),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 6.0,
                                                height: 6.0,
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Color(0xFFD97706),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4.0),
                                              Text(
                                                'Offline Mode',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: isLight
                                                      ? const Color(0xFFD97706)
                                                      : const Color(0xFFFBBF24),
                                                  letterSpacing: -0.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '1 $fromCurrency = ${CurrencyFormatter.formatRateDynamic(loadedState.current)} $toCurrency',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                        color: isLight
                                            ? const Color(0xFF111827)
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: loadedState.isPositive
                                      ? AppColors.deltaPositive
                                          .withValues(alpha: 0.18)
                                      : AppColors.deltaNegative
                                          .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      loadedState.isPositive
                                          ? CupertinoIcons.arrow_up_right
                                          : CupertinoIcons.arrow_down_right,
                                      size: 14,
                                      color: loadedState.isPositive
                                          ? AppColors.deltaPositive
                                          : AppColors.deltaNegative,
                                    ),
                                    const SizedBox(width: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        deltaStr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: loadedState.isPositive
                                              ? AppColors.deltaPositive
                                              : AppColors.deltaNegative,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        RateChartWidget(
                          fromCurrency: fromCurrency,
                          toCurrency: toCurrency,
                          ratePoints: loadedState.ratePoints,
                          timeframe: '7D',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: MarketMetricsCard(
                          title: '7D High',
                          value: CurrencyFormatter.formatRateDynamic(
                              loadedState.high),
                          accentColor: AppColors.deltaPositive,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MarketMetricsCard(
                          title: '7D Low',
                          value: CurrencyFormatter.formatRateDynamic(
                              loadedState.low),
                          accentColor: AppColors.deltaNegative,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
