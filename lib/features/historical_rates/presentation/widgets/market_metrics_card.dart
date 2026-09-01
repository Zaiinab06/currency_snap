import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Polished Market Metrics card matching the soft lavender/purple brand theme.
class MarketMetricsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color accentColor;

  const MarketMetricsCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.accentColor = const Color(0xFF7B5CFF),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isDark = !isLight;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: isDark
          ? AppColors.neonCardDecoration(
              color: AppColors.darkCardSurface,
              borderColor: AppColors.darkBorder,
              glow: false,
              borderRadius: 18.0,
            )
          : BoxDecoration(
              color: const Color(0xFFFF3366).withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: const Color(0xFFFF3366).withValues(alpha: 0.08),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: isLight
                      ? const Color(0xFF6B7280)
                      : AppColors.darkTextSecondary,
                ),
              ),
              if (icon != null)
                Icon(icon, size: 14, color: accentColor)
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: isLight
                    ? const Color(0xFF111827)
                    : Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
