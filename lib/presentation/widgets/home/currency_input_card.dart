import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';

/// The card used for both "You send" and "They receive" rows on the
/// Home/Converter screen. [isEditable] controls whether the amount
/// field accepts input (the "send" side) or just displays a computed
/// result (the "receive" side).
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
  void didUpdateWidget(covariant CurrencyInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amountText != oldWidget.amountText && !widget.isEditable) {
      _controller.text = widget.amountText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: widget.isEditable
                    ? TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
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
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
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
    final countryCode = kCurrencyData[code]?.countryCode ??
        code.substring(0, code.length > 2 ? 2 : code.length);

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CountryFlag.fromCountryCode(
                    countryCode,
                    shape: const Circle(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                code,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

