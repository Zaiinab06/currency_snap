import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../../converter/data/datasources/currency_cache_datasource.dart';
import '../../../converter/presentation/bottom_sheets/currency_picker_sheet.dart';
import '../../../converter/presentation/cubit/convert_cubit.dart';
import '../../../converter/presentation/cubit/convert_state.dart';
import '../widgets/rate_chart_widget.dart';

/// Screen displaying comprehensive exchange rates, interactive charts, and analytics with Deep Plum & Neon Glow reactivity.
class RatesScreen extends StatefulWidget {
  final String? initialFromCurrency;
  final String? initialToCurrency;

  const RatesScreen({
    super.key,
    this.initialFromCurrency,
    this.initialToCurrency,
  });

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  String? _selectedFrom;
  String? _selectedTo;
  String? _lastConvertCubitFrom;
  String? _lastConvertCubitTo;
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

  @override
  void initState() {
    super.initState();
    if (widget.initialFromCurrency != null &&
        widget.initialToCurrency != null) {
      _selectedFrom = widget.initialFromCurrency;
      _selectedTo = widget.initialToCurrency;
      _lastConvertCubitFrom = widget.initialFromCurrency;
      _lastConvertCubitTo = widget.initialToCurrency;
    } else {
      final convertState = context.read<ConvertCubit>().state;
      if (convertState is ConvertLoaded) {
        _selectedFrom = convertState.fromCurrency;
        _selectedTo = convertState.toCurrency;
        _lastConvertCubitFrom = convertState.fromCurrency;
        _lastConvertCubitTo = convertState.toCurrency;
      } else {
        _selectedFrom = 'USD';
        _selectedTo = 'EUR';
      }
    }
  }

