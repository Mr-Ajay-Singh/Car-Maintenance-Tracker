# Expenses Feature - Implementation Plan

## Feature Overview
The Expenses feature allows users to track all vehicle-related costs beyond service and fuel. This includes insurance, registration, parking, fines, parts, and other miscellaneous expenses. Users can categorize expenses, attach receipts, and generate expense reports for budgeting and tax purposes.

## Architecture
Following CLAUDE.md guidelines:
- **Data Layer**: Expense model with SQLite and Firestore operations
- **Service Layer**: Business logic for expense tracking and reporting
- **Presentation Layer**: UI components (implemented in UI.md)

---

## Data Layer

### Expense Model

**File**: `lib/features/expenses/data/models/expense_model.dart`

```dart
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

  static const String tableCreate = '''
    CREATE TABLE expenses (
      id TEXT PRIMARY KEY,
      vehicleId TEXT NOT NULL,
      userId TEXT NOT NULL,
      date TEXT NOT NULL,
      category TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'USD',
      description TEXT,
      vendor TEXT,
      notes TEXT,
      receiptUrls TEXT,
      isRecurring INTEGER NOT NULL DEFAULT 0,
      recurringPeriod TEXT,
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
    'CREATE INDEX idx_expenses_vehicleId ON expenses(vehicleId)';

  static const String createIndexUserId =
    'CREATE INDEX idx_expenses_userId ON expenses(userId)';

  static const String createIndexSync =
    'CREATE INDEX idx_expenses_isSynced ON expenses(isSynced)';

  static const String createIndexDate =
    'CREATE INDEX idx_expenses_date ON expenses(date DESC)';

  static const String createIndexCategory =
    'CREATE INDEX idx_expenses_category ON expenses(category)';

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
      amount: map['amount'] as double,
      currency: map['currency'] as String? ?? 'USD',
      description: map['description'] as String?,
      vendor: map['vendor'] as String?,
      notes: map['notes'] as String?,
      receiptUrls: map['receiptUrls'] != null && (map['receiptUrls'] as String).isNotEmpty
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

// Category constants
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
```

---

## Service Layer

### Expense Service

**File**: `lib/features/expenses/service/expense_service.dart`

```dart
class ExpenseService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CREATE
  Future<String> addExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;

    await db.rawInsert(ExpenseModel.queryInsert, [
      expense.id,
      expense.vehicleId,
      expense.userId,
      expense.date.toIso8601String(),
      expense.category,
      expense.amount,
      expense.currency,
      expense.description,
      expense.vendor,
      expense.notes,
      expense.receiptUrls.join(','),
      expense.isRecurring ? 1 : 0,
      expense.recurringPeriod,
      expense.createdAt.toIso8601String(),
      expense.updatedAt.toIso8601String(),
      expense.isDeleted ? 1 : 0,
      expense.isSynced ? 1 : 0,
      expense.firebaseId,
      expense.lastSyncedAt?.toIso8601String(),
    ]);

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        await _syncExpenseToFirestore(expense);
      } catch (e) {
        print('Sync failed: $e');
      }
    }

    return expense.id;
  }

  // READ
  Future<List<ExpenseModel>> getAllExpenses(String userId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ExpenseModel.queryGetAll, [userId]);
    return results.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<List<ExpenseModel>> getExpensesByVehicle(String vehicleId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ExpenseModel.queryGetByVehicle, [vehicleId]);
    return results.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ExpenseModel.queryGetById, [id]);
    if (results.isEmpty) return null;
    return ExpenseModel.fromMap(results.first);
  }

  Future<List<ExpenseModel>> getExpensesByCategory(
    String vehicleId,
    String category,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ExpenseModel.queryGetByCategory,
      [vehicleId, category],
    );
    return results.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<List<ExpenseModel>> getExpensesInRange(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ExpenseModel.queryGetInRange,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    return results.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // STATISTICS
  Future<double> getTotalExpenses(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ExpenseModel.queryGetTotalByVehicle,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    if (results.isEmpty || results.first['total'] == null) return 0.0;
    return results.first['total'] as double;
  }

  Future<Map<String, double>> getExpensesByCategory(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ExpenseModel.queryGetTotalByCategory,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );

    final categoryTotals = <String, double>{};
    for (final row in results) {
      final category = row['category'] as String;
      final total = row['total'] as double;
      categoryTotals[category] = total;
    }

    return categoryTotals;
  }

  Future<double> getMonthlyAverage(String vehicleId, int months) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months, 1);
    final total = await getTotalExpenses(vehicleId, startDate, now);
    return total / months;
  }

  // UPDATE
  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    final updatedExpense = expense.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await db.rawUpdate(ExpenseModel.queryUpdate, [
      updatedExpense.date.toIso8601String(),
      updatedExpense.category,
      updatedExpense.amount,
      updatedExpense.currency,
      updatedExpense.description,
      updatedExpense.vendor,
      updatedExpense.notes,
      updatedExpense.receiptUrls.join(','),
      updatedExpense.isRecurring ? 1 : 0,
      updatedExpense.recurringPeriod,
      updatedExpense.updatedAt.toIso8601String(),
      updatedExpense.id,
    ]);

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        await _syncExpenseToFirestore(updatedExpense);
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // DELETE (soft delete)
  Future<void> deleteExpense(String id) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(ExpenseModel.querySoftDelete, [
      DateTime.now().toIso8601String(),
      id,
    ]);

    // Try to sync deletion to Firestore
    if (await _isOnline()) {
      try {
        final expense = await getExpenseById(id);
        if (expense != null && expense.firebaseId != null) {
          await _deleteFromFirestore(expense.userId, expense.firebaseId!);
        }
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // SYNC OPERATIONS
  Future<void> syncUnsyncedExpenses(String userId) async {
    if (!await _isOnline()) return;

    final db = await _dbHelper.database;
    final unsyncedRows = await db.rawQuery(
      ExpenseModel.queryGetUnsynced,
      [userId],
    );

    for (final row in unsyncedRows) {
      try {
        final expense = ExpenseModel.fromMap(row);
        await _syncExpenseToFirestore(expense);
      } catch (e) {
        print('Failed to sync expense: $e');
      }
    }
  }

  Future<void> _syncExpenseToFirestore(ExpenseModel expense) async {
    final firebaseId = await FirestoreHelper.pushExpense(expense);

    final db = await _dbHelper.database;
    await db.rawUpdate(ExpenseModel.queryMarkSynced, [
      firebaseId,
      DateTime.now().toIso8601String(),
      expense.id,
    ]);
  }

  Future<void> _deleteFromFirestore(String userId, String firebaseId) async {
    await FirestoreHelper.deleteExpense(userId, firebaseId);
  }

  Future<bool> _isOnline() async {
    return true; // Placeholder
  }
}
```

---

## Implementation Checklist

- [ ] Create ExpenseModel with all fields
- [ ] Create ExpenseCategory constants
- [ ] Add static SQL queries
- [ ] Add Firestore conversion methods
- [ ] Create ExpenseService with CRUD operations
- [ ] Implement category-based filtering
- [ ] Implement expense statistics and analytics
- [ ] Integrate expenses table in DatabaseHelper
- [ ] Add expense sync methods to FirestoreHelper
- [ ] Test category grouping queries
- [ ] Test date range filtering

---

## Notes

- Expenses are separate from service and fuel costs
- Supports receipt attachments (multiple URLs)
- Category-based organization for reporting
- Recurring expenses tracked for budgeting
- Statistics support budget analysis and tax reporting
- Currency field for international users
