import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/home_screen.dart';

void main() {
  // testWidgets('HomeScreen renders correctly', (WidgetTester tester) async {
  //   await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

  //   expect(find.text('Sleep Tracking'), findsOneWidget);
  //   expect(find.byType(Image), findsOneWidget);
  //   expect(find.text('Register'), findsOneWidget);
  //   expect(find.text('Log in'), findsOneWidget);
  // });

  // testWidgets('HomeScreen button navigation', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: const HomeScreen(),
  //       routes: {
  //         '/login': (context) =>
  //             const Scaffold(body: Center(child: Text('Login Screen'))),
  //         '/registration': (context) =>
  //             const Scaffold(body: Center(child: Text('Registration Screen'))),
  //       },
  //     ),
  //   );

  //   // Test Register button
  //   await tester.tap(find.text('Register'));
  //   await tester.pumpAndSettle();
  //   expect(find.text('Registration Screen'), findsOneWidget);

  //   // Go back
  //   await tester.pageBack();
  //   await tester.pumpAndSettle();

  //   // Test Login button
  //   await tester.tap(find.text('Log in'));
  //   await tester.pumpAndSettle();
  //   expect(find.text('Login Screen'), findsOneWidget);
  // });
}
