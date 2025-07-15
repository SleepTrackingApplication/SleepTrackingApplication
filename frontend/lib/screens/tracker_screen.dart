import 'package:flutter/material.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  // Initial values
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeup = const TimeOfDay(hour: 7, minute: 0);
  String _sleepDuration = '9h 0m';
  int _totalMinutes = 540;

  // Function to select bedtime or wake up time
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
    int bedtimeInMinutes = _bedtime.hour * 60 + _bedtime.minute;
    int wakeupInMinutes = _wakeup.hour * 60 + _wakeup.minute;
    
    if (wakeupInMinutes < bedtimeInMinutes) {
      wakeupInMinutes += 24 * 60;
    }
    
    final totalMinutes = wakeupInMinutes - bedtimeInMinutes;
    final hours = (totalMinutes / 60).floor();
    final minutes = (totalMinutes % 60).round();
    
    setState(() {
      _totalMinutes = totalMinutes;
      _sleepDuration = '${hours}h ${minutes}m';
    });
  }

  @override
  void initState() {
    super.initState();
    _calculateSleepDuration();
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 40),
                  
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.purpleAccent.withOpacity(0.6),
                        width: 12,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bedtime_outlined,
                            color: Colors.white,
                            size: 50,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _sleepDuration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sleep Duration',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
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
                      color: Colors.white.withOpacity(0.1),
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
                                    color: Color.fromARGB(255, 17, 0, 255),
                                    size: 30,
                                  ),
                              const SizedBox(width: 15),
                              const Text(
                                'Bedtime:  ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _bedtime.format(context),
                                style: const TextStyle(
                                  color: Colors.white,
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
                          color: Colors.white.withOpacity(0.1),
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
                                    color: Color(0xFFF8B320),
                                    size: 30,
                                  ),
                              const SizedBox(width: 15),
                              const Text(
                                'Wake up:  ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _wakeup.format(context),
                                style: const TextStyle(
                                  color: Colors.white,
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
                        Navigator.pushNamed(context, '/session',
                          arguments: {
                            'duration' : _totalMinutes,
                            'startTime' : DateTime.now(),
                          });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      child: const Text(
                        'Start session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.black.withOpacity(0.3),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.nights_stay, color: Colors.white),
            Icon(Icons.assessment, color: Colors.white70),
            Icon(Icons.person, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}