# Reminders Feature - Implementation Plan

## Feature Overview
The Reminders feature allows users to set up maintenance and service reminders based on date (time-based) or odometer readings (mileage-based). Users receive notifications when reminders are due, helping them stay on top of vehicle maintenance schedules.

## Architecture
Following CLAUDE.md guidelines:
- **Data Layer**: Reminder model with SQLite and Firestore operations
- **Service Layer**: Business logic for reminder management and notifications
- **Presentation Layer**: UI components (implemented in UI.md)

---

## Data Layer

### Reminder Model

**File**: `lib/features/reminders/data/models/reminder_model.dart`

```dart
class ReminderModel {
  final String id;
  final String vehicleId;
  final String userId;
  final String title;
  final String type; // service, insurance, registration, inspection, custom
  final String? description;
  final DateTime? dueDate;
  final int? dueOdometer;
  final bool isRecurring;
  final int? recurringDays; // if time-based recurring
  final int? recurringOdometer; // if mileage-based recurring
  final bool notificationEnabled;
  final int notificationDaysBefore;
  final int notificationOdometerBefore;
  final bool isCompleted;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // Sync tracking fields
  final bool isSynced;
  final String? firebaseId;
  final DateTime? lastSyncedAt;

  // Calculated fields
  bool get isOverdue {
    if (isCompleted) return false;
    if (dueDate != null) {
      return DateTime.now().isAfter(dueDate!);
    }
    return false;
  }

  bool get isDueSoon {
    if (isCompleted || isOverdue) return false;
    if (dueDate != null) {
      final daysUntilDue = dueDate!.difference(DateTime.now()).inDays;
      return daysUntilDue <= notificationDaysBefore && daysUntilDue >= 0;
    }
    return false;
  }

  ReminderModel({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.title,
    required this.type,
    this.description,
    this.dueDate,
    this.dueOdometer,
    this.isRecurring = false,
    this.recurringDays,
    this.recurringOdometer,
    this.notificationEnabled = true,
    this.notificationDaysBefore = 7,
    this.notificationOdometerBefore = 500,
    this.isCompleted = false,
    this.completedDate,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseId,
    this.lastSyncedAt,
  });

  // Static SQL queries
  static const String tableName = 'reminders';

  static const String tableCreate = '''
    CREATE TABLE reminders (
      id TEXT PRIMARY KEY,
      vehicleId TEXT NOT NULL,
      userId TEXT NOT NULL,
      title TEXT NOT NULL,
      type TEXT NOT NULL,
      description TEXT,
      dueDate TEXT,
      dueOdometer INTEGER,
      isRecurring INTEGER NOT NULL DEFAULT 0,
      recurringDays INTEGER,
      recurringOdometer INTEGER,
      notificationEnabled INTEGER NOT NULL DEFAULT 1,
      notificationDaysBefore INTEGER NOT NULL DEFAULT 7,
      notificationOdometerBefore INTEGER NOT NULL DEFAULT 500,
      isCompleted INTEGER NOT NULL DEFAULT 0,
      completedDate TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      isSynced INTEGER NOT NULL DEFAULT 0,
      firebaseId TEXT,
      lastSyncedAt TEXT,
      FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
    )
  ''';

  static const String createIndexVehicleId =
    'CREATE INDEX idx_reminders_vehicleId ON reminders(vehicleId)';

  static const String createIndexUserId =
    'CREATE INDEX idx_reminders_userId ON reminders(userId)';

  static const String createIndexSync =
    'CREATE INDEX idx_reminders_isSynced ON reminders(isSynced)';

  static const String createIndexDueDate =
    'CREATE INDEX idx_reminders_dueDate ON reminders(dueDate)';

  static const String queryGetAll = '''
    SELECT * FROM reminders
    WHERE userId = ? AND isDeleted = 0
    ORDER BY isCompleted ASC, dueDate ASC
  ''';

  static const String queryGetByVehicle = '''
    SELECT * FROM reminders
    WHERE vehicleId = ? AND isDeleted = 0
    ORDER BY isCompleted ASC, dueDate ASC
  ''';

  static const String queryGetActive = '''
    SELECT * FROM reminders
    WHERE vehicleId = ? AND isCompleted = 0 AND isDeleted = 0
    ORDER BY dueDate ASC
  ''';

  static const String queryGetById = '''
    SELECT * FROM reminders WHERE id = ? AND isDeleted = 0
  ''';

  static const String queryGetUpcoming = '''
    SELECT * FROM reminders
    WHERE userId = ? AND isCompleted = 0 AND isDeleted = 0
    AND (dueDate IS NULL OR dueDate >= ?)
    ORDER BY dueDate ASC
    LIMIT ?
  ''';

  static const String queryGetOverdue = '''
    SELECT * FROM reminders
    WHERE userId = ? AND isCompleted = 0 AND isDeleted = 0
    AND dueDate IS NOT NULL AND dueDate < ?
    ORDER BY dueDate ASC
  ''';

  static const String queryGetUnsynced = '''
    SELECT * FROM reminders WHERE isSynced = 0 AND userId = ?
  ''';

  static const String queryInsert = '''
    INSERT INTO reminders (
      id, vehicleId, userId, title, type, description,
      dueDate, dueOdometer, isRecurring, recurringDays, recurringOdometer,
      notificationEnabled, notificationDaysBefore, notificationOdometerBefore,
      isCompleted, completedDate, createdAt, updatedAt, isDeleted,
      isSynced, firebaseId, lastSyncedAt
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''';

  static const String queryUpdate = '''
    UPDATE reminders SET
      title = ?, type = ?, description = ?,
      dueDate = ?, dueOdometer = ?, isRecurring = ?,
      recurringDays = ?, recurringOdometer = ?,
      notificationEnabled = ?, notificationDaysBefore = ?,
      notificationOdometerBefore = ?,
      updatedAt = ?, isSynced = 0
    WHERE id = ?
  ''';

  static const String queryMarkCompleted = '''
    UPDATE reminders SET
      isCompleted = 1, completedDate = ?, updatedAt = ?, isSynced = 0
    WHERE id = ?
  ''';

  static const String queryMarkIncomplete = '''
    UPDATE reminders SET
      isCompleted = 0, completedDate = NULL, updatedAt = ?, isSynced = 0
    WHERE id = ?
  ''';

  static const String querySoftDelete = '''
    UPDATE reminders SET isDeleted = 1, updatedAt = ?, isSynced = 0 WHERE id = ?
  ''';

  static const String queryMarkSynced = '''
    UPDATE reminders SET isSynced = 1, firebaseId = ?, lastSyncedAt = ? WHERE id = ?
  ''';

  // Conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'title': title,
      'type': type,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'dueOdometer': dueOdometer,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringDays': recurringDays,
      'recurringOdometer': recurringOdometer,
      'notificationEnabled': notificationEnabled ? 1 : 0,
      'notificationDaysBefore': notificationDaysBefore,
      'notificationOdometerBefore': notificationOdometerBefore,
      'isCompleted': isCompleted ? 1 : 0,
      'completedDate': completedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
      'firebaseId': firebaseId,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      type: map['type'] as String,
      description: map['description'] as String?,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      dueOdometer: map['dueOdometer'] as int?,
      isRecurring: map['isRecurring'] == 1,
      recurringDays: map['recurringDays'] as int?,
      recurringOdometer: map['recurringOdometer'] as int?,
      notificationEnabled: map['notificationEnabled'] == 1,
      notificationDaysBefore: map['notificationDaysBefore'] as int,
      notificationOdometerBefore: map['notificationOdometerBefore'] as int,
      isCompleted: map['isCompleted'] == 1,
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: map['isDeleted'] == 1,
      isSynced: map['isSynced'] == 1,
      firebaseId: map['firebaseId'] as String?,
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'] as String)
          : null,
    );
  }

  // Firestore operations
  static const String firestoreCollection = 'reminders';

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'title': title,
      'type': type,
      'description': description,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'dueOdometer': dueOdometer,
      'isRecurring': isRecurring,
      'recurringDays': recurringDays,
      'recurringOdometer': recurringOdometer,
      'notificationEnabled': notificationEnabled,
      'notificationDaysBefore': notificationDaysBefore,
      'notificationOdometerBefore': notificationOdometerBefore,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory ReminderModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ReminderModel(
      id: data['id'] as String,
      vehicleId: data['vehicleId'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      type: data['type'] as String,
      description: data['description'] as String?,
      dueDate: data['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['dueDate'] as int)
          : null,
      dueOdometer: data['dueOdometer'] as int?,
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurringDays: data['recurringDays'] as int?,
      recurringOdometer: data['recurringOdometer'] as int?,
      notificationEnabled: data['notificationEnabled'] as bool? ?? true,
      notificationDaysBefore: data['notificationDaysBefore'] as int? ?? 7,
      notificationOdometerBefore: data['notificationOdometerBefore'] as int? ?? 500,
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedDate: data['completedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['completedDate'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int),
      isDeleted: data['isDeleted'] as bool? ?? false,
      isSynced: true,
      firebaseId: docId,
      lastSyncedAt: DateTime.now(),
    );
  }

  ReminderModel copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    String? title,
    String? type,
    String? description,
    DateTime? dueDate,
    int? dueOdometer,
    bool? isRecurring,
    int? recurringDays,
    int? recurringOdometer,
    bool? notificationEnabled,
    int? notificationDaysBefore,
    int? notificationOdometerBefore,
    bool? isCompleted,
    DateTime? completedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
    String? firebaseId,
    DateTime? lastSyncedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueOdometer: dueOdometer ?? this.dueOdometer,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      recurringOdometer: recurringOdometer ?? this.recurringOdometer,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationDaysBefore: notificationDaysBefore ?? this.notificationDaysBefore,
      notificationOdometerBefore: notificationOdometerBefore ?? this.notificationOdometerBefore,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
```

