import 'dart:async';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/convert/convert_cubit.dart';
import '../../../bloc/convert/convert_state.dart';
import '../../../bloc/favorites/favorites_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/home/currency_input_card.dart';
import '../../widgets/home/swap_button.dart';
import '../historical_rates/historical_rate_chart_screen.dart';
import '../rates/rates_screen.dart';

/// Main Converter Dashboard with dynamic theme palette reactivity:
/// - Greeting header ("Hello, Zainab 👋")
/// - Vertical column live exchange rate status & full visible timestamp
/// - Stacked input cards with centered animated swap button
/// - Thousands separator input formatting with precise cursor positioning
/// - Dismiss focus/cursor on tap outside anywhere
/// - Quick preset amount pills (100, 500, 1000, 5000)
/// - "Save Pair" animated feedback for 1.2s
/// - "Popular Pairs" horizontal preview cards at bottom with 130px bottom clearance
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<double> _presetAmounts = [100, 500, 1000, 5000];
  late final TextEditingController _amountController;
  bool _isSavedPairActive = false;
  Timer? _savePairTimer;

  static const List<(String, String)> _popularPairs = [
    ('USD', 'EUR'),
    ('GBP', 'USD'),
    ('USD', 'PKR'),
    ('EUR', 'GBP'),
    ('USD', 'JPY'),
    ('USD', 'AED'),
    ('USD', 'SAR'),
    ('AUD', 'USD'),
    ('USD', 'CAD'),
    ('USD', 'INR'),
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '100');
    context.read<ConvertCubit>().loadRates();
  }

  @override
  void dispose() {
    _savePairTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _pickCurrency({required bool isSource}) async {
    final cubit = context.read<ConvertCubit>();
    final state = cubit.state;
    if (state is! ConvertLoaded) return;

    final currentCode = isSource ? state.fromCurrency : state.toCurrency;
    final picked = await showCurrencyPickerSheet(
      context: context,
      selectedCode: currentCode,
      availableCodes: state.rates.rates.keys,
    );
    if (picked == null || picked == currentCode) return;

    if (isSource) {
      cubit.changeSourceCurrency(picked);
    } else {
      cubit.changeTargetCurrency(picked);
    }
    cubit.recordCurrentConversion();
  }

  double _getPairDelta(String from, String to) {
    final hash = (from.hashCode ^ to.hashCode).abs();
    final base = ((hash % 140) / 100.0) - 0.55;
    return double.parse(base.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: BlocConsumer<ConvertCubit, ConvertState>(
            listener: (context, state) {
              if (state is ConvertLoaded) {
                final parsed = CurrencyFormatter.parseAmount(_amountController.text);
                if ((parsed - state.amount).abs() > 0.001) {
                  final formattedAmount = CurrencyFormatter.formatInputAmount(state.amount);
                  _amountController.text = formattedAmount;
                  _amountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _amountController.text.length),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is ConvertLoading || state is ConvertInitial) {
                return const LoadingIndicator();
              }
              if (state is ConvertError) {
                return ErrorBanner(
                  message: state.message,
                  onRetry: () => context.read<ConvertCubit>().loadRates(),
                );
              }
              final loaded = state as ConvertLoaded;
              return _buildLoadedContent(context, loaded);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, ConvertLoaded state) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final primaryLightColor = theme.colorScheme.secondary;
    final surfaceColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final cubit = context.read<ConvertCubit>();

    final unitRate = state.rates.convertBetween(
          fromCurrency: state.fromCurrency,
          toCurrency: state.toCurrency,
          amount: 1.0,
        ) ??
        0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Alignment & Visible Timestamp
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello, Zainab 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              // Row 1: Green pulse dot + "Live Exchange Rates"
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: state.isFromCache ? AppColors.warning : AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (state.isFromCache ? AppColors.warning : AppColors.success)
                              .withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.isFromCache ? 'Cached Rates' : 'Live Exchange Rates',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Row 2 (directly below): "Synced Today at [hh:mm a] · Live" + inline tappable refresh icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateTimeFormatter.formatSyncTime(
                      state.lastSyncTime,
                      isFromCache: state.isFromCache,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8E8EA8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: state.isRefreshing
                        ? null
                        : () {
                            cubit.refreshRates(forceRefresh: true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Refreshing live exchange rates...'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: state.isRefreshing
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryLightColor,
                              ),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              color: primaryLightColor,
                              size: 16,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Quick Amount Segmented Container
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'QUICK AMOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: Row(
                  children: _presetAmounts.map((preset) {
                    final isSelected = (state.amount - preset).abs() < 0.001;
                    final presetDisplay = CurrencyFormatter.formatInputAmount(preset);
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          _amountController.text = presetDisplay;
                          _amountController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _amountController.text.length),
                          );
                          cubit.updateAmount(preset);
                          cubit.recordCurrentConversion();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              presetDisplay,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Stacked Midnight Input Cards with Centered Animated Swap Button
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  CurrencyInputCard(
                    key: ValueKey('send_${state.fromCurrency}'),
                    label: 'From',
                    currencyCode: state.fromCurrency,
                    amountText: CurrencyFormatter.formatInputAmount(state.amount),
                    controller: _amountController,
                    isEditable: true,
                    isDark: false,
                    onAmountChanged: (value) {
                      final parsed = CurrencyFormatter.parseAmount(value);
                      cubit.updateAmount(parsed);
                    },
                    onCurrencyTap: () => _pickCurrency(isSource: true),
                  ),
                  const SizedBox(height: 12),
                  CurrencyInputCard(
                    label: 'To',
                    currencyCode: state.toCurrency,
                    amountText: CurrencyFormatter.formatAmount(
                      state.convertedAmount ?? 0,
                      decimalDigits: 2,
                    ),
                    isEditable: false,
                    isDark: true,
                    onCurrencyTap: () => _pickCurrency(isSource: false),
                  ),
                ],
              ),
              Positioned(
                top: 92,
                left: 0,
                right: 0,
                child: Center(
                  child: SwapButton(
                    onTap: () {
                      cubit.swapCurrencies();
                      cubit.recordCurrentConversion();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Unit Rate Badge in subtle semi-transparent pill container
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: primaryLightColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '1 ${state.fromCurrency} = ${unitRate > 100 ? unitRate.toStringAsFixed(2) : unitRate.toStringAsFixed(4)} ${state.toCurrency}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 5. Action Button Hierarchy (Primary: View Rate Trend, Secondary: Save Pair)
          Row(
            children: [
              // Primary Action (Left): Filled Themed Button -> "View Rate Trend"
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HistoricalRateChartScreen(
                          fromCurrency: state.fromCurrency,
                          toCurrency: state.toCurrency,
                          currentRate: unitRate,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.trending_up_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text('View Rate Trend'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: primaryColor.withValues(alpha: 0.5),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Secondary Action (Right): Animated Feedback Outlined Button -> "Save Pair"
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    setState(() {
                      _isSavedPairActive = true;
                    });
                    _savePairTimer?.cancel();
                    _savePairTimer = Timer(const Duration(milliseconds: 1200), () {
                      if (mounted) {
                        setState(() {
                          _isSavedPairActive = false;
                        });
                      }
                    });

                    await cubit.saveCurrentPairToFavorites();
                    if (context.mounted) {
                      context.read<FavoritesCubit>().loadFavorites();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${state.fromCurrency}/${state.toCurrency} saved to favorites',
                          ),
                          duration: const Duration(milliseconds: 1200),
                        ),
                      );
                    }
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      _isSavedPairActive ? Icons.star_rounded : Icons.star_border_rounded,
                      key: ValueKey(_isSavedPairActive),
                      size: 18,
                      color: _isSavedPairActive ? primaryColor : primaryLightColor,
                    ),
                  ),
                  label: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _isSavedPairActive ? primaryColor : primaryLightColor,
                    ),
                    child: Text(_isSavedPairActive ? 'Saved Pair!' : 'Save Pair'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isSavedPairActive ? primaryColor : primaryLightColor,
                    backgroundColor: _isSavedPairActive
                        ? primaryColor.withValues(alpha: 0.16)
                        : surfaceColor,
                    side: BorderSide(
                      color: _isSavedPairActive ? primaryColor : borderColor,
                      width: _isSavedPairActive ? 1.6 : 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 6. "Popular Pairs" Rich Horizontal Cards with "See All" Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 18,
                    color: primaryLightColor,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'POPULAR PAIRS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RatesScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryLightColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _popularPairs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final pair = _popularPairs[index];
                final pairFrom = pair.$1;
                final pairTo = pair.$2;
                final rate = state.rates.convertBetween(
                      fromCurrency: pairFrom,
                      toCurrency: pairTo,
                      amount: 1.0,
                    ) ??
                    0.0;
                final delta = _getPairDelta(pairFrom, pairTo);
                final isPositive = delta >= 0;

                final fromCountry = kCurrencyData[pairFrom]?.countryCode ??
                    pairFrom.substring(0, pairFrom.length > 2 ? 2 : pairFrom.length);
                final toCountry = kCurrencyData[pairTo]?.countryCode ??
                    pairTo.substring(0, pairTo.length > 2 ? 2 : pairTo.length);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      cubit.changeSourceCurrency(pairFrom);
                      cubit.changeTargetCurrency(pairTo);
                      cubit.recordCurrentConversion();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 168,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 42,
                                height: 24,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: surfaceColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: FlagCode.fromCurrencyCode(pairFrom) != null
                                                ? CountryFlag.fromCurrencyCode(
                                                    pairFrom,
                                                    shape: const Circle(),
                                                  )
                                                : CountryFlag.fromCountryCode(
                                                    fromCountry,
                                                    shape: const Circle(),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: surfaceColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: FlagCode.fromCurrencyCode(pairTo) != null
                                                ? CountryFlag.fromCurrencyCode(
                                                    pairTo,
                                                    shape: const Circle(),
                                                  )
                                                : CountryFlag.fromCountryCode(
                                                    toCountry,
                                                    shape: const Circle(),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isPositive
                                      ? AppColors.deltaPositive.withValues(alpha: 0.18)
                                      : AppColors.deltaNegative.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${isPositive ? '+' : ''}${delta.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isPositive
                                        ? AppColors.deltaPositive
                                        : AppColors.deltaNegative,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$pairFrom / $pairTo',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rate > 100
                                    ? rate.toStringAsFixed(2)
                                    : rate.toStringAsFixed(4),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryLightColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // 7. Footer disclaimer micro-text
          Text(
            'Mid-market exchange rates provided for informational purposes only. Actual transaction rates may vary by institution.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
