// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:generate_pdf/main.dart';

void main() {
  testWidgets('PDF generator app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads with the expected title and button.
    expect(find.text('Generate PDF from HTML'), findsOneWidget);
    expect(find.text('Generate and Open PDF'), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
  });
}
