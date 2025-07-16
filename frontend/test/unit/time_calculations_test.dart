import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/sleep_calculator.dart';

void main() {
  test('SleepCalculator - same day calculation', () {
    final bedtime = TimeOfDay(hour: 22, minute: 0);
    final wakeup = TimeOfDay(hour: 7, minute: 30);

    final result = SleepCalculator.calculateSleepDuration(bedtime, wakeup);

    expect(result.$1, 570); // 9.5 hours in minutes
    expect(result.$2, '9h 30m');
  });

  test('SleepCalculator - overnight calculation', () {
    final bedtime = TimeOfDay(hour: 23, minute: 30);
    final wakeup = TimeOfDay(hour: 6, minute: 15);

    final result = SleepCalculator.calculateSleepDuration(bedtime, wakeup);

    expect(result.$1, 405); // 6.75 hours in minutes
    expect(result.$2, '6h 45m');
  });

  test('SleepCalculator - time formatting', () {
    expect(SleepCalculator.formatTime(90), '1h 30m');
    expect(SleepCalculator.formatTime(125), '2h 5m');
    expect(SleepCalculator.formatTime(60), '1h 0m');
  });
}
