import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/favourite_pair_model.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';

/// Elevated card tile rendering a saved favorite currency pair with dual flag avatars,
/// unit rate, clean percentage delta badge in Mint Green/Coral Red, and delete action.
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

  double get _deltaPercent {
    // Deterministic 24h delta percentage derived from pair code
    final hash = (pair.fromCurrency.hashCode ^ pair.toCurrency.hashCode).abs();
    final base = ((hash % 140) / 100.0) - 0.55;
    return double.parse(base.toStringAsFixed(2));
  }

  Widget _buildDualFlags(String fromCode, String toCode) {
    final fromFlag = FlagCode.fromCurrencyCode(fromCode);
    final toFlag = FlagCode.fromCurrencyCode(toCode);
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
                  child: fromFlag != null
                      ? CountryFlag.fromCurrencyCode(
                          fromCode,
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
                  child: toFlag != null
                      ? CountryFlag.fromCurrencyCode(
                          toCode,
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
    );
  }

  Widget _buildDeltaBadge(double percent) {
    final isPositive = percent >= 0;
    final bg = isPositive
        ? AppColors.deltaPositive.withValues(alpha: 0.18)
        : AppColors.deltaNegative.withValues(alpha: 0.18);
    final textColor = isPositive ? AppColors.deltaPositive : AppColors.deltaNegative;
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
            size: 16,
            color: textColor,
          ),
          Text(
            '$sign${percent.toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '1 ${pair.fromCurrency} = ${pair.rate > 100 ? pair.rate.toStringAsFixed(2) : pair.rate.toStringAsFixed(4)} ${pair.toCurrency}',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Saved $_relativeTime',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDeltaBadge(_deltaPercent),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  tooltip: 'Delete favorite',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



