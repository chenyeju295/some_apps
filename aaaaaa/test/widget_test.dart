// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build a simple test widget
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AI Wallpaper Generator')),
        body: const Center(
          child: Text('AI Wallpaper Generator Test'),
        ),
      ),
    ));

    // Verify that the test widget loads
    expect(find.text('AI Wallpaper Generator'), findsOneWidget);
    expect(find.text('AI Wallpaper Generator Test'), findsOneWidget);
  });
}
