import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/convert/convert_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/conversion_history_model.dart';
import '../../../data/repositories/currency_repository.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';

/// Screen displaying user's persisted conversion history logs with dynamic theming, search, copy, delete, and re-convert actions.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ConversionHistoryModel> _history = [];
  String _filterQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final repository = context.read<CurrencyRepository>();
    final items = await repository.getHistory();
    if (mounted) {
      setState(() {
        _history = items;
      });
    }
  }

  Future<void> _deleteItem(String id) async {
    final repository = context.read<CurrencyRepository>();
    await repository.deleteHistoryItem(id);
    await _loadHistory();
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Clear Conversion Logs?',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          'This will remove all conversion history logs from your device storage.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repository = context.read<CurrencyRepository>();
              await repository.clearHistory();
              await _loadHistory();
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
              backgroundColor: AppColors.deltaNegative,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final scaffoldBg = isLight ? theme.scaffoldBackgroundColor : AppColors.scaffoldBackground;
    final surfaceColor = isLight ? Colors.white : AppColors.surface;
    final primaryColor = AppColors.primary;
    final primaryLightColor = AppColors.primaryLight;
    final borderColor = isLight
        ? Colors.black.withValues(alpha: 0.06)
        : AppColors.border;

    final filtered = _filterQuery.isEmpty
        ? _history
        : _history.where((item) {
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
          if (_history.isNotEmpty)
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
        onRefresh: _loadHistory,
        color: primaryLightColor,
        backgroundColor: surfaceColor,
        child: filtered.isEmpty && _history.isEmpty
            ? _buildEmptyState(surfaceColor, borderColor)
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  // 1. Search Bar with dynamic theme styling and soft muted hint text
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 1.0),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _filterQuery = val.trim()),
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

                  // 2. Summary stats header
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          primaryColor: primaryColor,
                          primaryLightColor: primaryLightColor,
                          title: 'Total Logs',
                          value: '${_history.length}',
                          icon: CupertinoIcons.doc_text,
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
                          value: _getTopPair(),
                          icon: CupertinoIcons.arrow_right_arrow_left,
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
                          style: const TextStyle(color: AppColors.textSecondary),
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
                          ),
                        )),
                ],
              ),
      ),
    );
  }

  String _getTopPair() {
    if (_history.isEmpty) return 'None';
    final counts = <String, int>{};
    for (final h in _history) {
      final key = '${h.fromCurrency}/${h.toCurrency}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    var top = 'USD / EUR';
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
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
    required ConversionHistoryModel item,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryLightColor,
  }) {
    final fromFlag = FlagCode.fromCurrencyCode(item.fromCurrency);
    final toFlag = FlagCode.fromCurrencyCode(item.toCurrency);
    final fromCountry = kCurrencyData[item.fromCurrency]?.countryCode ??
        item.fromCurrency.substring(0, item.fromCurrency.length > 2 ? 2 : item.fromCurrency.length);
    final toCountry = kCurrencyData[item.toCurrency]?.countryCode ??
        item.toCurrency.substring(0, item.toCurrency.length > 2 ? 2 : item.toCurrency.length);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
                              border: Border.all(color: surfaceColor, width: 1.5),
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
                              border: Border.all(color: surfaceColor, width: 1.5),
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
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
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
                    icon: const Icon(CupertinoIcons.doc_on_doc, size: 18, color: AppColors.textSecondary),
                    tooltip: 'Copy',
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
                    icon: Icon(CupertinoIcons.arrow_2_circlepath, size: 18, color: primaryLightColor),
                    tooltip: 'Re-convert',
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color surfaceColor, Color borderColor) {
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
              ),
              child: const Icon(
                CupertinoIcons.clock,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Conversion History',
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
