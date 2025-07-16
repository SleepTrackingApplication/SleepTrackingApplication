import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/leaderboard_screen.dart';

void main() {
  testWidgets('LeaderboardScreen renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LeaderboardScreen()));

    expect(find.text('Sleep Tracking'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Place'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);

    // Check for sample data
    expect(find.text('SleepMaster'), findsOneWidget);
    expect(find.text('2450'), findsOneWidget);
  });

  testWidgets('LeaderboardScreen displays all entries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LeaderboardScreen()));

    // Verify all entries are displayed
    expect(
      find.descendant(of: find.byType(ListView), matching: find.byType(Row)),
      findsAtLeast(5),
    );
  });
}
