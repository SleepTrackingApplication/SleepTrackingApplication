import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/tracker_screen.dart';
import '../utils.dart';

void main() {
  testWidgets('TrackerScreen renders correctly', (WidgetTester tester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await tester.pumpWidget(const MaterialApp(home: TrackerScreen()));

    expect(find.text('Sleep Tracking'), findsOneWidget);
    expect(
      find.byType(Icon),
      findsNWidgets(3),
    ); // Bedtime, wakeup, and circle icon
    expect(find.textContaining('Bedtime:'), findsOneWidget);
    expect(find.textContaining('Wake up:'), findsOneWidget);
    expect(find.textContaining('Start session'), findsOneWidget);
  });

  testWidgets('TrackerScreen time selection', (WidgetTester tester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TrackerScreen())),
    );

    expect(find.text('9h 0m'), findsOneWidget);

    await tester.tap(find.textContaining('Bedtime:'));
    await tester.pumpAndSettle();

    expect(find.byType(TimePickerDialog), findsOneWidget);
  });
}
