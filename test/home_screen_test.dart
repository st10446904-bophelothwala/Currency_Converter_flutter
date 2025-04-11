import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/main.dart';
import 'package:currency_converter/pages/home.dart';

void main() {
  group('Currency Converter Tests', () {
    //  testWidgets('Name of the test', what do I want test);
    testWidgets('Dropdowns loads all currencies', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        )
      );

      // find all dropdowns
      final dropdowns = find.byType(DropdownButton<String>);
      expect(dropdowns, findsNWidgets(2));

      // Tap first dropdown and check options
      await tester.tap(dropdowns.first);
      await tester.pumpAndSettle();

      expect(find.text('South African Rand (R)'), findsWidgets);
      expect(find.text('US Dollars (\$)'), findsWidgets);
      expect(find.text('Chinese Yuan (\\Y)'), findsWidgets);
    });

    testWidgets('Currency Converter Tests Conversions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        )
      );

      await tester.pumpAndSettle();

      // Select SA Rand (R) in the first dropdown
      await tester.tap(find.byType(DropdownButton<String>).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('South African Rand (R)').last);
      await tester.pumpAndSettle();

      // Select US Dollar ($) in the second dropdown
      await tester.tap(find.byType(DropdownButton<String>).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('US Dollar (\$)').last);
      await tester.pumpAndSettle();

      // Entering a value in the input field
      await tester.enterText(find.byType(TextField).first, '100');
      await tester.pump();

      // Tap the update button
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // Conversion result
      expect(('R100 = \$5.20'), findsOneWidget);
    });

    testWidgets('Shows error when both dropdowns are not selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        )
      );

      await tester.pumpAndSettle();

      // Enter a number without selecting currencies
      await tester.enterText(find.byType(TextField).first, '50');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);

    });
    // Select dropdowns without entering a number
    testWidgets('Shows error when one or both input are empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        )
      );

      await tester.pumpAndSettle();

      // Selected currencies without entering a number

      // First Input testing empty input
      await tester.enterText(find.byType(TextField).first, '');
      
      await tester.tap(find.byType(DropdownButton<String>).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('South African Rand (R)').last);
      await tester.pumpAndSettle();

      // Second Input testing empty input
      await tester.enterText(find.byType(TextField).last, '');

      await tester.tap(find.byType(DropdownButton<String>).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('US Dollar (\$)').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    // run flutter test test/file_test.dart
  });
}