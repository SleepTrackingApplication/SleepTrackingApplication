import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/authorization_screen.dart';

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Sleep Tracking'), findsOneWidget);
    expect(find.text('Authorization'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });

  testWidgets('LoginScreen form interaction', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Enter text in username field
    await tester.enterText(find.byType(TextField).first, 'testuser');
    await tester.pumpAndSettle();

    // Verify text was entered
    expect(find.text('testuser'), findsOneWidget);
  });
}
