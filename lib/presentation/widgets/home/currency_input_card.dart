import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';

/// The dual-contrast card used for "From" (#14152D) and "To" (#1B1C38)
/// rows on the Home/Converter screen in Midnight Neon Purple theme.
class CurrencyInputCard extends StatefulWidget {
  final String label;
  final String currencyCode;
  final String amountText;
  final bool isEditable;
  final bool isDark;
  final TextEditingController? controller;
  final ValueChanged<String>? onAmountChanged;
  final VoidCallback onCurrencyTap;

  const CurrencyInputCard({
    super.key,
    required this.label,
    required this.currencyCode,
    required this.amountText,
    required this.onCurrencyTap,
    this.isEditable = false,
    this.isDark = false,
    this.controller,
    this.onAmountChanged,
  });

  @override
  State<CurrencyInputCard> createState() => _CurrencyInputCardState();
}

class _CurrencyInputCardState extends State<CurrencyInputCard> {
  TextEditingController? _internalController;
  TextEditingController get _controller => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController(text: widget.amountText);
    }
  }

  @override
  void didUpdateWidget(covariant CurrencyInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && _internalController != null) {
      if (widget.amountText != oldWidget.amountText && !widget.isEditable) {
        _internalController!.text = widget.amountText;
      } else if (widget.amountText != _internalController!.text && widget.isEditable) {
        _internalController!.text = widget.amountText;
        _internalController!.selection = TextSelection.fromPosition(
          TextPosition(offset: _internalController!.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cardBg = isDark ? AppColors.surfaceAlt : AppColors.surface;
    final cardBorder = isDark ? AppColors.borderHighlight : AppColors.cardBorder;
    const labelColor = AppColors.textSecondary;
    const amountColor = AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 10),
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
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: amountColor,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                          ),
                        ),
                        onChanged: widget.onAmountChanged,
                      )
                    : Text(
                        widget.amountText,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: amountColor,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              _CurrencyPill(
                code: widget.currencyCode,
                onTap: widget.onCurrencyTap,
                isDark: isDark,
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
  final bool isDark;

  const _CurrencyPill({
    required this.code,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final flagCode = FlagCode.fromCurrencyCode(code);
    final countryCode = kCurrencyData[code]?.countryCode ??
        code.substring(0, code.length > 2 ? 2 : code.length);

    final pillBg = isDark
        ? AppColors.surfaceElevated
        : AppColors.surfaceAlt;
    final pillBorder = isDark
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.borderHighlight;
    const textColor = AppColors.textPrimary;
    const arrowColor = AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: pillBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderHighlight, width: 1),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: flagCode != null
                        ? CountryFlag.fromCurrencyCode(
                            code,
                            shape: const Circle(),
                          )
                        : CountryFlag.fromCountryCode(
                            countryCode,
                            shape: const Circle(),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.3,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: arrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


