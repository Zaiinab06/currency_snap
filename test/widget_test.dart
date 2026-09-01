import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('CurrencySnap'),
          ),
        ),
      ),
    );
    expect(find.text('CurrencySnap'), findsOneWidget);
  });
}
