import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/registration_screen.dart';

void main() {
  testWidgets('RegistrationScreen renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));

    expect(find.text('Sleep Tracking'), findsOneWidget);
    expect(find.text('Registration'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });

  testWidgets('RegistrationScreen form interaction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));

    // Enter text in all fields
    await tester.enterText(find.byType(TextField).at(0), 'newuser');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.pump();

    expect(find.text('newuser'), findsOneWidget);
    expect(find.text('password123'), findsNWidgets(2));
  });
}
