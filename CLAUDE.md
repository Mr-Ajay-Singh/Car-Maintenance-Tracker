# Project File Structure

## Features Folder Architecture

Each feature in the `lib/features/` directory follows a clean architecture pattern with three main folders:

```
lib/features/
├── dashboard/
│   ├── data/
│   │   └── models/          # Data models and entities
│   ├── service/
│   │   └── *_service.dart   # Service classes handling business logic
│   └── presentation/
│       └── *_page.dart      # UI components and pages
│
├── mainPage/
│   ├── data/
│   │   └── models/
│   ├── service/
│   └── presentation/
│
└── settings/
    ├── data/
    │   └── models/
    ├── service/
    └── presentation/
```

## Folder Responsibilities

### 📁 Data
- Contains all data models and entities
- Data transfer objects (DTOs)
- Model classes representing the structure of data

### 📁 Service
- Service classes that handle business logic
- API calls and data processing
- State management and data manipulation
- Interaction between data layer and presentation layer

### 📁 Presentation
- All UI components and pages
- Widgets specific to the feature
- Screen layouts and user interface elements
- User interaction handlers

## Architecture Benefits

This structure provides:
- **Separation of Concerns**: Each layer has a specific responsibility
- **Maintainability**: Easy to locate and modify code
- **Scalability**: Simple to add new features following the same pattern
- **Testability**: Each layer can be tested independently

## UI and Styling Guidelines

### Color Usage
- **ALWAYS use colors from the app theme only**
- Never hardcode color values directly in widgets
- Access colors through `Theme.of(context).colorScheme`
- The app uses a warm coral color palette defined in `lib/common/theme/themes.dart`
- Available theme colors include: primary, secondary, tertiary, surface, error, and their variants

**Example:**
```dart
// ✅ CORRECT - Using theme colors
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
  ),
)

// ❌ INCORRECT - Hardcoded colors
Container(
  color: Color(0xFFF9816E),
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.white),
  ),
)
```

### Benefits of Using Theme Colors
- **Consistency**: All UI elements follow the same color palette
- **Maintainability**: Change colors in one place (themes.dart) to update the entire app
- **Flexibility**: Easy to adjust colors without touching individual widgets
- **Accessibility**: Theme colors are designed with proper contrast ratios

## Data Storage Guidelines

### Database Storage
- **Use SQLite database** for storing data and records
- All database operations must go through the `DatabaseHelper` class located in `lib/common/data/`
- Never access the database directly from feature modules

### Database Query Guidelines
- **All database queries must be defined as static variables** in the related data model class
- Never write raw SQL queries directly in service classes or anywhere else
- Use the static query variables from model classes for all database operations (SELECT, INSERT, UPDATE, DELETE, etc.)
- This ensures consistency and makes queries easy to maintain and reuse

**Example:**
```dart
// In lib/features/dashboard/data/models/record_model.dart
class RecordModel {
  // Static query variables
  static const String tableCreate = '''
    CREATE TABLE records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      amount REAL NOT NULL
    )
  ''';

  static const String queryGetAll = 'SELECT * FROM records ORDER BY date DESC';
  static const String queryGetById = 'SELECT * FROM records WHERE id = ?';
  static const String queryInsert = 'INSERT INTO records (date, amount) VALUES (?, ?)';
  static const String queryUpdate = 'UPDATE records SET date = ?, amount = ? WHERE id = ?';
  static const String queryDelete = 'DELETE FROM records WHERE id = ?';

  // Model properties
  final int id;
  final String date;
  final double amount;

  RecordModel({required this.id, required this.date, required this.amount});
}

// Usage in service or DatabaseHelper
final records = await db.rawQuery(RecordModel.queryGetAll);
await db.rawInsert(RecordModel.queryInsert, [date, amount]);
```

### Key-Value Storage
- **Use Shared Preferences** for storing key-value pairs
- All shared preferences operations must go through the `SharedPreferencesHelper` static class located in `lib/common/data/`
- Never access SharedPreferences directly from feature modules

### Common Data Layer Structure

```
lib/common/data/
├── shared_preferences_helper.dart   # Static class for all key-value operations
└── database_helper.dart             # Class for all database operations
```

### Usage Example

```dart
// Accessing shared preferences
final userName = await SharedPreferencesHelper.getUserName();
await SharedPreferencesHelper.setUserName('John');

// Accessing database
final records = await DatabaseHelper.instance.getRecords();
await DatabaseHelper.instance.insertRecord(record);
```

### Benefits of Centralized Data Access
- **Single Source of Truth**: All data access goes through one place
- **Easy to Modify**: Changes to storage logic only need to be made once
- **Consistent**: Ensures all parts of the app use the same data access patterns
- **Testable**: Easy to mock for unit tests

