import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';

/// The dual-contrast card used for "From" and "To" rows on the Home/Converter screen with dynamic theming.
class CurrencyInputCard extends StatefulWidget {
  final String label;
  final String currencyCode;
  final String amountText;
  final bool isEditable;
  final bool isDark;
  final TextEditingController? controller;
  final FocusNode? focusNode;
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
    this.focusNode,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final labelColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final amountColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
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
                        focusNode: widget.focusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: amountColor,
                        ),
                        inputFormatters: [
                          ThousandsSeparatorInputFormatter(),
                        ],
                        cursorColor: theme.colorScheme.secondary,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        onChanged: widget.onAmountChanged,
                      )
                    : Text(
                        widget.amountText,
                        style: TextStyle(
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
                isDark: widget.isDark,
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
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final flagCode = FlagCode.fromCurrencyCode(code);
    final countryCode = kCurrencyData[code]?.countryCode ??
        code.substring(0, code.length > 2 ? 2 : code.length);

    final pillBg = isDarkTheme ? AppColors.darkInputBox : AppColors.lightInputBox;
    final pillBorder = isDarkTheme ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDarkTheme ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final arrowColor = isDarkTheme ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: pillBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkTheme ? 0.15 : 0.03),
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
                  border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.3,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.chevron_down,
                size: 14,
                color: arrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
