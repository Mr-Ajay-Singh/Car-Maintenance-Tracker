# Service Log Feature - Implementation Plan

## Feature Overview
The Service Log feature allows users to record and track all vehicle maintenance and service activities. Users can log service entries with details like service type, parts used, costs, receipts, and shop information. This feature provides a complete service history for each vehicle.

## Architecture
Following CLAUDE.md guidelines:
- **Data Layer**: ServiceEntry model with SQLite and Firestore operations
- **Service Layer**: Business logic for managing service records
- **Presentation Layer**: UI components (implemented in UI.md)

---

## Data Layer

### Service Entry Model

**File**: `lib/features/service_log/data/models/service_entry_model.dart`

```dart
class ServiceEntryModel {
  final String id;
  final String vehicleId;
  final String userId;
  final DateTime date;
  final int odometer;
  final String serviceType;
  final List<ServicePart> parts;
  final double totalCost;
  final String? shopId;
  final String? shopName;
  final String? notes;
  final List<String> receiptUrls;
  final bool warrantyCovered;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // Sync tracking fields
  final bool isSynced;
  final String? firebaseId;
  final DateTime? lastSyncedAt;

  ServiceEntryModel({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.date,
    required this.odometer,
    required this.serviceType,
    this.parts = const [],
    required this.totalCost,
    this.shopId,
    this.shopName,
    this.notes,
    this.receiptUrls = const [],
    this.warrantyCovered = false,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseId,
    this.lastSyncedAt,
  });

  // Static SQL queries
  static const String tableName = 'service_entries';

  static const String tableCreate = '''
    CREATE TABLE service_entries (
      id TEXT PRIMARY KEY,
      vehicleId TEXT NOT NULL,
      userId TEXT NOT NULL,
      date TEXT NOT NULL,
      odometer INTEGER NOT NULL,
      serviceType TEXT NOT NULL,
      parts TEXT,
      totalCost REAL NOT NULL,
      shopId TEXT,
      shopName TEXT,
      notes TEXT,
      receiptUrls TEXT,
      warrantyCovered INTEGER NOT NULL DEFAULT 0,
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
    'CREATE INDEX idx_service_entries_vehicleId ON service_entries(vehicleId)';

  static const String createIndexUserId =
    'CREATE INDEX idx_service_entries_userId ON service_entries(userId)';

  static const String createIndexSync =
    'CREATE INDEX idx_service_entries_isSynced ON service_entries(isSynced)';

  static const String createIndexDate =
    'CREATE INDEX idx_service_entries_date ON service_entries(date DESC)';

  static const String queryGetAll = '''
    SELECT * FROM service_entries
    WHERE userId = ? AND isDeleted = 0
    ORDER BY date DESC
  ''';

  static const String queryGetByVehicle = '''
    SELECT * FROM service_entries
    WHERE vehicleId = ? AND isDeleted = 0
    ORDER BY date DESC
  ''';

  static const String queryGetById = '''
    SELECT * FROM service_entries WHERE id = ? AND isDeleted = 0
  ''';

  static const String queryGetByType = '''
    SELECT * FROM service_entries
    WHERE vehicleId = ? AND serviceType = ? AND isDeleted = 0
    ORDER BY date DESC
  ''';

  static const String queryGetUnsynced = '''
    SELECT * FROM service_entries WHERE isSynced = 0 AND userId = ?
  ''';

  static const String queryGetRecent = '''
    SELECT * FROM service_entries
    WHERE vehicleId = ? AND isDeleted = 0
    ORDER BY date DESC
    LIMIT ?
  ''';

  static const String queryGetTotalCost = '''
    SELECT SUM(totalCost) as total
    FROM service_entries
    WHERE vehicleId = ? AND isDeleted = 0
    AND date >= ? AND date <= ?
  ''';

  static const String queryInsert = '''
    INSERT INTO service_entries (
      id, vehicleId, userId, date, odometer, serviceType, parts,
      totalCost, shopId, shopName, notes, receiptUrls, warrantyCovered,
      createdAt, updatedAt, isDeleted, isSynced, firebaseId, lastSyncedAt
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''';

  static const String queryUpdate = '''
    UPDATE service_entries SET
      date = ?, odometer = ?, serviceType = ?, parts = ?,
      totalCost = ?, shopId = ?, shopName = ?, notes = ?,
      receiptUrls = ?, warrantyCovered = ?,
      updatedAt = ?, isSynced = 0
    WHERE id = ?
  ''';

  static const String querySoftDelete = '''
    UPDATE service_entries SET isDeleted = 1, updatedAt = ?, isSynced = 0 WHERE id = ?
  ''';

  static const String queryMarkSynced = '''
    UPDATE service_entries SET isSynced = 1, firebaseId = ?, lastSyncedAt = ? WHERE id = ?
  ''';

  // Conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'serviceType': serviceType,
      'parts': _partsToJson(parts),
      'totalCost': totalCost,
      'shopId': shopId,
      'shopName': shopName,
      'notes': notes,
      'receiptUrls': receiptUrls.join(','),
      'warrantyCovered': warrantyCovered ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
      'firebaseId': firebaseId,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory ServiceEntryModel.fromMap(Map<String, dynamic> map) {
    return ServiceEntryModel(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      userId: map['userId'] as String,
      date: DateTime.parse(map['date'] as String),
      odometer: map['odometer'] as int,
      serviceType: map['serviceType'] as String,
      parts: _partsFromJson(map['parts'] as String?),
      totalCost: map['totalCost'] as double,
      shopId: map['shopId'] as String?,
      shopName: map['shopName'] as String?,
      notes: map['notes'] as String?,
      receiptUrls: map['receiptUrls'] != null && (map['receiptUrls'] as String).isNotEmpty
          ? (map['receiptUrls'] as String).split(',')
          : [],
      warrantyCovered: map['warrantyCovered'] == 1,
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
  static const String firestoreCollection = 'service_entries';

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'odometer': odometer,
      'serviceType': serviceType,
      'parts': parts.map((p) => p.toMap()).toList(),
      'totalCost': totalCost,
      'shopId': shopId,
      'shopName': shopName,
      'notes': notes,
      'receiptUrls': receiptUrls,
      'warrantyCovered': warrantyCovered,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory ServiceEntryModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ServiceEntryModel(
      id: data['id'] as String,
      vehicleId: data['vehicleId'] as String,
      userId: data['userId'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] as int),
      odometer: data['odometer'] as int,
      serviceType: data['serviceType'] as String,
      parts: (data['parts'] as List?)
          ?.map((p) => ServicePart.fromMap(p as Map<String, dynamic>))
          .toList() ?? [],
      totalCost: (data['totalCost'] as num).toDouble(),
      shopId: data['shopId'] as String?,
      shopName: data['shopName'] as String?,
      notes: data['notes'] as String?,
      receiptUrls: List<String>.from(data['receiptUrls'] ?? []),
      warrantyCovered: data['warrantyCovered'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int),
      isDeleted: data['isDeleted'] as bool? ?? false,
      isSynced: true,
      firebaseId: docId,
      lastSyncedAt: DateTime.now(),
    );
  }

  // Helper methods for parts JSON conversion
  static String _partsToJson(List<ServicePart> parts) {
    if (parts.isEmpty) return '[]';
    final list = parts.map((p) => p.toMap()).toList();
    return jsonEncode(list);
  }

  static List<ServicePart> _partsFromJson(String? json) {
    if (json == null || json.isEmpty || json == '[]') return [];
    try {
      final List<dynamic> list = jsonDecode(json);
      return list.map((item) => ServicePart.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  ServiceEntryModel copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    DateTime? date,
    int? odometer,
    String? serviceType,
    List<ServicePart>? parts,
    double? totalCost,
    String? shopId,
    String? shopName,
    String? notes,
    List<String>? receiptUrls,
    bool? warrantyCovered,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
    String? firebaseId,
    DateTime? lastSyncedAt,
  }) {
    return ServiceEntryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      serviceType: serviceType ?? this.serviceType,
      parts: parts ?? this.parts,
      totalCost: totalCost ?? this.totalCost,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      notes: notes ?? this.notes,
      receiptUrls: receiptUrls ?? this.receiptUrls,
      warrantyCovered: warrantyCovered ?? this.warrantyCovered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

// Service Part Model (nested)
class ServicePart {
  final String? partId;
  final String name;
  final int quantity;
  final double price;

  ServicePart({
    this.partId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'partId': partId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory ServicePart.fromMap(Map<String, dynamic> map) {
    return ServicePart(
      partId: map['partId'] as String?,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
    );
  }
}
```

