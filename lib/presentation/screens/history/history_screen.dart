import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/convert/convert_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';

class HistoryItem {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double fromAmount;
  final double toAmount;
  final double rate;
  final DateTime timestamp;

  const HistoryItem({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.rate,
    required this.timestamp,
  });
}

/// Screen displaying user's recent conversion history logs in Midnight Neon theme.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<HistoryItem> _history = [
    HistoryItem(
      id: '1',
      fromCurrency: 'USD',
      toCurrency: 'EUR',
      fromAmount: 500,
      toAmount: 460.00,
      rate: 0.9200,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    HistoryItem(
      id: '2',
      fromCurrency: 'GBP',
      toCurrency: 'USD',
      fromAmount: 1000,
      toAmount: 1265.00,
      rate: 1.2650,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
    ),
    HistoryItem(
      id: '3',
      fromCurrency: 'USD',
      toCurrency: 'PKR',
      fromAmount: 100,
      toAmount: 27850.00,
      rate: 278.50,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    HistoryItem(
      id: '4',
      fromCurrency: 'EUR',
      toCurrency: 'GBP',
      fromAmount: 250,
      toAmount: 214.25,
      rate: 0.8570,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HistoryItem(
      id: '5',
      fromCurrency: 'USD',
      toCurrency: 'JPY',
      fromAmount: 1000,
      toAmount: 154300.00,
      rate: 154.30,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    HistoryItem(
      id: '6',
      fromCurrency: 'AUD',
      toCurrency: 'USD',
      fromAmount: 5000,
      toAmount: 3260.00,
      rate: 0.6520,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  String _filterQuery = '';

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Clear Conversion Logs?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'This will remove all recent conversion history logs from your device.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _history.clear());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversion history cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
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
    final filtered = _history.where((item) {
      if (_filterQuery.isEmpty) return true;
      final q = _filterQuery.toUpperCase();
      return item.fromCurrency.contains(q) ||
          item.toCurrency.contains(q) ||
          '${item.fromAmount}'.contains(q) ||
          '${item.toAmount}'.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Conversion History',
          style: TextStyle(
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
                Icons.delete_sweep_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: filtered.isEmpty && _history.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                // 1. Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _filterQuery = val.trim()),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                      hintText: 'Search by currency code or amount...',
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Summary stats header
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat(
                        title: 'Total Logs',
                        value: '${_history.length}',
                        icon: Icons.receipt_long_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMiniStat(
                        title: 'Top Pair',
                        value: 'USD / EUR',
                        icon: Icons.swap_horiz_rounded,
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

                ...filtered.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildHistoryCard(item),
                    )),
              ],
            ),
    );
  }

  Widget _buildMiniStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(HistoryItem item) {
    final fromFlag = FlagCode.fromCurrencyCode(item.fromCurrency);
    final toFlag = FlagCode.fromCurrencyCode(item.toCurrency);
    final fromCountry = kCurrencyData[item.fromCurrency]?.countryCode ??
        item.fromCurrency.substring(0, 2);
    final toCountry = kCurrencyData[item.toCurrency]?.countryCode ??
        item.toCurrency.substring(0, 2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.1),
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
                              border: Border.all(color: AppColors.surface, width: 1.5),
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
                              border: Border.all(color: AppColors.surface, width: 1.5),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                _formatRelativeTime(item.timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.toAmount.toStringAsFixed(2)} ${item.toCurrency}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.primaryLight,
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
                    icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
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
                    icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primaryLight),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Conversion History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Conversions performed on the Home dashboard will automatically appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
