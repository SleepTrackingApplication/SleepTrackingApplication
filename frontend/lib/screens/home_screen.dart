import 'package:flutter/material.dart';
import 'registration_screen.dart';

// Class HomeScreen represents main screen of app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    // A blueprint for the future for creating a light-themed switcher
    final gradientColors = Theme.of(context).brightness == Brightness.dark
        ? [Color(0xFF1A1032), Color(0xFF2C1A64)]
        : [Colors.purple.shade100, Colors.blue.shade100];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: gradientColors,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? screenWidth * 0.9 : 500,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  // Text for app name
                  child: Text(
                    'Sleep Tracking',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
                // Container with icon for app (icon is from Figma)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'images/home_icon2.png',
                      width: isMobile ? 300 : 400,
                      height: isMobile ? 300 : 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Block for three buttons
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      // Register button with transfer to registration screen
                      _buildButton(context, 'Register', Colors.white, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      }),
                      // The indentation between the buttons
                      const SizedBox(height: 15),
                      // Login button with transfer to login screen
                      _buildButton(context, 'Log in', Colors.white, () {
                        Navigator.pushNamed(context, '/login');
                      }),
                      const SizedBox(height: 15),
                      // Exit button, just shows alert that this button was used; it will be changed for real functionaly later
                      _buildButton(context, 'Exit', Colors.white, () {
                        _showSnackbar(context, 'Exit');
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helpful class to create buttons
  Widget _buildButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 300,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.8),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.5),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Method to show alerts (for exit button in this case)
  void _showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text'),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}