---

## Service Layer

### Service Entry Service

**File**: `lib/features/service_log/service/service_entry_service.dart`

```dart
class ServiceEntryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CREATE
  Future<String> addServiceEntry(ServiceEntryModel entry) async {
    final db = await _dbHelper.database;

    await db.rawInsert(ServiceEntryModel.queryInsert, [
      entry.id,
      entry.vehicleId,
      entry.userId,
      entry.date.toIso8601String(),
      entry.odometer,
      entry.serviceType,
      ServiceEntryModel._partsToJson(entry.parts),
      entry.totalCost,
      entry.shopId,
      entry.shopName,
      entry.notes,
      entry.receiptUrls.join(','),
      entry.warrantyCovered ? 1 : 0,
      entry.createdAt.toIso8601String(),
      entry.updatedAt.toIso8601String(),
      entry.isDeleted ? 1 : 0,
      entry.isSynced ? 1 : 0,
      entry.firebaseId,
      entry.lastSyncedAt?.toIso8601String(),
    ]);

    // Update vehicle odometer if this is newer
    await _updateVehicleOdometer(entry.vehicleId, entry.odometer);

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        await _syncEntryToFirestore(entry);
      } catch (e) {
        print('Sync failed: $e');
      }
    }

    return entry.id;
  }

  // READ
  Future<List<ServiceEntryModel>> getAllEntries(String userId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ServiceEntryModel.queryGetAll, [userId]);
    return results.map((map) => ServiceEntryModel.fromMap(map)).toList();
  }

  Future<List<ServiceEntryModel>> getEntriesByVehicle(String vehicleId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ServiceEntryModel.queryGetByVehicle, [vehicleId]);
    return results.map((map) => ServiceEntryModel.fromMap(map)).toList();
  }

  Future<ServiceEntryModel?> getEntryById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ServiceEntryModel.queryGetById, [id]);
    if (results.isEmpty) return null;
    return ServiceEntryModel.fromMap(results.first);
  }

  Future<List<ServiceEntryModel>> getEntriesByType(
    String vehicleId,
    String serviceType,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ServiceEntryModel.queryGetByType,
      [vehicleId, serviceType],
    );
    return results.map((map) => ServiceEntryModel.fromMap(map)).toList();
  }

  Future<List<ServiceEntryModel>> getRecentEntries(
    String vehicleId,
    int limit,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ServiceEntryModel.queryGetRecent,
      [vehicleId, limit],
    );
    return results.map((map) => ServiceEntryModel.fromMap(map)).toList();
  }

  Future<double> getTotalCost(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ServiceEntryModel.queryGetTotalCost,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    if (results.isEmpty || results.first['total'] == null) return 0.0;
    return results.first['total'] as double;
  }

  // UPDATE
  Future<void> updateServiceEntry(ServiceEntryModel entry) async {
    final db = await _dbHelper.database;
    final updatedEntry = entry.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await db.rawUpdate(ServiceEntryModel.queryUpdate, [
      updatedEntry.date.toIso8601String(),
      updatedEntry.odometer,
      updatedEntry.serviceType,
      ServiceEntryModel._partsToJson(updatedEntry.parts),
      updatedEntry.totalCost,
      updatedEntry.shopId,
      updatedEntry.shopName,
      updatedEntry.notes,
      updatedEntry.receiptUrls.join(','),
      updatedEntry.warrantyCovered ? 1 : 0,
      updatedEntry.updatedAt.toIso8601String(),
      updatedEntry.id,
    ]);

    // Update vehicle odometer if needed
    await _updateVehicleOdometer(entry.vehicleId, entry.odometer);

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        await _syncEntryToFirestore(updatedEntry);
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // DELETE (soft delete)
  Future<void> deleteServiceEntry(String id) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(ServiceEntryModel.querySoftDelete, [
      DateTime.now().toIso8601String(),
      id,
    ]);

    // Try to sync deletion to Firestore
    if (await _isOnline()) {
      try {
        final entry = await getEntryById(id);
        if (entry != null && entry.firebaseId != null) {
          await _deleteFromFirestore(entry.userId, entry.firebaseId!);
        }
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // SYNC OPERATIONS
  Future<void> syncUnsyncedEntries(String userId) async {
    if (!await _isOnline()) return;

    final db = await _dbHelper.database;
    final unsyncedRows = await db.rawQuery(
      ServiceEntryModel.queryGetUnsynced,
      [userId],
    );

    for (final row in unsyncedRows) {
      try {
        final entry = ServiceEntryModel.fromMap(row);
        await _syncEntryToFirestore(entry);
      } catch (e) {
        print('Failed to sync service entry: $e');
      }
    }
  }

  Future<void> _syncEntryToFirestore(ServiceEntryModel entry) async {
    final firebaseId = await FirestoreHelper.pushServiceEntry(entry);

    final db = await _dbHelper.database;
    await db.rawUpdate(ServiceEntryModel.queryMarkSynced, [
      firebaseId,
      DateTime.now().toIso8601String(),
      entry.id,
    ]);
  }

  Future<void> _deleteFromFirestore(String userId, String firebaseId) async {
    await FirestoreHelper.deleteServiceEntry(userId, firebaseId);
  }

  Future<void> _updateVehicleOdometer(String vehicleId, int odometer) async {
    // Call VehicleService to update odometer if this reading is newer
    final vehicleService = VehicleService();
    final vehicle = await vehicleService.getVehicleById(vehicleId);
    if (vehicle != null && odometer > vehicle.currentOdometer) {
      await vehicleService.updateOdometer(vehicleId, odometer);
    }
  }

  Future<bool> _isOnline() async {
    return true; // Placeholder
  }
}
```

---

## Implementation Checklist

- [ ] Create ServiceEntryModel with all fields
- [ ] Create ServicePart nested model
- [ ] Add static SQL queries to ServiceEntryModel
- [ ] Add Firestore conversion methods
- [ ] Create ServiceEntryService with CRUD operations
- [ ] Integrate service_entries table in DatabaseHelper
- [ ] Add service entry sync methods to FirestoreHelper
- [ ] Test local CRUD operations
- [ ] Test filtering by vehicle and type
- [ ] Test cost calculations
- [ ] Test sync functionality

---

## Dependencies

- DatabaseHelper (common/data/)
- FirestoreHelper (common/data/)
- VehicleService (for odometer updates)
- Firebase Firestore
- sqflite
- uuid

---

## Notes

- Service entries are linked to vehicles (vehicleId foreign key)
- Parts stored as JSON string in SQLite, array in Firestore
- Receipt URLs stored as comma-separated in SQLite
- Automatically updates vehicle odometer when service logged
- Supports filtering by service type for maintenance history
- Soft delete pattern maintained
