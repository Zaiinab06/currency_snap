import 'package:intl/intl.dart';

/// Utility class providing standardized number, currency, and rate formatting.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a numeric amount with standard thousands separators and decimal digits.
  /// Example: 1000.5 -> "1,000.50"
  static String formatAmount(double amount, {int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount).trim();
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
