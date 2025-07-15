import 'package:flutter/material.dart';
import 'screens/authorization_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/tracker_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
      // Router to registration and login pages
      routes: {
        '/registration': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/tracker': (context) => const TrackerScreen(), 
      },
    );
  }
}
