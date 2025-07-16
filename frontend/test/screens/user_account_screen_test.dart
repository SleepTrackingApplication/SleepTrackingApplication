import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/user_account_screen.dart';
import '../utils.dart';

void main() {
  testWidgets('ProfileScreen renders correctly', (WidgetTester tester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(changeTheme: (mode) {})),
    );

    expect(find.text('Sleep Tracking'), findsOneWidget);
    expect(find.text('My account'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('JohnDoe'), findsOneWidget);
    expect(find.text('Leaderboard Position'), findsOneWidget);
    expect(find.text('#42'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('1200 points'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
  });

  testWidgets('ProfileScreen theme switching', (WidgetTester tester) async {
    FlutterError.onError = ignoreOverflowErrors;

    bool darkMode = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileScreen(
            changeTheme: (mode) {
              darkMode = mode == ThemeMode.dark;
            },
          ),
        ),
      ),
    );

    // Find and toggle the theme switch
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
  });
}
