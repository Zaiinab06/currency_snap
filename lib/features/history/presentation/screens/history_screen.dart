import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../converter/presentation/bottom_sheets/currency_picker_sheet.dart';
import '../../../converter/presentation/cubit/convert_cubit.dart';
import '../../domain/entities/conversion_history_entity.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';

/// Screen displaying user's persisted conversion history logs with search, copy, delete, and re-convert actions.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterQuery = '';

  Future<void> _deleteItem(String id) async {
    context.read<HistoryCubit>().deleteItem(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversion log removed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  void _clearAllHistory() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft red/coral trash icon badge at top center
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF450A0A)
                    : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.trash,
                color: Color(0xFFEF4444),
                size: 26,
              ),
            ),
            const SizedBox(height: 18),
            // Title: Bold, centered "Clear History?"
            Text(
              'Clear History?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            // Content: Centered subtitle
            Text(
              'Are you sure you want to delete all conversion logs? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons side-by-side with equal width
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      context.read<HistoryCubit>().clearHistory();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conversion history cleared'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.trash,
                            size: 15, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Clear All',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor =
        isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final primaryColor = AppColors.neonPurple;
    final primaryLightColor = AppColors.neonPink;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        final historyList = state.history;
        final filtered = _filterQuery.isEmpty
            ? historyList
            : historyList.where((item) {
                final q = _filterQuery.toLowerCase();
                return item.fromCurrency.toLowerCase().contains(q) ||
                    item.toCurrency.toLowerCase().contains(q) ||
                    item.fromAmount.toString().contains(q) ||
                    item.toAmount.toString().contains(q);
              }).toList();

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: scaffoldBg,
            elevation: 0,
            title: Text(
              'Conversion History',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.4,
              ),
            ),
            actions: [
              if (historyList.isNotEmpty)
                IconButton(
                  onPressed: _clearAllHistory,
                  icon: const Icon(
                    CupertinoIcons.trash,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  tooltip: 'Clear history',
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<HistoryCubit>().loadHistory(),
            color: primaryLightColor,
            backgroundColor: surfaceColor,
            child: filtered.isEmpty && historyList.isEmpty
                ? _buildEmptyState(surfaceColor, borderColor, isDark)
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkInputBox
                              : AppColors.lightInputBox,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 1.0),
                        ),
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _filterQuery = val.trim()),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          cursorColor: primaryLightColor,
                          decoration: InputDecoration(
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Icon(
                                CupertinoIcons.search,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 18,
                              ),
                            ),
                            hintText: 'Search by currency code or amount...',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStat(
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              primaryColor: primaryColor,
                              primaryLightColor: primaryLightColor,
                              title: 'Total Logs',
                              value: '${historyList.length}',
                              icon: CupertinoIcons.doc_text,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMiniStat(
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              primaryColor: primaryColor,
                              primaryLightColor: primaryLightColor,
                              title: 'Top Pair',
                              value: _getTopPair(historyList),
                              icon: CupertinoIcons.arrow_right_arrow_left,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'RECENT LOGS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (filtered.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'No conversions found matching "$_filterQuery"',
                              style:
                                  const TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else
                        ...filtered.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildHistoryCard(
                                item: item,
                                surfaceColor: surfaceColor,
                                borderColor: borderColor,
                                primaryLightColor: primaryLightColor,
                                isDark: isDark,
                              ),
                            )),
                    ],
                  ),
          ),
        );
      },
    );
  }

  String _getTopPair(List<ConversionHistoryEntity> history) {
    if (history.isEmpty) return 'None';
    final counts = <String, int>{};
    for (final h in history) {
      final key = '${h.fromCurrency}/${h.toCurrency}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    var top = 'None';
    var maxCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        top = entry.key;
      }
    }
    return top;
  }

  Widget _buildMiniStat({
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryColor,
    required Color primaryLightColor,
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: isDark
          ? AppColors.neonCardDecoration(
              color: surfaceColor,
              borderColor: borderColor,
              glow: false,
              borderRadius: 14,
            )
          : BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: primaryLightColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required ConversionHistoryEntity item,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryLightColor,
    required bool isDark,
  }) {
    final fromFlag = FlagCode.fromCurrencyCode(item.fromCurrency);
    final toFlag = FlagCode.fromCurrencyCode(item.toCurrency);
    final fromCountry = kCurrencyData[item.fromCurrency]?.countryCode ??
        item.fromCurrency.substring(
            0, item.fromCurrency.length > 2 ? 2 : item.fromCurrency.length);
    final toCountry = kCurrencyData[item.toCurrency]?.countryCode ??
        item.toCurrency.substring(
            0, item.toCurrency.length > 2 ? 2 : item.toCurrency.length);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: isDark
          ? AppColors.neonCardDecoration(
              color: surfaceColor,
              borderColor: borderColor,
              glow: true,
              borderRadius: 18,
            )
          : BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                              border:
                                  Border.all(color: surfaceColor, width: 1.5),
                            ),
                            child: ClipOval(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: fromFlag != null
                                    ? CountryFlag.fromCurrencyCode(
                                        item.fromCurrency,
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
                              border:
                                  Border.all(color: surfaceColor, width: 1.5),
                            ),
                            child: ClipOval(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: toFlag != null
                                    ? CountryFlag.fromCurrencyCode(
                                        item.toCurrency,
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
                  const SizedBox(width: 8),
                  Text(
                    '${item.fromCurrency} → ${item.toCurrency}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatRelativeTime(item.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => _deleteItem(item.id),
                    icon: Icon(
                      CupertinoIcons.xmark_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Delete log',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.fromAmount.toStringAsFixed(0)} ${item.fromCurrency} =',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.toAmount.toStringAsFixed(2)} ${item.toCurrency}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: primaryLightColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              '${item.fromAmount} ${item.fromCurrency} = ${item.toAmount} ${item.toCurrency}',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conversion copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.doc_on_doc,
                        size: 18, color: AppColors.textSecondary),
                    tooltip: 'Copy',
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  IconButton(
                    onPressed: () {
                      final cubit = context.read<ConvertCubit>();
                      cubit.changeSourceCurrency(item.fromCurrency);
                      cubit.changeTargetCurrency(item.toCurrency);
                      cubit.updateAmount(item.fromAmount);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Loaded ${item.fromCurrency}/${item.toCurrency} into Converter',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(CupertinoIcons.arrow_2_circlepath,
                        size: 18, color: primaryLightColor),
                    tooltip: 'Re-convert',
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color surfaceColor, Color borderColor, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: AppColors.neonPurple.withValues(alpha: 0.2),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
              child: const Icon(
                CupertinoIcons.clock,
                size: 48,
                color: AppColors.neonPink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Recent Conversions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Conversions performed on the Home dashboard will automatically appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
