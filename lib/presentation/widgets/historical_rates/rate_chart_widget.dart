import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Line chart visualizing recent exchange rate trends with dynamic theme glowing gradient styling.
class RateChartWidget extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double currentRate;
  final String timeframe;

  const RateChartWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.currentRate,
    this.timeframe = '7D',
  });

  /// Provides timeframe-specific percentage variance points to build realistic trend curves.
  static List<double> getVariance(String timeframe) {
    switch (timeframe) {
      case '24H':
        return const [0.998, 0.999, 1.003, 0.997, 1.0];
      case '1M':
        return const [0.978, 0.992, 1.018, 0.988, 1.0];
      case '1Y':
        return const [0.945, 0.970, 1.045, 0.965, 1.0];
      case '7D':
      default:
        return const [0.985, 0.992, 0.989, 0.997, 1.005, 0.998, 1.0];
    }
  }

  /// Returns localized and formatted X-axis markers for the active timeframe.
  static List<String> getXAxisLabels(String timeframe) {
    switch (timeframe) {
      case '24H':
        return const ['00:00', '06:00', '12:00', '18:00', 'Now'];
      case '1M':
        return const ['4w ago', '3w ago', '2w ago', '1w ago', 'Today'];
      case '1Y':
        return const ['Jan', 'Apr', 'Jul', 'Oct', 'Now'];
      case '7D':
      default:
        return const ['6d ago', '5d', '4d', '3d', '2d', '1d', 'Today'];
    }
  }

  List<FlSpot> _generateSpots() {
    final variance = getVariance(timeframe);
    return List.generate(
      variance.length,
      (i) => FlSpot(i.toDouble(), currentRate * variance[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;
    final primaryLightColor = theme.colorScheme.secondary;
    final borderColor = isLight
        ? Colors.black.withValues(alpha: 0.06)
        : theme.dividerColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final labelMutedColor = isLight
        ? const Color(0xFF64748B)
        : theme.colorScheme.onSurfaceVariant;

    final spots = _generateSpots();
    final rawMinY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final rawMaxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final diff = rawMaxY - rawMinY;
    final padding = diff > 0 ? diff * 0.15 : (currentRate * 0.01);
    final minY = rawMinY - padding;
    final maxY = rawMaxY + padding;
    final range = maxY - minY;
    // Step calculation to ensure distinct, non-overlapping Y-axis grid lines
    final step = range > 0 ? (range / 3) : 1.0;

    return AspectRatio(
      aspectRatio: 1.75,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF14152D),
              tooltipBorder: BorderSide(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.5),
                width: 1.2,
              ),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) {
                final labels = getXAxisLabels(timeframe);
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final timeLabel = (index >= 0 && index < labels.length) ? labels[index] : '';
                  final formattedRate = spot.y > 100
                      ? spot.y.toStringAsFixed(2)
                      : spot.y.toStringAsFixed(4);

                  return LineTooltipItem(
                    '$timeLabel\n',
                    const TextStyle(
                      color: Color(0xFF8E8EA9),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: '1 $fromCurrency = $formattedRate $toCurrency',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
            touchSpotThreshold: 10,
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.6),
                    strokeWidth: 1.5,
                    dashArray: const [4, 4],
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 5.5,
                      color: Colors.white,
                      strokeWidth: 2.5,
                      strokeColor: const Color(0xFF6C5CE7),
                    ),
                  ),
                );
              }).toList();
            },
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: step,
            getDrawingHorizontalLine: (value) => FlLine(
              color: borderColor,
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                interval: step,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      value > 100
                          ? value.toStringAsFixed(1)
                          : value.toStringAsFixed(3),
                      style: TextStyle(
                        fontSize: 10,
                        color: labelMutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1.0,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  // Strictly prevent sub-step or duplicate rendering
                  if (value != index.toDouble()) {
                    return const SizedBox.shrink();
                  }

                  final labels = getXAxisLabels(timeframe);
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }

                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 11,
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
              isCurved: true,
              curveSmoothness: 0.35,
              gradient: LinearGradient(
                colors: [primaryColor, primaryLightColor],
              ),
              shadow: Shadow(
                color: primaryColor.withValues(alpha: isLight ? 0.3 : 0.6),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              barWidth: 3.2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) => spot.x == (spots.length - 1).toDouble(),
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 5,
                  color: primaryLightColor,
                  strokeWidth: 2,
                  strokeColor: isLight ? Colors.white : theme.cardColor,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: isLight ? 0.25 : 0.4),
                    primaryLightColor.withValues(alpha: isLight ? 0.08 : 0.15),
                    bgColor.withValues(alpha: 0.0),
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
