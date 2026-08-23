import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/convert/convert_cubit.dart';
import '../../../bloc/convert/convert_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/common/cache_timestamp_label.dart';
import '../../widgets/home/currency_input_card.dart';
import '../../widgets/home/swap_button.dart';

/// The app's main screen: amount input, currency selection, live
/// conversion, and the offline-cache indicator.
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
      appBar: AppBar(title: const Text('CurrencySnap')),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  CurrencyInputCard(
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
              // Swap button overlaps the seam between the two cards,
              // centered horizontally, matching the approved design.
              Positioned(
                top: 88, // half of card height minus half of button height
                left: 0,
                right: 0,
                child: Center(child: SwapButton(onTap: cubit.swapCurrencies)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CacheTimestampLabel(
                isFromCache: state.isFromCache,
                lastUpdated: state.rates.lastUpdated,
              ),
              TextButton.icon(
                onPressed: () async {
                  await cubit.saveCurrentPairToFavorites();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pair saved to favorites')),
                    );
                  }
                },
                icon: const Icon(Icons.star_border_rounded, size: 18),
                label: const Text('Save pair'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
