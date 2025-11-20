/// ExpenseModel - Data model for vehicle expenses
class ExpenseModel {
  final String id;
  final String vehicleId;
  final String userId;
  final DateTime date;
  final String category; // insurance, registration, parking, fine, parts, other
  final double amount;
  final String currency;
  final String? description;
  final String? vendor;
  final String? notes;
  final List<String> receiptUrls;
  final bool isRecurring;
  final String? recurringPeriod; // monthly, yearly, etc.
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // Sync tracking fields
  final bool isSynced;
  final String? firebaseId;
  final DateTime? lastSyncedAt;

  ExpenseModel({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.date,
    required this.category,
    required this.amount,
    this.currency = 'USD',
    this.description,
    this.vendor,
    this.notes,
    this.receiptUrls = const [],
    this.isRecurring = false,
    this.recurringPeriod,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseId,
    this.lastSyncedAt,
  });

  // Static SQL queries
  static const String tableName = 'expenses';

  static const String queryGetAll = '''
    SELECT * FROM expenses
    WHERE userId = ? AND isDeleted = 0
    ORDER BY date DESC
  ''';

  static const String queryGetByVehicle = '''
    SELECT * FROM expenses
    WHERE vehicleId = ? AND isDeleted = 0
    ORDER BY date DESC
  ''';

  static const String queryGetById = '''
    SELECT * FROM expenses WHERE id = ? AND isDeleted = 0
  ''';

  static const String queryGetByCategory = '''
    SELECT * FROM expenses
    WHERE vehicleId = ? AND category = ? AND isDeleted = 0
    ORDER BY date DESC
  ''';

  static const String queryGetInRange = '''
    SELECT * FROM expenses
    WHERE vehicleId = ? AND isDeleted = 0
    AND date >= ? AND date <= ?
    ORDER BY date DESC
  ''';

  static const String queryGetTotalByVehicle = '''
    SELECT SUM(amount) as total
    FROM expenses
    WHERE vehicleId = ? AND isDeleted = 0
    AND date >= ? AND date <= ?
  ''';

  static const String queryGetTotalByCategory = '''
    SELECT category, SUM(amount) as total
    FROM expenses
    WHERE vehicleId = ? AND isDeleted = 0
    AND date >= ? AND date <= ?
    GROUP BY category
  ''';

  static const String queryGetUnsynced = '''
    SELECT * FROM expenses WHERE isSynced = 0 AND userId = ?
  ''';

  static const String queryInsert = '''
    INSERT INTO expenses (
      id, vehicleId, userId, date, category, amount, currency,
      description, vendor, notes, receiptUrls, isRecurring, recurringPeriod,
      createdAt, updatedAt, isDeleted, isSynced, firebaseId, lastSyncedAt
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''';

  static const String queryUpdate = '''
    UPDATE expenses SET
      date = ?, category = ?, amount = ?, currency = ?,
      description = ?, vendor = ?, notes = ?, receiptUrls = ?,
      isRecurring = ?, recurringPeriod = ?,
      updatedAt = ?, isSynced = 0
    WHERE id = ?
  ''';

  static const String querySoftDelete = '''
    UPDATE expenses SET isDeleted = 1, updatedAt = ?, isSynced = 0 WHERE id = ?
  ''';

  static const String queryMarkSynced = '''
    UPDATE expenses SET isSynced = 1, firebaseId = ?, lastSyncedAt = ? WHERE id = ?
  ''';

  // Conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'currency': currency,
      'description': description,
      'vendor': vendor,
      'notes': notes,
      'receiptUrls': receiptUrls.join(','),
      'isRecurring': isRecurring ? 1 : 0,
      'recurringPeriod': recurringPeriod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
      'firebaseId': firebaseId,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      userId: map['userId'] as String,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      description: map['description'] as String?,
      vendor: map['vendor'] as String?,
      notes: map['notes'] as String?,
      receiptUrls: map['receiptUrls'] != null &&
              (map['receiptUrls'] as String).isNotEmpty
          ? (map['receiptUrls'] as String).split(',')
          : [],
      isRecurring: map['isRecurring'] == 1,
      recurringPeriod: map['recurringPeriod'] as String?,
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
  static const String firestoreCollection = 'expenses';

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'amount': amount,
      'currency': currency,
      'description': description,
      'vendor': vendor,
      'notes': notes,
      'receiptUrls': receiptUrls,
      'isRecurring': isRecurring,
      'recurringPeriod': recurringPeriod,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory ExpenseModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ExpenseModel(
      id: data['id'] as String,
      vehicleId: data['vehicleId'] as String,
      userId: data['userId'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] as int),
      category: data['category'] as String,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String? ?? 'USD',
      description: data['description'] as String?,
      vendor: data['vendor'] as String?,
      notes: data['notes'] as String?,
      receiptUrls: List<String>.from(data['receiptUrls'] ?? []),
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurringPeriod: data['recurringPeriod'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int),
      isDeleted: data['isDeleted'] as bool? ?? false,
      isSynced: true,
      firebaseId: docId,
      lastSyncedAt: DateTime.now(),
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    DateTime? date,
    String? category,
    double? amount,
    String? currency,
    String? description,
    String? vendor,
    String? notes,
    List<String>? receiptUrls,
    bool? isRecurring,
    String? recurringPeriod,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
    String? firebaseId,
    DateTime? lastSyncedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      vendor: vendor ?? this.vendor,
      notes: notes ?? this.notes,
      receiptUrls: receiptUrls ?? this.receiptUrls,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

/// ExpenseCategory - Constants for expense categories
class ExpenseCategory {
  static const String insurance = 'Insurance';
  static const String registration = 'Registration';
  static const String parking = 'Parking';
  static const String fine = 'Fine/Ticket';
  static const String parts = 'Parts';
  static const String tolls = 'Tolls';
  static const String cleaning = 'Cleaning/Detailing';
  static const String storage = 'Storage';
  static const String other = 'Other';

  static List<String> get all => [
        insurance,
        registration,
        parking,
        fine,
        parts,
        tolls,
        cleaning,
        storage,
        other,
      ];
}
