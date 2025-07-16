import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int? _totalSeconds;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _isSending = false;
  bool _isCompleted = false;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSession();
    });
  }

  void _initializeSession() {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _totalSeconds = args['duration'] as int;
    _startTime = args['startTime'] as DateTime;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final now = DateTime.now();
        final elapsed = now.difference(_startTime!);
        
        setState(() {
          _elapsed = elapsed;
          _isCompleted = elapsed.inSeconds >= _totalSeconds!;
        });

        if (_isCompleted) {
          _timer?.cancel();
          _stopSession();
        }
      }
    });
  }

  Future<void> _sendSleepData() async {
    setState(() => _isSending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Not authenticated');
      }

      _endTime = DateTime.now().toUtc();
      final durationSeconds = _isCompleted 
          ? _totalSeconds! 
          : _endTime!.difference(_startTime!).inSeconds;

      final response = await http.post(
        Uri.parse('http://localhost:8080/sleep/period'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode({
          'start_period': _startTime!.toIso8601String(),
          'end_period': _endTime!.toIso8601String(),
          'duration': durationSeconds,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save sleep data: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _stopSession() async {
    _timer?.cancel();
    await _sendSleepData();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_totalSeconds == null || _startTime == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF2C1A64) : theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? Colors.white : Colors.purple,
          ),
        ),
      );
    }

    final remainingSeconds = _totalSeconds! - _elapsed.inSeconds;
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
                _isCompleted ? "Session Completed!" : "Sleep Session",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _isCompleted
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
                  onPressed: _isSending ? null : _stopSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : const Color.fromARGB(255, 243, 243, 243),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSending
                      ? const CircularProgressIndicator()
                      : Text(
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