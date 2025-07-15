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
  // Show loading indicator, while getting data from tracker_screen to avoid error
  if (_totalDuration == null || _startTime == null) {
    return const Scaffold(
      backgroundColor: Color(0xFF2C1A64),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  final remainingSeconds = (_totalDuration! * 60) - _elapsed.inSeconds;
  final isCompleted = remainingSeconds <= 0;
  final hours = (remainingSeconds ~/ 3600).abs();
  final minutes = ((remainingSeconds % 3600) ~/ 60).abs();
  final seconds = (remainingSeconds % 60).abs();

  return Scaffold(
    backgroundColor: const Color(0xFF2C1A64),
    body: Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                    'Sleep Tracking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
            Text(
              isCompleted ? "Session Completed!" : "Sleep Session",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // Timer
            Text(
              isCompleted
                  ? "00:00:00"
                  : "${hours.toString().padLeft(2, '0')}:"
                      "${minutes.toString().padLeft(2, '0')}:"
                      "${seconds.toString().padLeft(2, '0')}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // Button to finish session
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _stopSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "End Session",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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