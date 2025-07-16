import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/session_screen.dart';

void main() {
  testWidgets('SessionScreen renders correctly with data', (
    WidgetTester tester,
  ) async {
    final startTime = DateTime.now();
    const duration = 480; // 8 hours
    const testTxt = 'Test';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/session',
                    arguments: {'duration': duration, 'startTime': startTime},
                  );
                },
                child: Text(testTxt),
              );
            },
          ),
        ),
        routes: {'/session': (context) => SessionScreen()},
      ),
    );

    await tester.tap(find.text(testTxt));
    await tester.pumpAndSettle();

    expect(find.text('Sleep Session'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('SessionScreen shows completed state', (
    WidgetTester tester,
  ) async {
    final startTime = DateTime.now().subtract(const Duration(hours: 9));
    const duration = 480; // 8 hours

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    settings: RouteSettings(
                      arguments: {'duration': duration, 'startTime': startTime},
                    ),
                    builder: (context) => SessionScreen(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Session Completed!'), findsOneWidget);
  });
}
