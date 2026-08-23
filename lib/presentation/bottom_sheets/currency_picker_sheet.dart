import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A commonly supported currency, shown in the picker list.
class CurrencyOption {
  final String code;
  final String name;
  const CurrencyOption(this.code, this.name);
}

/// The fixed set of currencies the MVP supports for picking.
/// Kept small and explicit rather than pulling a full ISO list,
/// in line with the app's intentionally narrow scope.
const List<CurrencyOption> kSupportedCurrencies = [
  CurrencyOption('USD', 'United States Dollar'),
  CurrencyOption('EUR', 'Euro'),
  CurrencyOption('GBP', 'British Pound'),
  CurrencyOption('PKR', 'Pakistani Rupee'),
  CurrencyOption('JPY', 'Japanese Yen'),
  CurrencyOption('AED', 'UAE Dirham'),
  CurrencyOption('CAD', 'Canadian Dollar'),
  CurrencyOption('AUD', 'Australian Dollar'),
];

/// Opens the currency picker as a modal bottom sheet and returns the
/// selected currency code, or null if dismissed without a selection.
Future<String?> showCurrencyPickerSheet({
  required BuildContext context,
  required String selectedCode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CurrencyPickerContent(selectedCode: selectedCode),
  );
}

class _CurrencyPickerContent extends StatefulWidget {
  final String selectedCode;
  const _CurrencyPickerContent({required this.selectedCode});

  @override
  State<_CurrencyPickerContent> createState() => _CurrencyPickerContentState();
}

class _CurrencyPickerContentState extends State<_CurrencyPickerContent> {
  String _query = '';

  List<CurrencyOption> get _filtered {
    if (_query.isEmpty) return kSupportedCurrencies;
    final q = _query.toLowerCase();
    return kSupportedCurrencies
        .where(
          (c) =>
              c.code.toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Select Currency',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search currency',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final option = _filtered[index];
                  final isSelected = option.code == widget.selectedCode;
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(option.code),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceAlt,
                      child: Text(
                        option.code.substring(0, 2),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    title: Text(option.code),
                    subtitle: Text(option.name),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
