import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/historical_rate_point.dart';

/// Wise/Revolut-grade precision chart widget built strictly from an authentic RatePoint dataset.
class RateChartWidget extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final List<RatePoint> ratePoints;
  final String timeframe;

  const RateChartWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.ratePoints,
    this.timeframe = '7D',
  });

  /// Constructs exact spots list with 1-to-1 index mapping from authentic ratePoints.
  static List<FlSpot> buildSpots(List<RatePoint> points) {
    if (points.isEmpty) return [];
    return points.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.rate,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final borderColor = isLight
        ? const Color(0xFFF3F4F6)
        : theme.dividerColor;
    final labelMutedColor = isLight
        ? const Color(0xFF6B7280)
        : theme.colorScheme.onSurfaceVariant;

    final spots = buildSpots(ratePoints);
    if (spots.isEmpty) {
      return const SizedBox.shrink();
    }

    final ratesValues = ratePoints.map((p) => p.rate).toList();
    final minRate = ratesValues.reduce((a, b) => a < b ? a : b);
    final maxRate = ratesValues.reduce((a, b) => a > b ? a : b);
    final delta = maxRate - minRate;
    final padding = delta == 0
        ? (minRate == 0 ? 0.02 : minRate * 0.02)
        : delta * 0.25;
    final minY = minRate - padding;
    final maxY = maxRate + padding;

    // Evenly spaced step intervals across 4 grid zones
    const stepCount = 4;
    final yInterval = (maxY - minY) / stepCount;

    return AspectRatio(
      aspectRatio: 1.75,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchSpotThreshold: 20,
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: const Color(0xFF7B5CFF).withValues(alpha: 0.7),
                    strokeWidth: 1.5,
                    dashArray: const [4, 4],
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 5.5,
                      color: Colors.white,
                      strokeWidth: 2.5,
                      strokeColor: const Color(0xFFFF3366),
                    ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => isLight
                  ? const Color(0xFF111827)
                  : const Color(0xFF1F2937),
              tooltipBorder: BorderSide(
                color: const Color(0xFF7B5CFF).withValues(alpha: 0.4),
                width: 1.0,
              ),
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= ratePoints.length) {
                    return null;
                  }
                  final rateModel = ratePoints[index];
                  return LineTooltipItem(
                    '${rateModel.formattedTimestamp}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '1 $fromCurrency = ${CurrencyFormatter.formatRateDynamic(spot.y)} $toCurrency',
                        style: const TextStyle(
                          color: Color(0xFFE5E7EB),
                          fontWeight: FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: borderColor,
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                interval: yInterval,
                getTitlesWidget: (value, meta) {
                  if (value <= meta.min || value >= meta.max) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      CurrencyFormatter.formatRateDynamic(value),
                      style: TextStyle(
                        fontSize: 10,
                        color: labelMutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= ratePoints.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      ratePoints[index].formattedShortDate,
                      style: TextStyle(
                        fontSize: 10,
                        color: labelMutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 1.8,
              isStrokeCapRound: false,
              gradient: const LinearGradient(
                colors: [Color(0xFF7B5CFF), Color(0xFFFF3366)],
              ),
              shadow: Shadow(
                color: const Color(0xFF7B5CFF)
                    .withValues(alpha: isLight ? 0.20 : 0.40),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) =>
                    spot.x == (spots.length - 1).toDouble(),
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 4.5,
                  color: const Color(0xFFFF3366),
                  strokeWidth: 2,
                  strokeColor: isLight ? Colors.white : const Color(0xFF160F23),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7B5CFF).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
