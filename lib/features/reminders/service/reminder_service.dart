import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../common/data/database_helper.dart';
import '../../../common/data/firestore_helper.dart';
import '../data/models/reminder_model.dart';

/// ReminderService - Service class for reminder management
class ReminderService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // CREATE
  Future<String> addReminder(ReminderModel reminder) async {
    final db = await _dbHelper.database;

    await db.rawInsert(ReminderModel.queryInsert, [
      reminder.id,
      reminder.vehicleId,
      reminder.userId,
      reminder.title,
      reminder.type,
      reminder.description,
      reminder.dueDate?.toIso8601String(),
      reminder.dueOdometer,
      reminder.isRecurring ? 1 : 0,
      reminder.recurrenceType?.name,
      reminder.recurrenceWeekdays?.join(','),
      reminder.recurrenceMonthDay,
      reminder.recurringDays,
      reminder.recurringOdometer,
      reminder.notificationEnabled ? 1 : 0,
      reminder.notificationDaysBefore,
      reminder.notificationOdometerBefore,
      reminder.isCompleted ? 1 : 0,
      reminder.completedDate?.toIso8601String(),
      reminder.createdAt.toIso8601String(),
      reminder.updatedAt.toIso8601String(),
      reminder.isDeleted ? 1 : 0,
      reminder.isSynced ? 1 : 0,
      reminder.firebaseId,
      reminder.lastSyncedAt?.toIso8601String(),
    ]);

    // Schedule notification
    if (reminder.notificationEnabled) {
      await _scheduleNotification(reminder);
    }

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        await _syncReminderToFirestore(reminder);
      } catch (e) {
        debugPrint('Sync failed: $e');
      }
    }

    return reminder.id;
  }

  // READ
  Future<List<ReminderModel>> getAllReminders(String userId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ReminderModel.queryGetAll, [userId]);
    return results.map((map) => ReminderModel.fromMap(map)).toList();
  }

  Future<List<ReminderModel>> getRemindersByVehicle(String vehicleId) async {
    final db = await _dbHelper.database;
    final results =
        await db.rawQuery(ReminderModel.queryGetByVehicle, [vehicleId]);
    return results.map((map) => ReminderModel.fromMap(map)).toList();
  }

  Future<List<ReminderModel>> getActiveReminders(String vehicleId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ReminderModel.queryGetActive, [vehicleId]);
    return results.map((map) => ReminderModel.fromMap(map)).toList();
  }

  Future<ReminderModel?> getReminderById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ReminderModel.queryGetById, [id]);
    if (results.isEmpty) return null;
    return ReminderModel.fromMap(results.first);
  }

  Future<List<ReminderModel>> getUpcomingReminders(
    String userId,
    int limit,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ReminderModel.queryGetUpcoming,
      [userId, DateTime.now().toIso8601String(), limit],
    );
    return results.map((map) => ReminderModel.fromMap(map)).toList();
  }

  Future<List<ReminderModel>> getOverdueReminders(String userId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ReminderModel.queryGetOverdue,
      [userId, DateTime.now().toIso8601String()],
    );
    return results.map((map) => ReminderModel.fromMap(map)).toList();
  }

  // UPDATE
  Future<void> updateReminder(ReminderModel reminder) async {
    final db = await _dbHelper.database;
    final updatedReminder = reminder.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await db.rawUpdate(ReminderModel.queryUpdate, [
      updatedReminder.title,
      updatedReminder.type,
      updatedReminder.description,
      updatedReminder.dueDate?.toIso8601String(),
      updatedReminder.dueOdometer,
      updatedReminder.isRecurring ? 1 : 0,
      updatedReminder.recurrenceType?.name,
      updatedReminder.recurrenceWeekdays?.join(','),
      updatedReminder.recurrenceMonthDay,
      updatedReminder.recurringDays,
      updatedReminder.recurringOdometer,
      updatedReminder.notificationEnabled ? 1 : 0,
      updatedReminder.notificationDaysBefore,
      updatedReminder.notificationOdometerBefore,
      updatedReminder.updatedAt.toIso8601String(),
      updatedReminder.id,
    ]);

    // Reschedule notification
    await _cancelNotification(reminder.id);
    if (updatedReminder.notificationEnabled) {
      await _scheduleNotification(updatedReminder);
    }

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        await _syncReminderToFirestore(updatedReminder);
      } catch (e) {
        debugPrint('Sync failed: $e');
      }
    }
  }

  // COMPLETE/UNCOMPLETE
  Future<void> markCompleted(String id) async {
    final db = await _dbHelper.database;
    final reminder = await getReminderById(id);
    if (reminder == null) return;

    await db.rawUpdate(ReminderModel.queryMarkCompleted, [
      DateTime.now().toIso8601String(),
      DateTime.now().toIso8601String(),
      id,
    ]);

    // Cancel notification
    await _cancelNotification(id);

    // Create new reminder if recurring
    if (reminder.isRecurring) {
      await _createRecurringReminder(reminder);
    }

    // Sync
    if (await _isOnline()) {
      try {
        final updated = await getReminderById(id);
        if (updated != null) {
          await _syncReminderToFirestore(updated);
        }
      } catch (e) {
        debugPrint('Sync failed: $e');
      }
    }
  }

  Future<void> markIncomplete(String id) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(ReminderModel.queryMarkIncomplete, [
      DateTime.now().toIso8601String(),
      id,
    ]);

    final reminder = await getReminderById(id);
    if (reminder != null && reminder.notificationEnabled) {
      await _scheduleNotification(reminder);
    }

    // Sync
    if (await _isOnline()) {
      try {
        final updated = await getReminderById(id);
        if (updated != null) {
          await _syncReminderToFirestore(updated);
        }
      } catch (e) {
        debugPrint('Sync failed: $e');
      }
    }
  }

  // DELETE (soft delete)
  Future<void> deleteReminder(String id) async {
    final db = await _dbHelper.database;
    final reminder = await getReminderById(id);

    await db.rawUpdate(ReminderModel.querySoftDelete, [
      DateTime.now().toIso8601String(),
      id,
    ]);

    // Cancel notification
    await _cancelNotification(id);

    // Try to sync deletion to Firestore
    if (await _isOnline() && reminder != null && reminder.firebaseId != null) {
      try {
        await _deleteFromFirestore(reminder.userId, reminder.firebaseId!);
      } catch (e) {
        debugPrint('Sync failed: $e');
      }
    }
  }

  // NOTIFICATION MANAGEMENT
  /// Initialize notification plugin
  Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    debugPrint('✅ Notifications initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Schedule notification for a reminder
  Future<void> _scheduleNotification(ReminderModel reminder) async {
    if (!reminder.notificationEnabled || reminder.dueDate == null) return;

    try {
      // Calculate notification date
      final notificationDate = reminder.dueDate!
          .subtract(Duration(days: reminder.notificationDaysBefore));

      // Only schedule if notification date is in the future
      if (notificationDate.isAfter(DateTime.now())) {
        final scheduledDate = tz.TZDateTime.from(notificationDate, tz.local);

        const androidDetails = AndroidNotificationDetails(
          'reminders_channel',
          'Vehicle Maintenance Reminders',
          channelDescription: 'Notifications for upcoming vehicle maintenance',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const details = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _notificationsPlugin.zonedSchedule(
          reminder.id.hashCode,
          reminder.title,
          reminder.description ?? 'Maintenance reminder is coming up',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: reminder.id,
        );

        debugPrint('✅ Notification scheduled for ${reminder.title} at $notificationDate');
      }
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }

  /// Cancel notification for a reminder
  Future<void> _cancelNotification(String reminderId) async {
    try {
      await _notificationsPlugin.cancel(reminderId.hashCode);
      debugPrint('✅ Notification canceled for reminder: $reminderId');
    } catch (e) {
      debugPrint('❌ Error canceling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('✅ All notifications canceled');
    } catch (e) {
      debugPrint('❌ Error canceling all notifications: $e');
    }
  }

  /// Create a new recurring reminder when the current one is completed
  Future<void> _createRecurringReminder(ReminderModel completed) async {
    if (!completed.isRecurring) return;

    DateTime? newDueDate;
    int? newDueOdometer;

    // Calculate new due date
    if (completed.dueDate != null) {
      if (completed.recurrenceType == RecurrenceType.daily) {
        newDueDate = completed.dueDate!.add(const Duration(days: 1));
      } else if (completed.recurrenceType == RecurrenceType.weekly &&
          completed.recurrenceWeekdays != null &&
          completed.recurrenceWeekdays!.isNotEmpty) {
        // Find next weekday
        final currentWeekday = completed.dueDate!.weekday;
        final sortedDays = List<int>.from(completed.recurrenceWeekdays!)..sort();
        
        int? nextDay;
        for (final day in sortedDays) {
          if (day > currentWeekday) {
            nextDay = day;
            break;
          }
        }
        
        if (nextDay != null) {
          // Same week
          newDueDate = completed.dueDate!.add(Duration(days: nextDay - currentWeekday));
        } else {
          // Next week (first available day)
          nextDay = sortedDays.first;
          newDueDate = completed.dueDate!.add(Duration(days: 7 - currentWeekday + nextDay));
        }
      } else if (completed.recurrenceType == RecurrenceType.monthly &&
          completed.recurrenceMonthDay != null) {
        // Next month
        var nextMonth = DateTime(
          completed.dueDate!.year,
          completed.dueDate!.month + 1,
          completed.recurrenceMonthDay!,
        );
        
        // Handle invalid dates (e.g. Feb 30)
        while (nextMonth.month > completed.dueDate!.month + 1) {
           nextMonth = nextMonth.subtract(const Duration(days: 1));
        }
        newDueDate = nextMonth;
      } else if (completed.recurringDays != null) {
        // Interval (legacy or explicit)
        newDueDate = completed.dueDate!.add(Duration(days: completed.recurringDays!));
      }
    }

    // Calculate new due odometer
    if (completed.dueOdometer != null && completed.recurringOdometer != null) {
      newDueOdometer = completed.dueOdometer! + completed.recurringOdometer!;
    }

    // Create new reminder
    final newReminder = completed.copyWith(
      id: const Uuid().v4(),
      dueDate: newDueDate,
      dueOdometer: newDueOdometer,
      isCompleted: false,
      completedDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      firebaseId: null,
      lastSyncedAt: null,
    );

    await addReminder(newReminder);
  }

  // SYNC OPERATIONS
  Future<void> syncUnsyncedReminders(String userId) async {
    if (!await _isOnline()) return;

    final db = await _dbHelper.database;
    final unsyncedRows = await db.rawQuery(
      ReminderModel.queryGetUnsynced,
      [userId],
    );

    for (final row in unsyncedRows) {
      try {
        final reminder = ReminderModel.fromMap(row);
        await _syncReminderToFirestore(reminder);
      } catch (e) {
        debugPrint('Failed to sync reminder: $e');
      }
    }
  }

  Future<void> _syncReminderToFirestore(ReminderModel reminder) async {
    final firebaseId = await FirestoreHelper.pushReminder(reminder);

    final db = await _dbHelper.database;
    await db.rawUpdate(ReminderModel.queryMarkSynced, [
      firebaseId,
      DateTime.now().toIso8601String(),
      reminder.id,
    ]);
  }

  Future<void> _deleteFromFirestore(String userId, String firebaseId) async {
    await FirestoreHelper.deleteReminder(userId, firebaseId);
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
