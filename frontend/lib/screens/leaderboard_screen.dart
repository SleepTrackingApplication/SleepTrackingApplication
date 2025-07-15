import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Temporary data (in the real application it will be loaded from the backend)
  final List<Map<String, dynamic>> _leaderboardData = [
    {'rank': 1, 'username': 'SleepMaster', 'balance': 2450},
    {'rank': 2, 'username': 'Dream', 'balance': 2300},
    {'rank': 3, 'username': 'NightOwl', 'balance': 2150},
    {'rank': 4, 'username': 'PillowPrince', 'balance': 1980},
    {'rank': 5, 'username': 'MoonWalker', 'balance': 1820},
    {'rank': 6, 'username': 'Star', 'balance': 1750},
    {'rank': 7, 'username': 'BedtimeBuddy', 'balance': 1620},
    {'rank': 8, 'username': 'King', 'balance': 1500},
    {'rank': 9, 'username': 'Duke', 'balance': 1420},
    {'rank': 10, 'username': 'NapNinja', 'balance': 1350},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF1A1032),
              Color(0xFF2C1A64),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Sleep Tracking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderText('Place'),
                      _buildHeaderText('Username'),
                      _buildHeaderText('Balance'),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.separated(
                    itemCount: _leaderboardData.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final entry = _leaderboardData[index];
                      final isTopThree = entry['rank'] <= 3;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0, 
                          horizontal: 20
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${entry['rank']}',
                              style: TextStyle(
                                color: isTopThree 
                                    ? Colors.white 
                                    : const Color.fromARGB(179, 180, 180, 180),
                                fontSize: 20,
                                fontWeight: isTopThree 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              entry['username'],
                              style: TextStyle(
                                color: isTopThree 
                                    ? Colors.white 
                                    : const Color.fromARGB(179, 180, 180, 180),
                                fontSize: 18,
                                fontWeight: isTopThree 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              '${entry['balance']}',
                              style: TextStyle(
                                color: isTopThree 
                                    ? Colors.white 
                                    : const Color.fromARGB(179, 180, 180, 180),
                                fontSize: 18,
                                fontWeight: isTopThree 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Column headers
  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.purpleAccent.withOpacity(0.8),
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}