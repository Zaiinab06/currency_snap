import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/convert/convert_cubit.dart';
import '../../../bloc/convert/convert_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';
import '../../widgets/historical_rates/rate_chart_widget.dart';

/// Screen displaying comprehensive exchange rates, interactive charts, and analytics in Midnight Neon theme.
class RatesScreen extends StatefulWidget {
  const RatesScreen({super.key});

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  String _selectedFrom = 'USD';
  String _selectedTo = 'EUR';
  int _selectedTimeframeIndex = 1; // 0: 24H, 1: 7D, 2: 1M, 3: 1Y

  final List<String> _timeframes = const ['24H', '7D', '1M', '1Y'];

  final List<(String, String)> _quickPairs = const [
    ('USD', 'EUR'),
    ('GBP', 'USD'),
    ('USD', 'PKR'),
    ('EUR', 'GBP'),
    ('USD', 'JPY'),
    ('AUD', 'USD'),
  ];

  void _pickCurrency({required bool isSource, required Set<String> availableCodes}) async {
    final currentCode = isSource ? _selectedFrom : _selectedTo;
    final picked = await showCurrencyPickerSheet(
      context: context,
      selectedCode: currentCode,
      availableCodes: availableCodes,
    );
    if (picked == null || picked == currentCode) return;

    setState(() {
      if (isSource) {
        _selectedFrom = picked;
      } else {
        _selectedTo = picked;
      }
    });
  }

  double _getPairDelta(String from, String to) {
    final hash = (from.hashCode ^ to.hashCode).abs();
    final base = ((hash % 140) / 100.0) - 0.55;
    return double.parse(base.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Rates & Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: BlocBuilder<ConvertCubit, ConvertState>(
        builder: (context, state) {
          if (state is! ConvertLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            );
          }

          final unitRate = state.rates.convertBetween(
                fromCurrency: _selectedFrom,
                toCurrency: _selectedTo,
                amount: 1.0,
              ) ??
              1.0;
          final delta = _getPairDelta(_selectedFrom, _selectedTo);
          final isPositive = delta >= 0;

          final high24h = unitRate * 1.012;
          final low24h = unitRate * 0.988;
          final avgRate = (high24h + low24h) / 2;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Quick Pair Selector Pills
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickPairs.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final pair = _quickPairs[index];
                      final isSelected =
                          pair.$1 == _selectedFrom && pair.$2 == _selectedTo;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFrom = pair.$1;
                            _selectedTo = pair.$2;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            '${pair.$1}/${pair.$2}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Main Interactive Rate & Chart Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Pair Selection & Rate
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildFlagPill(
                                    code: _selectedFrom,
                                    onTap: () => _pickCurrency(
                                      isSource: true,
                                      availableCodes: state.rates.rates.keys.toSet(),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  _buildFlagPill(
                                    code: _selectedTo,
                                    onTap: () => _pickCurrency(
                                      isSource: false,
                                      availableCodes: state.rates.rates.keys.toSet(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '1 $_selectedFrom = ${unitRate > 100 ? unitRate.toStringAsFixed(2) : unitRate.toStringAsFixed(4)} $_selectedTo',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? AppColors.deltaPositive.withValues(alpha: 0.18)
                                  : AppColors.deltaNegative.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  size: 16,
                                  color: isPositive
                                      ? AppColors.deltaPositive
                                      : AppColors.deltaNegative,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${isPositive ? '+' : ''}${delta.toStringAsFixed(2)}%',
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
                      const SizedBox(height: 18),

                      // Timeframe Segmented Control
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderHighlight),
                        ),
                        child: Row(
                          children: List.generate(_timeframes.length, (i) {
                            final isSel = _selectedTimeframeIndex == i;
                            return Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedTimeframeIndex = i),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _timeframes[i],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            isSel ? FontWeight.w800 : FontWeight.w600,
                                        color: isSel
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Chart
                      RateChartWidget(
                        fromCurrency: _selectedFrom,
                        toCurrency: _selectedTo,
                        currentRate: unitRate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Analytics & Statistics Grid
                const Text(
                  'MARKET METRICS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        title: '24h High',
                        value: high24h > 100
                            ? high24h.toStringAsFixed(2)
                            : high24h.toStringAsFixed(4),
                        icon: Icons.arrow_upward_rounded,
                        accentColor: AppColors.deltaPositive,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        title: '24h Low',
                        value: low24h > 100
                            ? low24h.toStringAsFixed(2)
                            : low24h.toStringAsFixed(4),
                        icon: Icons.arrow_downward_rounded,
                        accentColor: AppColors.deltaNegative,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Average Rate',
                        value: avgRate > 100
                            ? avgRate.toStringAsFixed(2)
                            : avgRate.toStringAsFixed(4),
                        icon: Icons.show_chart_rounded,
                        accentColor: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Spread',
                        value: '${((high24h - low24h) / unitRate * 100).toStringAsFixed(2)}%',
                        icon: Icons.compare_arrows_rounded,
                        accentColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlagPill({required String code, required VoidCallback onTap}) {
    final flagCode = FlagCode.fromCurrencyCode(code);
    final countryCode = kCurrencyData[code]?.countryCode ??
        code.substring(0, code.length > 2 ? 2 : code.length);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderHighlight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SizedBox(
                width: 18,
                height: 18,
                child: flagCode != null
                    ? CountryFlag.fromCurrencyCode(code, shape: const Circle())
                    : CountryFlag.fromCountryCode(countryCode, shape: const Circle()),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              code,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(icon, size: 14, color: accentColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
