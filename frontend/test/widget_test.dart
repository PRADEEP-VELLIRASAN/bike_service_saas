// Basic Flutter widget test for Bike Service App

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bike_service_app/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BikeServiceApp());

    // Verify that the app loads (shows loading state or login screen)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
