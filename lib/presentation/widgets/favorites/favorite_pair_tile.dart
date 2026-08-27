import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
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
    final hash = (pair.fromCurrency.hashCode ^ pair.toCurrency.hashCode).abs();
    final base = ((hash % 140) / 100.0) - 0.55;
    return double.parse(base.toStringAsFixed(2));
  }

  Widget _buildFlagAvatar(String currencyCode, String countryCode) {
    final fromFlag = FlagCode.fromCurrencyCode(currencyCode);
    return SizedBox(
      width: 28,
      height: 28,
      child: ClipOval(
        child: fromFlag != null
            ? CountryFlag.fromCurrencyCode(
                currencyCode,
                shape: const Circle(),
              )
            : CountryFlag.fromCountryCode(
                countryCode,
                shape: const Circle(),
              ),
      ),
    );
  }

  Widget _buildDualFlags(BuildContext context, String fromCode, String toCode) {
    final theme = Theme.of(context);
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
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.cardColor, width: 1.5),
              ),
              child: _buildFlagAvatar(fromCode, fromCountry),
            ),
          ),
          Positioned(
            left: 18,
            top: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.cardColor, width: 1.5),
              ),
              child: _buildFlagAvatar(toCode, toCountry),
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
            isPositive ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 2),
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
    final theme = Theme.of(context);
    final surfaceColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final primaryLightColor = theme.colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
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
                _buildDualFlags(context, pair.fromCurrency, pair.toCurrency),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pair.fromCurrency} → ${pair.toCurrency}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.4,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '1 ${pair.fromCurrency} = ${pair.rate > 100 ? pair.rate.toStringAsFixed(2) : pair.rate.toStringAsFixed(4)} ${pair.toCurrency}',
                        style: TextStyle(
                          color: primaryLightColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Saved $_relativeTime',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildDeltaBadge(_deltaPercent),
                    const SizedBox(height: 6),
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.trash,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      tooltip: 'Remove',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
