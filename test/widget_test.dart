// ============================================================
// FILE: test/widget_test.dart
//
// PURPOSE: A basic smoke test that confirms the app launches
//          without crashing.
//
// As we build more screens, we'll add proper widget tests here.
// For now this just verifies the app boots up correctly.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yahweh_frontend/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Build the app and trigger the first frame.
    await tester.pumpWidget(const YahwehApp());

    // Verify the app renders something on screen.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
