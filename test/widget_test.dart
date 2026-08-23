import 'package:flutter_test/flutter_test.dart';
import 'package:currency_snap/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CurrencySnapApp());
    expect(find.byType(CurrencySnapApp), findsOneWidget);
  });
}
