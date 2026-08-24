import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/convert/convert_cubit.dart';
import '../../../bloc/convert/convert_state.dart';
import '../../../bloc/favorites/favorites_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/home/currency_input_card.dart';
import '../../widgets/home/swap_button.dart';
import '../historical_rates/historical_rate_chart_screen.dart';

/// Main Stitch Converter Dashboard: amount input, live conversion,
/// mid-market status badge, baseline rates, and quick action buttons.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConvertCubit>().loadRates();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'CurrencySnap',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ConvertCubit, ConvertState>(
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
    );
  }

  Widget _buildLoadedContent(BuildContext context, ConvertLoaded state) {
    final cubit = context.read<ConvertCubit>();
    final unitRate = state.rates.convertBetween(
          fromCurrency: state.fromCurrency,
          toCurrency: state.toCurrency,
          amount: 1.0,
        ) ??
        0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live status badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    state.isFromCache
                        ? 'Offline cache mode'
                        : 'Live mid-market rate',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Converter Stack with overlapping center swap button
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  CurrencyInputCard(
                    key: ValueKey('send_${state.fromCurrency}'),
                    label: 'You send',
                    currencyCode: state.fromCurrency,
                    amountText: state.amount.toStringAsFixed(2),
                    isEditable: true,
                    onAmountChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) cubit.updateAmount(parsed);
                    },
                    onCurrencyTap: () => _pickCurrency(isSource: true),
                  ),
                  const SizedBox(height: 12),
                  CurrencyInputCard(
                    label: 'They receive',
                    currencyCode: state.toCurrency,
                    amountText: (state.convertedAmount ?? 0).toStringAsFixed(2),
                    isEditable: false,
                    onCurrencyTap: () => _pickCurrency(isSource: false),
                  ),
                ],
              ),
              Positioned(
                top: 86,
                left: 0,
                right: 0,
                child: Center(child: SwapButton(onTap: cubit.swapCurrencies)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clean baseline rate label
          Center(
            child: Text(
              '1 ${state.fromCurrency} = ${unitRate.toStringAsFixed(4)} ${state.toCurrency}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons: Save to Watchlist & Track Historical Trend
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await cubit.saveCurrentPairToFavorites();
                    if (context.mounted) {
                      context.read<FavoritesCubit>().loadFavorites();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${state.fromCurrency}/${state.toCurrency} saved to favorites',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.star_border_rounded, size: 18),
                  label: const Text('Save Pair'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                    color: AppColors.accent,
                  ),
                  label: const Text('Track Trend'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Footer disclaimer micro-text
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

