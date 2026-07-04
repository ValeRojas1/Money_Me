import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

void main() {
  group('MoneyFormField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyFormField(label: 'Email'))),
      );
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyFormField(hintText: 'Enter email'))),
      );
      expect(find.text('Enter email'), findsWidgets);
    });

    testWidgets('renders prefix icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyFormField(prefixIcon: Icons.email))),
      );
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('validates input', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: MoneyFormField(
                label: 'Required',
                validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
              ),
            ),
          ),
        ),
      );
      formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(find.text('Required field'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyFormField(obscureText: true))),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });

    testWidgets('triggers onChanged', (tester) async {
      String? changed;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyFormField(onChanged: (v) => changed = v))),
      );
      await tester.enterText(find.byType(TextFormField), 'test');
      expect(changed, 'test');
    });

    testWidgets('disables field when enabled is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyFormField(enabled: false))),
      );
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });
  });
}
