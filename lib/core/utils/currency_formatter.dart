import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Utility class providing standardized number, currency, and rate formatting.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a numeric amount with standard thousands separators and decimal digits.
  /// Example: 1000.5 -> "1,000.50", 277774.76 -> "277,774.76"
  static String formatAmount(double amount, {int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount).trim();
  }

  /// Formats an input amount cleanly with thousands separators (e.g. "1,000" for integers, "1,000.50" for decimals).
  static String formatInputAmount(double amount) {
    if (amount % 1 == 0) {
      return NumberFormat('#,##0').format(amount);
    }
    return NumberFormat('#,##0.00').format(amount);
  }

  /// Formats an exchange rate with high precision (default 4 decimal places).
  /// Example: 75.56402 -> "75.5640"
  static String formatRate(double rate, {int decimalDigits = 4}) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(rate).trim();
  }

  /// Formats large figures into compact representations (e.g. 1.2M, 500K).
  static String formatCompact(double amount) {
    final formatter = NumberFormat.compact();
    return formatter.format(amount);
  }

  /// Cleans symbols, commas, and whitespace, safely parsing text into a double.
  /// Falls back to 0.0 if input is invalid or empty.
  static double parseAmount(String text) {
    if (text.trim().isEmpty) return 0.0;
    final cleaned = text.replaceAll(RegExp(r'[^\d.-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}

/// Dynamic input formatter that formats integer portions with commas as thousands separators
/// while accurately tracking cursor position and permitting decimal entries.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final int maxDecimalDigits;

  ThousandsSeparatorInputFormatter({this.maxDecimalDigits = 4});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Filter out invalid characters, allowing only digits and at most one decimal point
    final textWithoutCommas = newValue.text.replaceAll(',', '');

    // Allow typing leading or solitary decimal point or digits
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(textWithoutCommas)) {
      return oldValue;
    }

    // Count how many non-comma characters (digits + '.') were before the new cursor in newValue
    int nonCommaCharsBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.end && i < newValue.text.length; i++) {
      if (newValue.text[i] != ',') {
        nonCommaCharsBeforeCursor++;
      }
    }

    // Split integer and decimal parts
    final parts = textWithoutCommas.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    if (decimalPart != null && decimalPart.length > maxDecimalDigits) {
      decimalPart = decimalPart.substring(0, maxDecimalDigits);
    }

    // Format integer part with thousands commas
    String formattedInteger = '';
    if (integerPart.isNotEmpty) {
      // Strip leading zeroes for multi-digit integers (e.g., '05' -> '5')
      if (integerPart.length > 1 && integerPart.startsWith('0')) {
        integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');
        if (integerPart.isEmpty) integerPart = '0';
      }

      final intBuffer = StringBuffer();
      for (int i = 0; i < integerPart.length; i++) {
        if (i > 0 && (integerPart.length - i) % 3 == 0) {
          intBuffer.write(',');
        }
        intBuffer.write(integerPart[i]);
      }
      formattedInteger = intBuffer.toString();
    } else if (textWithoutCommas.startsWith('.')) {
      formattedInteger = '0';
    }

    String formattedText = formattedInteger;
    if (parts.length > 1) {
      formattedText += '.$decimalPart';
    } else if (textWithoutCommas.endsWith('.')) {
      formattedText += '.';
    }

    // Calculate new cursor position based on nonCommaCharsBeforeCursor
    int newCursorPos = 0;
    int countedNonComma = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (countedNonComma == nonCommaCharsBeforeCursor) {
        newCursorPos = i;
        break;
      }
      if (formattedText[i] != ',') {
        countedNonComma++;
      }
      newCursorPos = i + 1;
    }

    newCursorPos = newCursorPos.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}

/// Formats a numeric amount with standard thousands separators and decimal digits.
String formatAmount(double amount, {int decimalDigits = 2}) =>
    CurrencyFormatter.formatAmount(amount, decimalDigits: decimalDigits);

/// Formats an exchange rate with high precision (default 4 decimal places).
String formatRate(double rate, {int decimalDigits = 4}) =>
    CurrencyFormatter.formatRate(rate, decimalDigits: decimalDigits);

/// Formats large figures into compact representations (e.g. 1.2M, 500K).
String formatCompact(double amount) => CurrencyFormatter.formatCompact(amount);

/// Cleans symbols, commas, and whitespace, safely parsing text into a double.
double parseAmount(String text) => CurrencyFormatter.parseAmount(text);
