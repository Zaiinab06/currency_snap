import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/favourite_pair_model.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';

/// Card tile rendering a saved favorite currency pair with dual flag avatars, unit rate, and delete action.
class FavoritePairTile extends StatelessWidget {
  final FavoritePairModel pair;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const FavoritePairTile({
    super.key,
    required this.pair,
    required this.onDelete,
    this.onTap,
  });

  String get _relativeTime {
    final diff = DateTime.now().difference(pair.savedAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildDualFlags(String fromCode, String toCode) {
    final fromCountry = kCurrencyData[fromCode]?.countryCode ??
        fromCode.substring(0, fromCode.length > 2 ? 2 : fromCode.length);
    final toCountry = kCurrencyData[toCode]?.countryCode ??
        toCode.substring(0, toCode.length > 2 ? 2 : toCode.length);

    return SizedBox(
      width: 48,
      height: 28,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CountryFlag.fromCountryCode(
                    fromCountry,
                    shape: const Circle(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CountryFlag.fromCountryCode(
                    toCountry,
                    shape: const Circle(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _buildDualFlags(pair.fromCurrency, pair.toCurrency),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pair.fromCurrency} → ${pair.toCurrency}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '1 ${pair.fromCurrency} = ${pair.rate.toStringAsFixed(3)} ${pair.toCurrency}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Saved $_relativeTime',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
                tooltip: 'Delete favorite',
                padding: const EdgeInsets.all(11),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                splashRadius: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

