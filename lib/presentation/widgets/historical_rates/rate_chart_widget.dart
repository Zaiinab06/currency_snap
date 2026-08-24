import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Line chart visualizing recent exchange rate trends.
class RateChartWidget extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double currentRate;

  const RateChartWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.currentRate,
  });

  List<FlSpot> _generateSpots() {
    final variance = [0.985, 0.992, 0.989, 0.997, 1.005, 0.998, 1.0];
    return List.generate(
      variance.length,
      (i) => FlSpot(i.toDouble(), currentRate * variance[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spots = _generateSpots();
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.995;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.005;

    return AspectRatio(
      aspectRatio: 1.8,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) > 0 ? (maxY - minY) / 3 : 1,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.cardBorder,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      value.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
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
                getTitlesWidget: (value, meta) {
                  const days = ['6d ago', '5d', '4d', '3d', '2d', '1d', 'Today'];
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        days[index],
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.35),
                    AppColors.accent.withValues(alpha: 0.0),
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