---

## Service Layer

### Reminder Service

**File**: `lib/features/reminders/service/reminder_service.dart`

```dart
class ReminderService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

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
        print('Sync failed: $e');
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
    final results = await db.rawQuery(ReminderModel.queryGetByVehicle, [vehicleId]);
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
        print('Sync failed: $e');
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
        print('Sync failed: $e');
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
        print('Sync failed: $e');
      }
    }
  }

  // DELETE (soft delete)
  Future<void> deleteReminder(String id) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(ReminderModel.querySoftDelete, [
      DateTime.now().toIso8601String(),
      id,
    ]);

    // Cancel notification
    await _cancelNotification(id);

    // Try to sync deletion to Firestore
    if (await _isOnline()) {
      try {
        final reminder = await getReminderById(id);
        if (reminder != null && reminder.firebaseId != null) {
          await _deleteFromFirestore(reminder.userId, reminder.firebaseId!);
        }
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // NOTIFICATION MANAGEMENT
  Future<void> _scheduleNotification(ReminderModel reminder) async {
    // Implementation using flutter_local_notifications
    // Schedule notification based on dueDate and notificationDaysBefore
    print('Scheduling notification for reminder: ${reminder.id}');
  }

  Future<void> _cancelNotification(String reminderId) async {
    // Implementation using flutter_local_notifications
    print('Canceling notification for reminder: $reminderId');
  }

  Future<void> _createRecurringReminder(ReminderModel completed) async {
    if (!completed.isRecurring) return;

    DateTime? newDueDate;
    int? newDueOdometer;

    if (completed.dueDate != null && completed.recurringDays != null) {
      newDueDate = completed.dueDate!.add(Duration(days: completed.recurringDays!));
    }

    if (completed.dueOdometer != null && completed.recurringOdometer != null) {
      newDueOdometer = completed.dueOdometer! + completed.recurringOdometer!;
    }

    final newReminder = completed.copyWith(
      id: Uuid().v4(),
      dueDate: newDueDate,
      dueOdometer: newDueOdometer,
      isCompleted: false,
      completedDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
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
        print('Failed to sync reminder: $e');
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
    return true; // Placeholder
  }
}
```

---

## Implementation Checklist

- [ ] Create ReminderModel with all fields
- [ ] Add static SQL queries
- [ ] Add Firestore conversion methods
- [ ] Create ReminderService with CRUD operations
- [ ] Implement notification scheduling logic
- [ ] Implement recurring reminder creation
- [ ] Integrate reminders table in DatabaseHelper
- [ ] Add reminder sync methods to FirestoreHelper
- [ ] Integrate flutter_local_notifications
- [ ] Test notification scheduling
- [ ] Test recurring reminders

---

## Notes

- Supports both time-based and mileage-based reminders
- Recurring reminders automatically create new instances when completed
- Notifications scheduled using flutter_local_notifications
- Overdue and upcoming status calculated on-the-fly
- Mark complete/incomplete toggle functionality
