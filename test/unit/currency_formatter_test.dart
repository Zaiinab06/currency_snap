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
}
