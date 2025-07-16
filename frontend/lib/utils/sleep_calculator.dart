import 'package:flutter/material.dart';

class SleepCalculator {
  static (int, String) calculateSleepDuration(
    TimeOfDay bedtime,
    TimeOfDay wakeup,
  ) {
    int bedtimeInMinutes = bedtime.hour * 60 + bedtime.minute;
    int wakeupInMinutes = wakeup.hour * 60 + wakeup.minute;

    if (wakeupInMinutes < bedtimeInMinutes) {
      wakeupInMinutes += 24 * 60;
    }

    final totalMinutes = wakeupInMinutes - bedtimeInMinutes;
    final hours = (totalMinutes / 60).floor();
    final minutes = (totalMinutes % 60).round();

    return (totalMinutes, '${hours}h ${minutes}m');
  }

  static String formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
}
