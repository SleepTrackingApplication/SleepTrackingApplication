import 'package:flutter/material.dart';
import 'package:frontend/screens/session_screen.dart';
import 'screens/authorization_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/tracker_screen.dart';
import 'screens/user_account_screen.dart';
//import 'screens/leaderboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1032),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C1A64),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/registration': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/session': (context) => const SessionScreen(),
        //'/profile': (context) => ProfileScreen(changeTheme: (_) {}),
        '/tracker': (context) => MainApp(changeTheme: (_) {}),
      },
    );
  }
}

class MainApp extends StatefulWidget {
  final Function(ThemeMode) changeTheme;
  const MainApp({super.key, required this.changeTheme});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TrackerScreen(),
      //const LeaderboardScreen(),
      //ProfileScreen(changeTheme: widget.changeTheme),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isSessionScreen = ModalRoute.of(context)?.settings.name == '/session';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: isSessionScreen 
          ? null
          : Container(
              height: 60,
              color: isDark ? const Color(0xFF2C1A64) : Color(0xFFF3E5F5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.nights_stay, 
                      color: _currentIndex == 0 
                        ? (isDark ? Colors.white : Colors.purple)
                        : (isDark ? const Color.fromARGB(179, 180, 180, 180) : Colors.grey)),
                    onPressed: () => setState(() => _currentIndex = 0),
                  ),
                  IconButton(
                    icon: Icon(Icons.assessment, 
                      color: _currentIndex == 1 
                        ? (isDark ? Colors.white : Colors.purple)
                        : (isDark ? const Color.fromARGB(179, 180, 180, 180) : Colors.grey)),
                    onPressed: () => setState(() => _currentIndex = 1),
                  ),
                  IconButton(
                    icon: Icon(Icons.person, 
                      color: _currentIndex == 2 
                        ? (isDark ? Colors.white : Colors.purple)
                        : (isDark ? const Color.fromARGB(179, 180, 180, 180) : Colors.grey)),
                    onPressed: () => setState(() => _currentIndex = 2),
                  ),
                ],
              ),
            ),
    );
  }
}