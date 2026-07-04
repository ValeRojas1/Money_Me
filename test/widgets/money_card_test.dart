import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_me/shared/widgets/money_card.dart';

void main() {
  group('MoneyCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyCard(child: Text('Content')))),
      );
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoneyCard(child: Text('Tap me'), onTap: () => tapped = true),
          ),
        ),
      );
      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoneyCard(child: Text('Padded'), padding: EdgeInsets.all(20)),
          ),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, EdgeInsets.all(20));
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoneyCard(child: Text('Colored'), color: Colors.red),
          ),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('applies custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoneyCard(child: Text('Tall'), height: 200),
          ),
        ),
      );
      expect(find.text('Tall'), findsOneWidget);
    });

    testWidgets('renders without onTap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoneyCard(child: Text('Static')))),
      );
      expect(find.text('Static'), findsOneWidget);
    });
  });
}
