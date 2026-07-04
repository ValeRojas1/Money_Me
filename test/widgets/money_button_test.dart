import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_me/shared/widgets/money_button.dart';

void main() {
  group('MoneyButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyButton(label: 'Save'))),
      );
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyButton(label: 'Click', onPressed: () => pressed = true))),
      );
      await tester.tap(find.text('Click'));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyButton(label: 'Save', isLoading: true))),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('is disabled when loading', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyButton(label: 'Save', isLoading: true, onPressed: () => pressed = true))),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);
    });

    testWidgets('expanded takes full width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: MoneyButton(label: 'Full', expanded: true)))),
      );
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.style?.minimumSize, isNotNull);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyButton(label: 'Save', icon: Icons.save))),
      );
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('small size uses 36 height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyButton(label: 'Small', size: MoneyButtonSize.small))),
      );
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.style?.minimumSize?.resolve(<WidgetState>{})?.height, 36);
    });
  });
}
