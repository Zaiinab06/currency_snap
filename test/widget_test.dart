import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_snap/core/constants/app_constants.dart';
import 'package:currency_snap/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.cacheKeyRates:
          '{"baseCurrency":"USD","rates":{"EUR":0.92,"PKR":278.5,"GBP":0.79},"lastUpdated":"2026-08-25T11:00:00.000Z"}',
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(CurrencySnapApp(prefs: prefs));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(CurrencySnapApp), findsOneWidget);
  });
}


