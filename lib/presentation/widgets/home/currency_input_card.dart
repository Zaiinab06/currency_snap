import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// The card used for both "You send" and "They receive" rows on the
/// Home/Converter screen. [isEditable] controls whether the amount
/// field accepts input (the "send" side) or just displays a computed
/// result (the "receive" side).
///
/// Stateful so it can own a persistent [TextEditingController] —
/// recreating the controller on every rebuild would reset the
/// cursor/typed text mid-keystroke, cutting off digits as the user types.
class CurrencyInputCard extends StatefulWidget {
  final String label;
  final String currencyCode;
  final String amountText;
  final bool isEditable;
  final ValueChanged<String>? onAmountChanged;
  final VoidCallback onCurrencyTap;

  const CurrencyInputCard({
    super.key,
    required this.label,
    required this.currencyCode,
    required this.amountText,
    required this.onCurrencyTap,
    this.isEditable = false,
    this.onAmountChanged,
  });

  @override
  State<CurrencyInputCard> createState() => _CurrencyInputCardState();
}

class _CurrencyInputCardState extends State<CurrencyInputCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.amountText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: widget.isEditable
                    ? TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontSize: 26),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: widget.onAmountChanged,
                      )
                    : Text(
                        widget.amountText,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontSize: 26),
                      ),
              ),
              const SizedBox(width: 8),
              _CurrencyPill(
                code: widget.currencyCode,
                onTap: widget.onCurrencyTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const _CurrencyPill({required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      // 44pt minimum touch target per Apple HIG, achieved via padding.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(code, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 2),
            const Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
