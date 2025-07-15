import 'package:flutter/material.dart';
import 'package:frontend/screens/session_screen.dart';
import 'screens/authorization_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/tracker_screen.dart';
import 'screens/user_account_screen.dart';
import 'screens/leaderboard_screen.dart';

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
      // I'll set up routing when the registration and authorization associated with the backup appear
      home: const MainApp(),
      //home: const HomeScreen(),
      routes: {
        '/registration': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/session': (context) => const SessionScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  // Lower bar with buttons
  final List<Widget> _screens = [
    const TrackerScreen(),
    const LeaderboardScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isSessionScreen = ModalRoute.of(context)?.settings.name == '/session';
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: isSessionScreen 
          ? null
          : Container(
              height: 60,
              color: const Color(0xFF2C1A64),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.nights_stay, 
                      color: _currentIndex == 0 ? Colors.white : const Color.fromARGB(179, 180, 180, 180)),
                    onPressed: () => setState(() => _currentIndex = 0),
                  ),
                  IconButton(
                    icon: Icon(Icons.assessment, 
                      color: _currentIndex == 1 ? Colors.white : const Color.fromARGB(179, 180, 180, 180)),
                    onPressed: () => setState(() => _currentIndex = 1),
                  ),
                  IconButton(
                    icon: Icon(Icons.person, 
                      color: _currentIndex == 2 ? Colors.white : const Color.fromARGB(179, 180, 180, 180)),
                    onPressed: () => setState(() => _currentIndex = 2),
                  ),
                ],
              ),
            ),
    );
  }
}