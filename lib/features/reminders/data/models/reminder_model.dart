/// RecurrenceType - Enum for recurrence frequency
enum RecurrenceType { daily, weekly, monthly, interval }

/// ReminderModel - Data model for maintenance reminders
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
  final RecurrenceType? recurrenceType;
  final List<int>? recurrenceWeekdays; // 1-7 (Mon-Sun)
  final int? recurrenceMonthDay; // 1-31
  final int? recurringDays; // if interval-based recurring
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
    this.recurrenceType,
    this.recurrenceWeekdays,
    this.recurrenceMonthDay,
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
      id, vehicleId, userId, title, type, description,
      dueDate, dueOdometer, isRecurring, recurrenceType, recurrenceWeekdays,
      recurrenceMonthDay, recurringDays, recurringOdometer,
      notificationEnabled, notificationDaysBefore, notificationOdometerBefore,
      isCompleted, completedDate, createdAt, updatedAt, isDeleted,
      isSynced, firebaseId, lastSyncedAt
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''';

  static const String queryUpdate = '''
    UPDATE reminders SET
      title = ?, type = ?, description = ?,
      dueDate = ?, dueOdometer = ?, isRecurring = ?,
      recurrenceType = ?, recurrenceWeekdays = ?, recurrenceMonthDay = ?,
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
      'recurrenceType': recurrenceType?.name,
      'recurrenceWeekdays': recurrenceWeekdays?.join(','),
      'recurrenceMonthDay': recurrenceMonthDay,
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
      recurrenceType: map['recurrenceType'] != null
          ? RecurrenceType.values.firstWhere(
              (e) => e.name == map['recurrenceType'],
              orElse: () => RecurrenceType.interval)
          : null,
      recurrenceWeekdays: map['recurrenceWeekdays'] != null
          ? (map['recurrenceWeekdays'] as String)
              .split(',')
              .where((e) => e.isNotEmpty)
              .map((e) => int.parse(e))
              .toList()
          : null,
      recurrenceMonthDay: map['recurrenceMonthDay'] as int?,
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
      'recurrenceType': recurrenceType?.name,
      'recurrenceWeekdays': recurrenceWeekdays,
      'recurrenceMonthDay': recurrenceMonthDay,
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

  factory ReminderModel.fromFirestore(
      Map<String, dynamic> data, String docId) {
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
      recurrenceType: data['recurrenceType'] != null
          ? RecurrenceType.values.firstWhere(
              (e) => e.name == data['recurrenceType'],
              orElse: () => RecurrenceType.interval)
          : null,
      recurrenceWeekdays: data['recurrenceWeekdays'] != null
          ? List<int>.from(data['recurrenceWeekdays'])
          : null,
      recurrenceMonthDay: data['recurrenceMonthDay'] as int?,
      recurringDays: data['recurringDays'] as int?,
      recurringOdometer: data['recurringOdometer'] as int?,
      notificationEnabled: data['notificationEnabled'] as bool? ?? true,
      notificationDaysBefore: data['notificationDaysBefore'] as int? ?? 7,
      notificationOdometerBefore:
          data['notificationOdometerBefore'] as int? ?? 500,
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
    RecurrenceType? recurrenceType,
    List<int>? recurrenceWeekdays,
    int? recurrenceMonthDay,
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
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceWeekdays: recurrenceWeekdays ?? this.recurrenceWeekdays,
      recurrenceMonthDay: recurrenceMonthDay ?? this.recurrenceMonthDay,
      recurringDays: recurringDays ?? this.recurringDays,
      recurringOdometer: recurringOdometer ?? this.recurringOdometer,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationDaysBefore:
          notificationDaysBefore ?? this.notificationDaysBefore,
      notificationOdometerBefore:
          notificationOdometerBefore ?? this.notificationOdometerBefore,
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