  void _pickCurrency({
    required bool isSource,
    required Set<String> availableCodes,
  }) async {
    final currentCode = (isSource ? _selectedFrom : _selectedTo) ??
        (isSource ? 'USD' : 'EUR');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final scaffoldBg =
        isLight ? theme.scaffoldBackgroundColor : AppColors.scaffoldBackground;
    final surfaceColor =
        isLight ? Colors.white : AppColors.darkCardSurface;
    final surfaceAlt = isLight
        ? theme.colorScheme.surfaceContainerHighest
        : AppColors.darkInputBox;
    final primaryColor = AppColors.neonPurple;
    final primaryLightColor = AppColors.neonPink;
    final borderColor = isLight
        ? Colors.black.withValues(alpha: 0.06)
        : AppColors.darkBorder;
    final labelMutedColor =
        isLight ? const Color(0xFF64748B) : AppColors.textSecondary;

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: const Icon(CupertinoIcons.chevron_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          'Rates & Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.4,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocConsumer<ConvertCubit, ConvertState>(
        listener: (context, state) {
          if (state is ConvertLoaded) {
            if (_lastConvertCubitFrom != state.fromCurrency ||
                _lastConvertCubitTo != state.toCurrency) {
              _lastConvertCubitFrom = state.fromCurrency;
              _lastConvertCubitTo = state.toCurrency;
              setState(() {
                _selectedFrom = state.fromCurrency;
                _selectedTo = state.toCurrency;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is! ConvertLoaded) {
            return Center(
              child: CircularProgressIndicator(color: primaryLightColor),
            );
          }

          final activeFrom = _selectedFrom ?? state.fromCurrency;
          final activeTo = _selectedTo ?? state.toCurrency;

          final unitRate = state.rates.convertBetween(
                fromCurrency: activeFrom,
                toCurrency: activeTo,
                amount: 1.0,
              ) ??
              1.0;

          final selectedTimeframe = _timeframes[_selectedTimeframeIndex];
          List<double> timeframeSpots = [];
          try {
            timeframeSpots =
                di.sl<CurrencyCacheDataSource>().getHistoricalPoints(
                      fromCurrency: activeFrom,
                      toCurrency: activeTo,
                      timeframe: selectedTimeframe,
                      currentRate: unitRate,
                    );
          } catch (_) {
            timeframeSpots = [unitRate, unitRate];
          }

          final highRate = timeframeSpots.reduce((a, b) => a > b ? a : b);
          final lowRate = timeframeSpots.reduce((a, b) => a < b ? a : b);
          final avgRate =
              timeframeSpots.reduce((a, b) => a + b) / timeframeSpots.length;

          final firstRate = timeframeSpots.first;
          final delta = firstRate > 0
              ? double.parse(
                  (((unitRate - firstRate) / firstRate) * 100.0)
                      .toStringAsFixed(2),
                )
              : 0.0;
          final isPositive = delta >= 0;

          final highTitle = switch (selectedTimeframe) {
            '24H' => '24h High',
            '7D' => '7d High',
            '1M' => '30d High',
            '1Y' => '52w High',
            _ => 'High',
          };

          final lowTitle = switch (selectedTimeframe) {
            '24H' => '24h Low',
            '7D' => '7d Low',
            '1M' => '30d Low',
            '1Y' => '52w Low',
            _ => 'Low',
          };

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Quick Pair Selector Pills
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _quickPairs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final pair = _quickPairs[index];
                      final isSelected =
                          pair.$1 == activeFrom && pair.$2 == activeTo;
                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
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
                            color: isSelected ? primaryColor : surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? primaryLightColor
                                  : borderColor,
                            ),
                          ),
                          child: Text(
                            '${pair.$1}/${pair.$2}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected ? Colors.white : labelMutedColor,
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
                  decoration: !isLight
                      ? AppColors.neonCardDecoration(
                          color: surfaceColor,
                          borderColor: borderColor,
                          glow: true,
                          borderRadius: 22,
                        )
                      : BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(22),
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
                                    code: activeFrom,
                                    surfaceAlt: surfaceAlt,
                                    borderColor: borderColor,
                                    onTap: () => _pickCurrency(
                                      isSource: true,
                                      availableCodes:
                                          state.rates.rates.keys.toSet(),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(
                                      CupertinoIcons.arrow_right,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  _buildFlagPill(
                                    code: activeTo,
                                    surfaceAlt: surfaceAlt,
                                    borderColor: borderColor,
                                    onTap: () => _pickCurrency(
                                      isSource: false,
                                      availableCodes:
                                          state.rates.rates.keys.toSet(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '1 $activeFrom = ${unitRate > 100 ? unitRate.toStringAsFixed(2) : unitRate.toStringAsFixed(4)} $activeTo',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                                  ? AppColors.deltaPositive
                                      .withValues(alpha: 0.18)
                                  : AppColors.deltaNegative
                                      .withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive
                                      ? CupertinoIcons.arrow_up_right
                                      : CupertinoIcons.arrow_down_right,
                                  size: 14,
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
                          color: surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: List.generate(_timeframes.length, (i) {
                            final isSel = _selectedTimeframeIndex == i;
                            return Expanded(
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedTimeframeIndex = i);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _timeframes[i],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSel
                                            ? FontWeight.w800
                                            : FontWeight.w600,
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
                        fromCurrency: activeFrom,
                        toCurrency: activeTo,
                        currentRate: unitRate,
                        timeframe: selectedTimeframe,
                        customPoints: timeframeSpots,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Analytics & Statistics Grid
                Text(
                  'MARKET METRICS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: labelMutedColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context: context,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        title: highTitle,
                        value: highRate > 100
                            ? highRate.toStringAsFixed(2)
                            : highRate.toStringAsFixed(4),
                        icon: CupertinoIcons.arrow_up,
                        accentColor: AppColors.deltaPositive,
                        isDark: !isLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        context: context,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        title: lowTitle,
                        value: lowRate > 100
                            ? lowRate.toStringAsFixed(2)
                            : lowRate.toStringAsFixed(4),
                        icon: CupertinoIcons.arrow_down,
                        accentColor: AppColors.deltaNegative,
                        isDark: !isLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context: context,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        title: 'Average Rate',
                        value: avgRate > 100
                            ? avgRate.toStringAsFixed(2)
                            : avgRate.toStringAsFixed(4),
                        icon: CupertinoIcons.waveform_path_ecg,
                        accentColor: primaryLightColor,
                        isDark: !isLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        context: context,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        title: 'Current Rate',
                        value: unitRate > 100
                            ? unitRate.toStringAsFixed(2)
                            : unitRate.toStringAsFixed(4),
                        icon: CupertinoIcons.bolt_fill,
                        accentColor: primaryLightColor,
                        isDark: !isLight,
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

  Widget _buildFlagPill({
    required String code,
    required Color surfaceAlt,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final flagCode = FlagCode.fromCurrencyCode(code);
    final countryCode = kCurrencyData[code]?.countryCode ??
        code.substring(0, code.length > 2 ? 2 : code.length);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
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
                    : CountryFlag.fromCountryCode(countryCode,
                        shape: const Circle()),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required Color surfaceColor,
    required Color borderColor,
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              border: Border.all(color: borderColor),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Icon(icon, size: 14, color: accentColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
