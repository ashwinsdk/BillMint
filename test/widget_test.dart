// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:billmint/main.dart';

void main() {
  testWidgets('BillMint app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: BillMintApp()));

    // Verify that BillMint home screen loads
    expect(find.text('BillMint'), findsOneWidget);

    // Verify navigation sections exist
    expect(find.text('Customers'), findsWidgets);
    expect(find.text('Products'), findsWidgets);
    expect(find.text('Invoices'), findsWidgets);
  });
}
