import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../../converter/data/datasources/currency_cache_datasource.dart';
import '../widgets/rate_chart_widget.dart';

/// Screen displaying interactive 7-day rate trend and dynamic high/low stats based on real rate points.
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
        isLight ? theme.scaffoldBackgroundColor : AppColors.scaffoldBackground;
    final surfaceColor =
        isLight ? Colors.white : AppColors.darkCardSurface;
    final borderColor = isLight
        ? Colors.black.withValues(alpha: 0.06)
        : AppColors.darkBorder;
    final labelMutedColor =
        isLight ? const Color(0xFF64748B) : AppColors.textSecondary;

    List<double> points = [];
    try {
      points = di.sl<CurrencyCacheDataSource>().getHistoricalPoints(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            timeframe: '7D',
            currentRate: currentRate,
          );
    } catch (_) {
      points = [currentRate, currentRate];
    }

    final high = points.reduce((a, b) => a > b ? a : b);
    final low = points.reduce((a, b) => a < b ? a : b);
    final firstRate = points.first;
    final deltaPercent = firstRate > 0
        ? ((currentRate - firstRate) / firstRate) * 100.0
        : 0.0;
    final isPositive = deltaPercent >= 0;
    final deltaStr =
        '${isPositive ? '+' : ''}${deltaPercent.toStringAsFixed(2)}%';

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '$fromCurrency to $toCurrency Trend',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: isDark
                  ? AppColors.neonCardDecoration(
                      color: surfaceColor,
                      borderColor: borderColor,
                      glow: true,
                      borderRadius: 20,
                    )
                  : BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
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
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Rate',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: labelMutedColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1 $fromCurrency = ${currentRate > 100 ? currentRate.toStringAsFixed(2) : currentRate.toStringAsFixed(4)} $toCurrency',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? AppColors.deltaPositive.withValues(alpha: 0.18)
                              : AppColors.deltaNegative.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? CupertinoIcons.arrow_up_right
                                  : CupertinoIcons.arrow_down_right,
                              size: 16,
                              color: isPositive
                                  ? AppColors.deltaPositive
                                  : AppColors.deltaNegative,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              deltaStr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isPositive
                                    ? AppColors.deltaPositive
                                    : AppColors.deltaNegative,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  RateChartWidget(
                    fromCurrency: fromCurrency,
                    toCurrency: toCurrency,
                    currentRate: currentRate,
                    customPoints: points,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    '7D High',
                    high.toStringAsFixed(currentRate > 100 ? 2 : 4),
                    AppColors.deltaPositive,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    '7D Low',
                    low.toStringAsFixed(currentRate > 100 ? 2 : 4),
                    AppColors.deltaNegative,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    Color accentColor,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final surfaceColor =
        isDark ? AppColors.darkCardSurface : theme.cardColor;
    final borderColor =
        isDark ? AppColors.darkBorder : theme.dividerColor;
    final labelMutedColor = isDark
        ? AppColors.darkTextSecondary
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: isDark
          ? AppColors.neonCardDecoration(
              color: surfaceColor,
              borderColor: borderColor,
              glow: false,
              borderRadius: 16,
            )
          : BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: labelMutedColor,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: -0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