## Firebase/Firestore Storage Guidelines

### Overview
- **Use Firebase Firestore** for cloud storage and cross-device sync
- Follow the **optimized O(k) sync strategy** (only sync unsynced records)
- Firestore logic is handled **in the data model class itself**
- Service classes handle both local SQLite and cloud Firestore operations
- **No separate sync service needed** - sync is integrated into existing service classes

### Sync Tracking Fields

All data models that need cloud sync MUST include these three fields:

```dart
class RecordModel {
  // ... existing fields ...

  // Sync tracking fields (REQUIRED for Firestore sync)
  final bool isSynced;           // false = needs sync, true = already synced
  final String? firebaseId;       // Firestore document ID after sync
  final DateTime? lastSyncedAt;   // When this record was last synced

  RecordModel({
    // ... other parameters ...
    this.isSynced = false,        // Default: not synced
    this.firebaseId,
    this.lastSyncedAt,
  });
}
```

### SQLite Schema for Sync-Enabled Tables

Add sync tracking columns to tables that need cloud sync:

```dart
class RecordModel {
  static const String tableCreate = '''
    CREATE TABLE records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId TEXT NOT NULL,
      date TEXT NOT NULL,
      amount REAL NOT NULL,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,

      -- Sync tracking fields
      isSynced INTEGER NOT NULL DEFAULT 0,  -- 0 = not synced, 1 = synced
      firebaseId TEXT,                       -- Firebase document ID
      lastSyncedAt TEXT                      -- ISO 8601 timestamp
    )
  ''';

  // Index for O(k) performance - REQUIRED!
  static const String createSyncIndex =
    'CREATE INDEX idx_records_isSynced ON records(isSynced)';

  // Query to get ONLY unsynced records (O(k) complexity)
  static const String queryGetUnsynced =
    'SELECT * FROM records WHERE isSynced = 0';
}
```

### Firestore Methods in Data Model Class

