import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyblock/widgets/stat_row.dart';

void main() {
  group('StatRow Widget Tests', () {
    testWidgets('should display labels and values correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StatRow(label: 'Test Stat', valueA: 10, valueB: 20),
        ),
      ));

      expect(find.text('Test Stat'), findsOneWidget);
      expect(find.text('You: 10'), findsOneWidget);
      expect(find.text('Opponent: 20'), findsOneWidget);
    });

    testWidgets('should color-code correctly when B wins', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StatRow(label: 'Test Stat', valueA: 10, valueB: 20),
        ),
      ));

      // Finder for the You: 10 container
      final youFinder = find.ancestor(
        of: find.text('You: 10'),
        matching: find.byType(Container),
      );
      final youContainer = tester.widget<Container>(youFinder);
      final youBoxDecoration = youContainer.decoration as BoxDecoration;
      expect(youBoxDecoration.border?.top.color, Colors.red);

      // Finder for the Opponent: 20 container
      final opponentFinder = find.ancestor(
        of: find.text('Opponent: 20'),
        matching: find.byType(Container),
      );
      final opponentContainer = tester.widget<Container>(opponentFinder);
      final opponentBoxDecoration = opponentContainer.decoration as BoxDecoration;
      expect(opponentBoxDecoration.border?.top.color, Colors.green);
    });

    testWidgets('should color-code correctly when A wins', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StatRow(label: 'Test Stat', valueA: 50, valueB: 20),
        ),
      ));

      // Finder for the You: 50 container
      final youFinder = find.ancestor(
        of: find.text('You: 50'),
        matching: find.byType(Container),
      );
      final youContainer = tester.widget<Container>(youFinder);
      final youBoxDecoration = youContainer.decoration as BoxDecoration;
      expect(youBoxDecoration.border?.top.color, Colors.green);

      // Finder for the Opponent: 20 container
      final opponentFinder = find.ancestor(
        of: find.text('Opponent: 20'),
        matching: find.byType(Container),
      );
      final opponentContainer = tester.widget<Container>(opponentFinder);
      final opponentBoxDecoration = opponentContainer.decoration as BoxDecoration;
      expect(opponentBoxDecoration.border?.top.color, Colors.red);
    });
  });
}
