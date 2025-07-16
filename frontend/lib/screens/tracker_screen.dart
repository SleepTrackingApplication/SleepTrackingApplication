import 'package:flutter/material.dart';
import 'package:frontend/utils/sleep_calculator.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeup = const TimeOfDay(hour: 7, minute: 0);
  String _sleepDuration = '9h 0m';
  int _totalMinutes = 540;

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final initialTime = isBedtime ? _bedtime : _wakeup;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _wakeup = picked;
        }
        _calculateSleepDuration();
      });
    }
  }

  void _calculateSleepDuration() {
    final result = SleepCalculator.calculateSleepDuration(_bedtime, _wakeup);
    setState(() {
      _totalMinutes = result.$1;
      _sleepDuration = result.$2;
    });
  }

  @override
  void initState() {
    super.initState();
    _calculateSleepDuration();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF2C1A64)
          : theme.scaffoldBackgroundColor,
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Sleep Tracking',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: isDark
                            ? Colors.purpleAccent.withOpacity(0.6)
                            : Colors.purple[300]!,
                        width: 12,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bedtime_outlined,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 50,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _sleepDuration,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sleep Duration',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 240,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : const Color.fromARGB(255, 243, 243, 243),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bedtime,
                              color: isDark
                                  ? const Color.fromARGB(255, 17, 0, 255)
                                  : Colors.blue[700],
                              size: 30,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              'Bedtime:  ',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _bedtime.format(context),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 240,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : const Color.fromARGB(255, 243, 243, 243),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: GestureDetector(
                      onTap: () => _selectTime(context, false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wb_sunny,
                              color: isDark
                                  ? const Color(0xFFF8B320)
                                  : Colors.orange[700],
                              size: 30,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              'Wake up:  ',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _wakeup.format(context),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 250,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/session',
                          arguments: {
                            'duration': _totalMinutes,
                            'startTime': DateTime.now(),
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.8)
                            : const Color.fromARGB(255, 243, 243, 243),
                        foregroundColor: isDark ? Colors.black : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      child: Text(
                        'Start session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.black : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
