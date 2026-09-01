import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  test('Open daily historical API returns valid differing rates for USD/PKR across 7 days', () async {
    final dio = Dio();
    final dates = [
      '2026-08-25',
      '2026-08-26',
      '2026-08-27',
      '2026-08-28',
      '2026-08-29',
      '2026-08-30',
      '2026-08-31',
    ];

    final List<double> rates = [];
    for (final date in dates) {
      final url = 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$date/v1/currencies/usd.json';
      final res = await dio.get(url);
      expect(res.statusCode, 200);
      final rate = (res.data['usd']['pkr'] as num).toDouble();
      rates.add(rate);
      expect(rate, greaterThan(200.0));
    }

    expect(rates.length, 7);
    final high = rates.reduce((a, b) => a > b ? a : b);
    final low = rates.reduce((a, b) => a < b ? a : b);
    // Ensure the rates are authentic and NOT all identical
    expect(high, isNot(equals(low)));
  });
}
