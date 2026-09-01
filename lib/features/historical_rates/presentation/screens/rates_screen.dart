import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../injection_container.dart' as di;
import '../../../converter/presentation/bottom_sheets/currency_picker_sheet.dart';
import '../../../converter/presentation/cubit/convert_cubit.dart';
import '../../../converter/presentation/cubit/convert_state.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../cubit/rates_cubit.dart';
import '../cubit/rates_state.dart';
import '../widgets/market_metrics_card.dart';
import '../widgets/rate_chart_widget.dart';

/// Screen displaying comprehensive exchange rates, interactive charts, and polished analytics.
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

  static const _pillSelectedGradient = LinearGradient(
    colors: [
      Color(0xFFFF3366), // Vibrant Rose Pink (Left)
      Color(0xFF8B5CF6), // Soft Purple / Indigo (Right)
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

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
      }
    }
  }

  void _pickCurrency({
    required BuildContext context,
    required bool isSource,
    required Set<String> availableCodes,
    required String activeFrom,
    required String activeTo,
  }) async {
    final currentCode = (isSource ? _selectedFrom : _selectedTo) ??
        (isSource ? activeFrom : activeTo);
    final ratesCubit = context.read<RatesCubit>();
    final convertCubit = context.read<ConvertCubit>();
    final picked = await showCurrencyPickerSheet(
      context: context,
      selectedCode: currentCode,
      availableCodes: availableCodes,
    );
    if (!mounted || picked == null || picked == currentCode) return;

    final newFrom = isSource ? picked : activeFrom;
    final newTo = !isSource ? picked : activeTo;

    setState(() {
      if (isSource) {
        _selectedFrom = picked;
      } else {
        _selectedTo = picked;
      }
    });

    final convertState = convertCubit.state;
    final updatedRate = convertState is ConvertLoaded
        ? (convertState.rates.convertBetween(
                fromCurrency: newFrom, toCurrency: newTo, amount: 1.0) ??
            1.0)
        : 1.0;

    // Reset state immediately and fetch new authentic historical dataset
    ratesCubit.loadHistoricalRates(
      fromCurrency: newFrom,
      toCurrency: newTo,
      timeframe: _timeframes[_selectedTimeframeIndex],
      currentRate: updatedRate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final scaffoldBg =
        isLight ? const Color(0xFFF9FAFB) : AppColors.scaffoldBackground;
    final surfaceColor =
        isLight ? Colors.white : AppColors.darkCardSurface;
    final surfaceAlt = isLight
        ? const Color(0xFFF3F4F6)
        : AppColors.darkInputBox;
    final primaryLightColor = const Color(0xFFFF4B72);
    final cardBorderColor = isLight
        ? const Color(0xFFF3F4F6)
        : AppColors.darkBorder;
    final pillUnselectedBorder = isLight
        ? const Color(0xFFE5E7EB)
        : AppColors.darkBorder;
    final labelMutedColor =
        isLight ? const Color(0xFF6B7280) : AppColors.textSecondary;

    final canPop = Navigator.of(context).canPop();

    return BlocProvider(
      create: (context) {
        final cubit = di.sl<RatesCubit>();
        final convertState = context.read<ConvertCubit>().state;
        final from = _selectedFrom ??
            (convertState is ConvertLoaded ? convertState.fromCurrency : 'USD');
        final to = _selectedTo ??
            (convertState is ConvertLoaded ? convertState.toCurrency : 'EUR');
        final unitRate = convertState is ConvertLoaded
            ? (convertState.rates.convertBetween(
                    fromCurrency: from, toCurrency: to, amount: 1.0) ??
                1.0)
            : 1.0;

        cubit.loadHistoricalRates(
          fromCurrency: from,
          toCurrency: to,
          timeframe: _timeframes[_selectedTimeframeIndex],
          currentRate: unitRate,
        );
        return cubit;
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: scaffoldBg,
            appBar: AppBar(
              backgroundColor: scaffoldBg,
              elevation: 0,
              leading: canPop
                  ? IconButton(
                      icon: Icon(
                        CupertinoIcons.chevron_back,
                        color: isLight
                            ? const Color(0xFF111827)
                            : Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    )
                  : null,
              title: Text(
                'Rates & Analytics',
                style: TextStyle(
                  color: isLight ? const Color(0xFF111827) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            body: BlocConsumer<ConvertCubit, ConvertState>(
              listener: (context, convertState) {
                if (convertState is ConvertLoaded) {
                  if (_lastConvertCubitFrom != convertState.fromCurrency ||
                      _lastConvertCubitTo != convertState.toCurrency) {
                    _lastConvertCubitFrom = convertState.fromCurrency;
                    _lastConvertCubitTo = convertState.toCurrency;
                    setState(() {
                      _selectedFrom = convertState.fromCurrency;
                      _selectedTo = convertState.toCurrency;
                    });
                    context.read<RatesCubit>().loadHistoricalRates(
                          fromCurrency: convertState.fromCurrency,
                          toCurrency: convertState.toCurrency,
                          timeframe: _timeframes[_selectedTimeframeIndex],
                          currentRate: convertState.rates.convertBetween(
                            fromCurrency: convertState.fromCurrency,
                            toCurrency: convertState.toCurrency,
                            amount: 1.0,
                          ),
                        );
                  }
                }
              },
              builder: (context, convertState) {
                if (convertState is! ConvertLoaded) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryLightColor),
                  );
                }

                final activeFrom = _selectedFrom ?? convertState.fromCurrency;
                final activeTo = _selectedTo ?? convertState.toCurrency;

                final unitRate = convertState.rates.convertBetween(
                      fromCurrency: activeFrom,
                      toCurrency: activeTo,
                      amount: 1.0,
                    ) ??
                    1.0;

                final selectedTimeframe = _timeframes[_selectedTimeframeIndex];

                // Dynamically assemble quick access pairs strictly from authentic data sources
                final List<(String, String)> dynamicQuickPairs = [];
                final favoritesCubit = di.sl.isRegistered<FavoritesCubit>()
                    ? context.watch<FavoritesCubit?>()
                    : null;
                if (favoritesCubit != null &&
                    favoritesCubit.state.favorites.isNotEmpty) {
                  for (final fav in favoritesCubit.state.favorites) {
                    final p = (fav.fromCurrency, fav.toCurrency);
                    if (!dynamicQuickPairs.contains(p)) {
                      dynamicQuickPairs.add(p);
                    }
                  }
                }

                // Append authentic pairs from live rate table if favorites are few
                final availableKeys = convertState.rates.rates.keys.toList();
                final base = convertState.rates.baseCurrency;
                for (final key in availableKeys) {
                  if (key != base && dynamicQuickPairs.length < 8) {
                    final p = (base, key);
                    if (!dynamicQuickPairs.contains(p)) {
                      dynamicQuickPairs.add(p);
                    }
                  }
                }

                // Ensure currently selected pair is present and accessible
                final activeTuple = (activeFrom, activeTo);
                if (!dynamicQuickPairs.contains(activeTuple)) {
                  dynamicQuickPairs.insert(0, activeTuple);
                }

                return BlocBuilder<RatesCubit, RatesState>(
                  builder: (context, ratesState) {
                    if (ratesState is RatesLoading) {
                      return Center(
                        child:
                            CircularProgressIndicator(color: primaryLightColor),
                      );
                    }

                    if (ratesState is RatesError) {
                      return Center(
                        child: Text(
                          ratesState.message,
                          style: TextStyle(color: labelMutedColor),
                        ),
                      );
                    }

                    final HistoricalRatesLoaded loadedState =
                        ratesState is HistoricalRatesLoaded
                            ? ratesState
                            : HistoricalRatesLoaded(
                                ratePoints: const [],
                                fromCurrency: activeFrom,
                                toCurrency: activeTo,
                                timeframe: selectedTimeframe,
                              );

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
                          // 1. Dynamic Quick Access Pair Selector Pills (Height 34.0)
                          SizedBox(
                            height: 34.0,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: dynamicQuickPairs.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final pair = dynamicQuickPairs[index];
                                final isSelected = pair.$1 == activeFrom &&
                                    pair.$2 == activeTo;
                                return InkWell(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _selectedFrom = pair.$1;
                                      _selectedTo = pair.$2;
                                    });
                                    final pairRate = convertState.rates
                                            .convertBetween(
                                          fromCurrency: pair.$1,
                                          toCurrency: pair.$2,
                                          amount: 1.0,
                                        ) ??
                                        unitRate;
                                    context
                                        .read<RatesCubit>()
                                        .loadHistoricalRates(
                                          fromCurrency: pair.$1,
                                          toCurrency: pair.$2,
                                          timeframe: _timeframes[
                                              _selectedTimeframeIndex],
                                          currentRate: pairRate,
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0,
                                      vertical: 7.0,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? _pillSelectedGradient
                                          : null,
                                      color: isSelected
                                          ? null
                                          : (isLight
                                              ? const Color(0xFFF9FAFB)
                                              : surfaceColor),
                                      borderRadius:
                                          BorderRadius.circular(20.0),
                                      border: isSelected
                                          ? null
                                          : Border.all(
                                              color: pillUnselectedBorder,
                                              width: 1.0,
                                            ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFFF3366)
                                                    .withValues(alpha: 0.35),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${pair.$1}/${pair.$2}',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : labelMutedColor,
                                        ),
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
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with Flag Selector Chips & Rate (Overflow-Proof)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              _buildFlagPill(
                                                code: activeFrom,
                                                isLight: isLight,
                                                surfaceAlt: surfaceAlt,
                                                borderColor:
                                                    pillUnselectedBorder,
                                                onTap: () => _pickCurrency(
                                                  context: context,
                                                  isSource: true,
                                                  availableCodes: convertState
                                                      .rates.rates.keys
                                                      .toSet(),
                                                  activeFrom: activeFrom,
                                                  activeTo: activeTo,
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6),
                                                child: Icon(
                                                  CupertinoIcons.arrow_right,
                                                  size: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              _buildFlagPill(
                                                code: activeTo,
                                                isLight: isLight,
                                                surfaceAlt: surfaceAlt,
                                                borderColor:
                                                    pillUnselectedBorder,
                                                onTap: () => _pickCurrency(
                                                  context: context,
                                                  isSource: false,
                                                  availableCodes: convertState
                                                      .rates.rates.keys
                                                      .toSet(),
                                                  activeFrom: activeFrom,
                                                  activeTo: activeTo,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              '1 $activeFrom = ${CurrencyFormatter.formatRateDynamic(loadedState.current)} $activeTo',
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
                                          horizontal: 8,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: loadedState.isPositive
                                              ? AppColors.deltaPositive
                                                  .withValues(alpha: 0.18)
                                              : AppColors.deltaNegative
                                                  .withValues(alpha: 0.18),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              loadedState.isPositive
                                                  ? CupertinoIcons
                                                      .arrow_up_right
                                                  : CupertinoIcons
                                                      .arrow_down_right,
                                              size: 13,
                                              color: loadedState.isPositive
                                                  ? AppColors.deltaPositive
                                                  : AppColors.deltaNegative,
                                            ),
                                            const SizedBox(width: 3),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                '${loadedState.isPositive ? '+' : ''}${loadedState.delta.toStringAsFixed(2)}%',
                                                style: TextStyle(
                                                  fontSize: 11.5,
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
                                const SizedBox(height: 18),

                                // Polished Timeframe Segmented Control
                                Container(
                                  padding: const EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                    color: isLight
                                        ? const Color(0xFFF3F4F6)
                                        : surfaceAlt,
                                    borderRadius:
                                        BorderRadius.circular(14.0),
                                    border: Border.all(
                                        color: pillUnselectedBorder),
                                  ),
                                  child: Row(
                                    children: List.generate(
                                        _timeframes.length, (i) {
                                      final isSel =
                                          _selectedTimeframeIndex == i;
                                      return Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() =>
                                                _selectedTimeframeIndex = i);
                                            context
                                                .read<RatesCubit>()
                                                .loadHistoricalRates(
                                                  fromCurrency: activeFrom,
                                                  toCurrency: activeTo,
                                                  timeframe: _timeframes[i],
                                                  currentRate: unitRate,
                                                );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(11.0),
                                          child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: isSel
                                                  ? _pillSelectedGradient
                                                  : null,
                                              color: isSel
                                                  ? null
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(11.0),
                                              boxShadow: isSel
                                                  ? [
                                                      BoxShadow(
                                                        color: const Color(
                                                                0xFFFF3366)
                                                            .withValues(
                                                                alpha: 0.35),
                                                        blurRadius: 10,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Text(
                                                _timeframes[i],
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: isSel
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: isSel
                                                      ? Colors.white
                                                      : labelMutedColor,
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
                                  ratePoints: loadedState.ratePoints,
                                  timeframe: selectedTimeframe,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 3. Analytics & Statistics Grid (Market Metrics Cards)
                          Text(
                            'MARKET METRICS',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: isLight
                                  ? const Color(0xFF6B7280)
                                  : AppColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: MarketMetricsCard(
                                  title: highTitle,
                                  value: CurrencyFormatter.formatRateDynamic(
                                      loadedState.high),
                                  icon: CupertinoIcons.arrow_up,
                                  accentColor: AppColors.deltaPositive,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MarketMetricsCard(
                                  title: lowTitle,
                                  value: CurrencyFormatter.formatRateDynamic(
                                      loadedState.low),
                                  icon: CupertinoIcons.arrow_down,
                                  accentColor: AppColors.deltaNegative,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: MarketMetricsCard(
                                  title: 'Average Rate',
                                  value: CurrencyFormatter.formatRateDynamic(
                                      loadedState.average),
                                  icon: CupertinoIcons.waveform_path_ecg,
                                  accentColor: const Color(0xFF7B5CFF),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MarketMetricsCard(
                                  title: 'Current Rate',
                                  value: CurrencyFormatter.formatRateDynamic(
                                      loadedState.current),
                                  icon: CupertinoIcons.bolt_fill,
                                  accentColor: primaryLightColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlagPill({
    required String code,
    required bool isLight,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isLight ? const Color(0xFFF9FAFB) : surfaceAlt,
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
              size: 16.0,
              color: isLight
                  ? const Color(0xFF6B7280)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
