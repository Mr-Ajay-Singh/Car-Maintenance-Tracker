import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class TimeUtils {
  /// Converts TimeOfDay to TZDateTime for today
  static tz.TZDateTime timeOfDayToTZDateTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
  }

  /// Gets the next occurrence of a time from now
  static tz.TZDateTime getNextOccurrence(TimeOfDay time, int weekday) {
    final now = timeOfDayToTZDateTime(TimeOfDay.now());
    
    var scheduledDate = timeOfDayToTZDateTime(time);
    
    debugPrint('Current time: ${now.toString()} , $scheduledDate');

    // If the time is in the past, start from tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Adjust to the next occurrence of the weekday
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // If we've found a date in the past, add a week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  /// Convert TZDateTime to TimeOfDay
  static TimeOfDay tzDateTimeToTimeOfDay(tz.TZDateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  /// Convert DateTime to TimeOfDay
  static TimeOfDay dateTimeToTimeOfDay(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  /// Convert DateTime to TZDateTime
  static tz.TZDateTime dateTimeToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Get the current time as TimeOfDay
  static TimeOfDay getCurrentTimeOfDay() {
    final now = tz.TZDateTime.now(tz.local);
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }
}