**All Firestore operations must be defined as static methods in the data model class:**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordModel {
  // ... fields and constructor ...

  // ========== FIRESTORE COLLECTION REFERENCE ==========
  static const String firestoreCollection = 'records';

  static CollectionReference getFirestoreCollection(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(firestoreCollection);
  }

  // ========== CONVERT TO/FROM FIRESTORE ==========

  // Convert model to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'firestoreId': firebaseId,
      'localId': id,
      'userId': userId,
      'date': date,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'syncedAt': Timestamp.now(),
    };
  }

  // Create model from Firestore document
  static RecordModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecordModel(
      id: data['localId'],
      userId: data['userId'],
      date: data['date'],
      amount: data['amount'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isSynced: true,  // Data from Firestore is already synced
      firebaseId: doc.id,
      lastSyncedAt: (data['syncedAt'] as Timestamp).toDate(),
    );
  }

  // ========== FIRESTORE OPERATIONS ==========

  // Push single record to Firestore
  static Future<String> pushToFirestore(String userId, RecordModel record) async {
    final docRef = await getFirestoreCollection(userId).add(record.toFirestore());
    return docRef.id;  // Return Firestore document ID
  }

  // Update record in Firestore
  static Future<void> updateInFirestore(String userId, RecordModel record) async {
    if (record.firebaseId == null) return;
    await getFirestoreCollection(userId)
        .doc(record.firebaseId)
        .set(record.toFirestore(), SetOptions(merge: true));
  }

  // Delete record from Firestore
  static Future<void> deleteFromFirestore(String userId, String firebaseId) async {
    await getFirestoreCollection(userId).doc(firebaseId).delete();
  }

  // Pull records from Firestore (filtered by last sync time)
  static Future<List<RecordModel>> pullFromFirestore(
    String userId,
    DateTime? lastSyncTime,
  ) async {
    Query query = getFirestoreCollection(userId);

    // Only get records updated after last sync (O(k) optimization)
    if (lastSyncTime != null) {
      query = query.where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSyncTime));
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
  }
}
```

### Service Class Pattern (Handles Both Local + Cloud)

Service classes handle BOTH local SQLite and Firestore operations:

```dart
class RecordService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ========== CREATE ==========
  Future<int> addRecord(RecordModel record) async {
    final db = await _dbHelper.database;

    // 1. Insert into local SQLite with isSynced = 0
    final localId = await db.rawInsert(
      RecordModel.queryInsert,
      [record.date, record.amount, /* ... */, 0],  // isSynced = 0
    );

    // 2. Try to sync to Firestore immediately if online
    if (await _isOnline()) {
      try {
        final recordWithId = record.copyWith(id: localId);
        final firebaseId = await RecordModel.pushToFirestore(
          record.userId,
          recordWithId,
        );

        // 3. Mark as synced in local database
        await _markAsSynced(localId, firebaseId);
      } catch (e) {
        // If sync fails, isSynced stays 0, will sync later
        print('Sync failed: $e');
      }
    }

    return localId;
  }

  // ========== UPDATE ==========
  Future<int> updateRecord(RecordModel record) async {
    final db = await _dbHelper.database;

    // 1. Update in local SQLite and mark as unsynced
    final result = await db.rawUpdate(
      '''UPDATE records
         SET date = ?, amount = ?, updatedAt = ?, isSynced = 0
         WHERE id = ?''',
      [record.date, record.amount, DateTime.now().toIso8601String(), record.id],
    );

    // 2. Try to sync to Firestore immediately if online
    if (await _isOnline() && record.firebaseId != null) {
      try {
        await RecordModel.updateInFirestore(record.userId, record);
        await _markAsSynced(record.id!, record.firebaseId!);
      } catch (e) {
        print('Sync failed: $e');
      }
    }

    return result;
  }

  // ========== DELETE ==========
  Future<int> deleteRecord(int id, String userId) async {
    final db = await _dbHelper.database;

    // 1. Get firebaseId before deleting
    final records = await db.rawQuery(
      RecordModel.queryGetById,
      [id],
    );
    final firebaseId = records.isNotEmpty ? records.first['firebaseId'] as String? : null;

    // 2. Delete from local SQLite
    final result = await db.rawDelete(RecordModel.queryDelete, [id]);

    // 3. Delete from Firestore if synced
    if (await _isOnline() && firebaseId != null) {
      try {
        await RecordModel.deleteFromFirestore(userId, firebaseId);
      } catch (e) {
        print('Delete from Firestore failed: $e');
      }
    }

    return result;
  }

  // ========== SYNC OPERATIONS (O(k) complexity) ==========

  // Sync all unsynced records to Firestore
  Future<void> syncUnsyncedRecords(String userId) async {
    if (!await _isOnline()) return;

    final db = await _dbHelper.database;

    // Get ONLY unsynced records (O(k) query with index)
    final unsyncedRows = await db.rawQuery(RecordModel.queryGetUnsynced);

    for (final row in unsyncedRows) {
      try {
        final record = RecordModel.fromMap(row);

        if (record.firebaseId == null) {
          // New record - push to Firestore
          final firebaseId = await RecordModel.pushToFirestore(userId, record);
          await _markAsSynced(record.id!, firebaseId);
        } else {
          // Updated record - update in Firestore
          await RecordModel.updateInFirestore(userId, record);
          await _markAsSynced(record.id!, record.firebaseId!);
        }
      } catch (e) {
        print('Failed to sync record: $e');
      }
    }
  }


  // ========== HELPER METHODS ==========

  Future<void> _markAsSynced(int localId, String firebaseId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      '''UPDATE records
         SET isSynced = 1, firebaseId = ?, lastSyncedAt = ?
         WHERE id = ?''',
      [firebaseId, DateTime.now().toIso8601String(), localId],
    );
  }

  Future<bool> _isOnline() async {
    // Implement connectivity check
    return true; // Placeholder
  }
}
```

### Key Principles

1. **Data Model Owns Firestore Logic**
   - All Firestore operations (CRUD, conversion) are static methods in the model class
   - Never write Firestore code in service classes directly
   - Use model's static methods for all cloud operations

2. **Service Handles Both Local + Cloud**
   - Service class coordinates local SQLite and Firestore operations
   - On create/update/delete: try to sync immediately if online
   - If offline: mark as unsynced (isSynced = 0), will sync later
   - No separate sync service needed

3. **O(k) Optimization**
   - Only sync records where isSynced = 0
   - Use index on isSynced for fast queries
   - Pull only records updated after lastSyncTime
   - First sign-in: full sync (one-time only)
   - Subsequent syncs: incremental (O(k) only)

4. **Automatic Offline Support**
   - Records with isSynced = 0 are the "offline queue"
   - When back online, call syncUnsyncedRecords()
   - No manual queue management needed

### Benefits

- **Consistent Architecture**: Follows the same data/service/presentation pattern
- **Single Responsibility**: Model owns data structure AND Firestore operations
- **No Code Duplication**: All services use the same Firestore methods from models
- **Performance**: O(k) complexity - only sync what's needed
- **Maintainability**: Firestore logic in one place per model
- **Offline-First**: Works seamlessly offline, syncs when online
