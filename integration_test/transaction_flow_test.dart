import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money_me/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Transaction Flow E2E', () {
    testWidgets('navigate to transactions page and see list', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'e2e@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'TestPass1!');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);

      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();

      expect(find.text('Transactions'), findsOneWidget);
    });
  });
}
