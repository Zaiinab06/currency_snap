import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../bottom_sheets/currency_picker_sheet.dart';

/// Compact Vaulta-inspired card for 'From' and 'To' currency inputs.
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
  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

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
      } else if (widget.amountText != _internalController!.text &&
          widget.isEditable) {
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

    final cardBg =
        isDark ? const Color(0xFF160F23) : AppColors.lightCardSurface;
    final cardBorder =
        isDark ? const Color(0xFF382352) : AppColors.lightBorder;
    final amountColor =
        isDark ? Colors.white : AppColors.lightTextPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.0),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Tiny uppercase label ("YOU SEND" / "THEY GET") + Currency Selector Pill ("USD ▾")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA197B4),
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              CurrencyPill(
                code: widget.currencyCode,
                onTap: widget.onCurrencyTap,
                isDark: widget.isDark,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Bottom Row: Amount Input / Display (28sp bold)
          widget.isEditable
              ? TextField(
                  controller: _controller,
                  focusNode: widget.focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: amountColor,
                    height: 1.15,
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
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: isDark
                          ? const Color(0xFFA197B4).withValues(alpha: 0.5)
                          : AppColors.lightTextSecondary.withValues(alpha: 0.5),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onChanged: widget.onAmountChanged,
                )
              : Text(
                  widget.amountText,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: amountColor,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }
}

class CurrencyPill extends StatelessWidget {
  final String code;
  final VoidCallback onTap;
  final bool isDark;

  const CurrencyPill({
    super.key,
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

    final pillBg =
        isDarkTheme ? const Color(0xFF231738) : AppColors.lightInputBox;
    final pillBorder =
        isDarkTheme ? const Color(0xFF382352) : AppColors.lightBorder;
    final textColor =
        isDarkTheme ? Colors.white : AppColors.lightTextPrimary;
    final arrowColor =
        isDarkTheme ? const Color(0xFFA197B4) : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: pillBorder, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 18,
                    height: 18,
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
              const SizedBox(width: 6),
              Text(
                code,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: -0.2,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.chevron_down,
                size: 11,
                color: arrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
