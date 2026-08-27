import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:currency_snap/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formatAmount formats with thousands separator and 2 decimal places', () {
      expect(formatAmount(1000.0), '1,000.00');
      expect(formatAmount(1234567.89), '1,234,567.89');
      expect(formatAmount(0.0), '0.00');
      expect(formatAmount(50.5, decimalDigits: 3), '50.500');
    });

    test('formatInputAmount formats whole and decimal inputs correctly', () {
      expect(CurrencyFormatter.formatInputAmount(100), '100');
      expect(CurrencyFormatter.formatInputAmount(1000), '1,000');
      expect(CurrencyFormatter.formatInputAmount(5000), '5,000');
      expect(CurrencyFormatter.formatInputAmount(277774.76), '277,774.76');
    });

    test('formatRate formats exchange rates with 4 decimal places by default', () {
      expect(formatRate(75.5640), '75.5640');
      expect(formatRate(1.12), '1.1200');
      expect(formatRate(0.003456, decimalDigits: 6), '0.003456');
    });

    test('formatCompact formats large amounts compactly', () {
      expect(formatCompact(1500), '1.5K');
      expect(formatCompact(2500000), '2.5M');
      expect(formatCompact(1000000000), '1B');
    });

    test('parseAmount safely parses formatted strings into doubles', () {
      expect(parseAmount('1,000.50'), 1000.50);
      expect(parseAmount('\$1,234.56'), 1234.56);
      expect(parseAmount('  500.00  '), 500.00);
      expect(parseAmount(''), 0.0);
      expect(parseAmount('invalid'), 0.0);
      expect(parseAmount('-150.75'), -150.75);
    });
  });

  group('ThousandsSeparatorInputFormatter', () {
    final formatter = ThousandsSeparatorInputFormatter();

    test('formats numbers as commas are typed', () {
      final res1 = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '50000',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(res1.text, '50,000');
      expect(res1.selection.baseOffset, 6);

      final res2 = formatter.formatEditUpdate(
        res1,
        const TextEditingValue(
          text: '50,000.50',
          selection: TextSelection.collapsed(offset: 9),
        ),
      );
      expect(res2.text, '50,000.50');
      expect(res2.selection.baseOffset, 9);
    });

    test('rejects non-numeric characters', () {
      const oldVal = TextEditingValue(
        text: '500',
        selection: TextSelection.collapsed(offset: 3),
      );
      final res = formatter.formatEditUpdate(
        oldVal,
        const TextEditingValue(
          text: '500abc',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      expect(res.text, '500');
    });
  });
}
