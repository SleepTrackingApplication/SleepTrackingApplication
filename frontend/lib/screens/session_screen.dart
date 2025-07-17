import 'dart:async';
import 'package:flutter/material.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int? _totalDuration;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSession();
    });
  }

  void _initializeSession() {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _totalDuration = args['duration'];
    _startTime = args['startTime'];
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
      }
    });
  }

  void _stopSession() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  
  if (_totalDuration == null || _startTime == null) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF2C1A64) : theme.scaffoldBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          color: isDark ? Colors.white : Colors.purple,
        ),
      ),
    );
  }

  final remainingSeconds = (_totalDuration! * 60) - _elapsed.inSeconds;
  final isCompleted = remainingSeconds <= 0;
  final hours = (remainingSeconds ~/ 3600).abs();
  final minutes = ((remainingSeconds % 3600) ~/ 60).abs();
  final seconds = (remainingSeconds % 60).abs();

  return Scaffold(
    backgroundColor: isDark ? const Color(0xFF2C1A64) : theme.scaffoldBackgroundColor,
    body: Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sleep Tracking',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              isCompleted ? "Session Completed!" : "Sleep Session",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              isCompleted
                  ? "00:00:00"
                  : "${hours.toString().padLeft(2, '0')}:"
                      "${minutes.toString().padLeft(2, '0')}:"
                      "${seconds.toString().padLeft(2, '0')}",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _stopSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : const Color.fromARGB(255, 243, 243, 243),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "End Session",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.black87,
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}