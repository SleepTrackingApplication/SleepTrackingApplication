import 'package:flutter/material.dart';
import 'package:frontend/screens/authorization_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(ThemeMode) changeTheme;
  const ProfileScreen({super.key, required this.changeTheme});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = "JohnDoe";
  int _leaderboardPosition = 42;
  int _balance = 1200;

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _changePassword() {
    Navigator.pushNamed(context, '/change-password');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF1A1032), Color(0xFF2C1A64)],
                )
              : LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.purple.shade100, Colors.blue.shade100],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Sleep Tracking',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _logout,
                        icon: Icon(
                          Icons.logout,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : const Color.fromARGB(255, 243, 243, 243),
                  ),
                  child: Icon(
                    Icons.person,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'My account',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    _buildInfoItem("Username", _username, context),
                    const SizedBox(height: 20),
                    _buildInfoItem("Leaderboard Position", "#$_leaderboardPosition", context),
                    const SizedBox(height: 20),
                    _buildInfoItem("Balance", "$_balance points", context),
                    const SizedBox(height: 20),
                    // Theme switcher
                    Container(
                      width: 350,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.white.withOpacity(0.1) 
                            : const Color.fromARGB(255, 243, 243, 243),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                color: isDark ? Colors.purpleAccent : Colors.amber,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isDark ? 'Dark Mode' : 'Light Mode',
                                style: TextStyle(
                                  color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (value) {
                              widget.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
                            },
                            activeColor: Colors.purpleAccent,
                            activeTrackColor: Colors.purple[300],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                SizedBox(
                  width: 300,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : const Color.fromARGB(255, 243, 243, 243),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.black : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withOpacity(0.1) 
            : const Color.fromARGB(255, 243, 243, 243),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}