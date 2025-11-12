# Fuel Tracking Feature - Implementation Plan

## Feature Overview
The Fuel Tracking feature allows users to log fuel fill-ups, track fuel economy (MPG/L per 100km), monitor fuel costs, and analyze fuel consumption patterns. This feature provides insights into vehicle efficiency and helps identify potential mechanical issues through fuel economy trends.

## Architecture
Following CLAUDE.md guidelines:
- **Data Layer**: FuelEntry model with SQLite and Firestore operations
- **Service Layer**: Business logic for fuel logging and calculations
- **Presentation Layer**: UI components (implemented in UI.md)

---

## Data Layer

### Fuel Entry Model

**File**: `lib/features/fuel/data/models/fuel_entry_model.dart`

```dart
class FuelEntryModel {
  final String id;
  final String vehicleId;
  final String userId;
  final DateTime date;
  final int odometer;
  final double volume; // liters or gallons
  final double cost;
  final double pricePerUnit;
  final String? stationName;
  final String fuelType;
  final bool isFullTank;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // Sync tracking fields
  final bool isSynced;
  final String? firebaseId;
  final DateTime? lastSyncedAt;

  // Calculated field (not stored)
  double? fuelEconomy;

  FuelEntryModel({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.date,
    required this.odometer,
    required this.volume,
    required this.cost,
    required this.pricePerUnit,
    this.stationName,
    required this.fuelType,
    this.isFullTank = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseId,
    this.lastSyncedAt,
    this.fuelEconomy,
  });

  // Static SQL queries
  static const String tableName = 'fuel_entries';

  static const String tableCreate = '''
    CREATE TABLE fuel_entries (
      id TEXT PRIMARY KEY,
      vehicleId TEXT NOT NULL,
      userId TEXT NOT NULL,
      date TEXT NOT NULL,
      odometer INTEGER NOT NULL,
      volume REAL NOT NULL,
      cost REAL NOT NULL,
      pricePerUnit REAL NOT NULL,
      stationName TEXT,
      fuelType TEXT NOT NULL,
      isFullTank INTEGER NOT NULL DEFAULT 1,
      notes TEXT,
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
    'CREATE INDEX idx_fuel_entries_vehicleId ON fuel_entries(vehicleId)';

  static const String createIndexUserId =
    'CREATE INDEX idx_fuel_entries_userId ON fuel_entries(userId)';

  static const String createIndexSync =
    'CREATE INDEX idx_fuel_entries_isSynced ON fuel_entries(isSynced)';

  static const String createIndexDate =
    'CREATE INDEX idx_fuel_entries_date ON fuel_entries(date DESC)';

  static const String queryGetAll = '''
    SELECT * FROM fuel_entries
    WHERE userId = ? AND isDeleted = 0
    ORDER BY date DESC, odometer DESC
  ''';

  static const String queryGetByVehicle = '''
    SELECT * FROM fuel_entries
    WHERE vehicleId = ? AND isDeleted = 0
    ORDER BY date DESC, odometer DESC
  ''';

  static const String queryGetById = '''
    SELECT * FROM fuel_entries WHERE id = ? AND isDeleted = 0
  ''';

  static const String queryGetUnsynced = '''
    SELECT * FROM fuel_entries WHERE isSynced = 0 AND userId = ?
  ''';

  static const String queryGetRecent = '''
    SELECT * FROM fuel_entries
    WHERE vehicleId = ? AND isDeleted = 0
    ORDER BY date DESC, odometer DESC
    LIMIT ?
  ''';

  static const String queryGetInRange = '''
    SELECT * FROM fuel_entries
    WHERE vehicleId = ? AND isDeleted = 0
    AND date >= ? AND date <= ?
    ORDER BY date DESC, odometer DESC
  ''';

  static const String queryGetTotalCost = '''
    SELECT SUM(cost) as total
    FROM fuel_entries
    WHERE vehicleId = ? AND isDeleted = 0
    AND date >= ? AND date <= ?
  ''';

  static const String queryGetTotalVolume = '''
    SELECT SUM(volume) as total
    FROM fuel_entries
    WHERE vehicleId = ? AND isDeleted = 0
    AND date >= ? AND date <= ?
  ''';

  static const String queryGetAveragePrice = '''
    SELECT AVG(pricePerUnit) as average
    FROM fuel_entries
    WHERE vehicleId = ? AND isDeleted = 0
    AND date >= ? AND date <= ?
  ''';

  static const String queryInsert = '''
    INSERT INTO fuel_entries (
      id, vehicleId, userId, date, odometer, volume, cost,
      pricePerUnit, stationName, fuelType, isFullTank, notes,
      createdAt, updatedAt, isDeleted, isSynced, firebaseId, lastSyncedAt
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''';

  static const String queryUpdate = '''
    UPDATE fuel_entries SET
      date = ?, odometer = ?, volume = ?, cost = ?,
      pricePerUnit = ?, stationName = ?, fuelType = ?,
      isFullTank = ?, notes = ?,
      updatedAt = ?, isSynced = 0
    WHERE id = ?
  ''';

  static const String querySoftDelete = '''
    UPDATE fuel_entries SET isDeleted = 1, updatedAt = ?, isSynced = 0 WHERE id = ?
  ''';

  static const String queryMarkSynced = '''
    UPDATE fuel_entries SET isSynced = 1, firebaseId = ?, lastSyncedAt = ? WHERE id = ?
  ''';

  // Conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'volume': volume,
      'cost': cost,
      'pricePerUnit': pricePerUnit,
      'stationName': stationName,
      'fuelType': fuelType,
      'isFullTank': isFullTank ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
      'firebaseId': firebaseId,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory FuelEntryModel.fromMap(Map<String, dynamic> map) {
    return FuelEntryModel(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      userId: map['userId'] as String,
      date: DateTime.parse(map['date'] as String),
      odometer: map['odometer'] as int,
      volume: map['volume'] as double,
      cost: map['cost'] as double,
      pricePerUnit: map['pricePerUnit'] as double,
      stationName: map['stationName'] as String?,
      fuelType: map['fuelType'] as String,
      isFullTank: map['isFullTank'] == 1,
      notes: map['notes'] as String?,
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
  static const String firestoreCollection = 'fuel_entries';

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'odometer': odometer,
      'volume': volume,
      'cost': cost,
      'pricePerUnit': pricePerUnit,
      'stationName': stationName,
      'fuelType': fuelType,
      'isFullTank': isFullTank,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory FuelEntryModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return FuelEntryModel(
      id: data['id'] as String,
      vehicleId: data['vehicleId'] as String,
      userId: data['userId'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] as int),
      odometer: data['odometer'] as int,
      volume: (data['volume'] as num).toDouble(),
      cost: (data['cost'] as num).toDouble(),
      pricePerUnit: (data['pricePerUnit'] as num).toDouble(),
      stationName: data['stationName'] as String?,
      fuelType: data['fuelType'] as String,
      isFullTank: data['isFullTank'] as bool? ?? true,
      notes: data['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int),
      isDeleted: data['isDeleted'] as bool? ?? false,
      isSynced: true,
      firebaseId: docId,
      lastSyncedAt: DateTime.now(),
    );
  }

  FuelEntryModel copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    DateTime? date,
    int? odometer,
    double? volume,
    double? cost,
    double? pricePerUnit,
    String? stationName,
    String? fuelType,
    bool? isFullTank,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
    String? firebaseId,
    DateTime? lastSyncedAt,
    double? fuelEconomy,
  }) {
    return FuelEntryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      volume: volume ?? this.volume,
      cost: cost ?? this.cost,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      stationName: stationName ?? this.stationName,
      fuelType: fuelType ?? this.fuelType,
      isFullTank: isFullTank ?? this.isFullTank,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      fuelEconomy: fuelEconomy ?? this.fuelEconomy,
    );
  }
}
```

---

## Service Layer

### Fuel Entry Service

**File**: `lib/features/fuel/service/fuel_entry_service.dart`

```dart
class FuelEntryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CREATE
  Future<String> addFuelEntry(FuelEntryModel entry) async {
    final db = await _dbHelper.database;

    await db.rawInsert(FuelEntryModel.queryInsert, [
      entry.id,
      entry.vehicleId,
      entry.userId,
      entry.date.toIso8601String(),
      entry.odometer,
      entry.volume,
      entry.cost,
      entry.pricePerUnit,
      entry.stationName,
      entry.fuelType,
      entry.isFullTank ? 1 : 0,
      entry.notes,
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
  Future<List<FuelEntryModel>> getAllEntries(String userId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(FuelEntryModel.queryGetAll, [userId]);
    final entries = results.map((map) => FuelEntryModel.fromMap(map)).toList();
    return _calculateFuelEconomy(entries);
  }

  Future<List<FuelEntryModel>> getEntriesByVehicle(String vehicleId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(FuelEntryModel.queryGetByVehicle, [vehicleId]);
    final entries = results.map((map) => FuelEntryModel.fromMap(map)).toList();
    return _calculateFuelEconomy(entries);
  }

  Future<FuelEntryModel?> getEntryById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(FuelEntryModel.queryGetById, [id]);
    if (results.isEmpty) return null;
    return FuelEntryModel.fromMap(results.first);
  }

  Future<List<FuelEntryModel>> getRecentEntries(
    String vehicleId,
    int limit,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      FuelEntryModel.queryGetRecent,
      [vehicleId, limit],
    );
    final entries = results.map((map) => FuelEntryModel.fromMap(map)).toList();
    return _calculateFuelEconomy(entries);
  }

  Future<List<FuelEntryModel>> getEntriesInRange(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      FuelEntryModel.queryGetInRange,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    final entries = results.map((map) => FuelEntryModel.fromMap(map)).toList();
    return _calculateFuelEconomy(entries);
  }

  // STATISTICS
  Future<double> getTotalCost(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      FuelEntryModel.queryGetTotalCost,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    if (results.isEmpty || results.first['total'] == null) return 0.0;
    return results.first['total'] as double;
  }

  Future<double> getTotalVolume(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      FuelEntryModel.queryGetTotalVolume,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    if (results.isEmpty || results.first['total'] == null) return 0.0;
    return results.first['total'] as double;
  }

  Future<double> getAveragePrice(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      FuelEntryModel.queryGetAveragePrice,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    if (results.isEmpty || results.first['average'] == null) return 0.0;
    return results.first['average'] as double;
  }

  Future<double> getAverageFuelEconomy(String vehicleId) async {
    final entries = await getEntriesByVehicle(vehicleId);
    if (entries.isEmpty) return 0.0;

    final validEconomies = entries
        .where((e) => e.fuelEconomy != null && e.fuelEconomy! > 0)
        .map((e) => e.fuelEconomy!)
        .toList();

    if (validEconomies.isEmpty) return 0.0;

    final sum = validEconomies.reduce((a, b) => a + b);
    return sum / validEconomies.length;
  }

  // UPDATE
  Future<void> updateFuelEntry(FuelEntryModel entry) async {
    final db = await _dbHelper.database;
    final updatedEntry = entry.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await db.rawUpdate(FuelEntryModel.queryUpdate, [
      updatedEntry.date.toIso8601String(),
      updatedEntry.odometer,
      updatedEntry.volume,
      updatedEntry.cost,
      updatedEntry.pricePerUnit,
      updatedEntry.stationName,
      updatedEntry.fuelType,
      updatedEntry.isFullTank ? 1 : 0,
      updatedEntry.notes,
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
  Future<void> deleteFuelEntry(String id) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(FuelEntryModel.querySoftDelete, [
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

  // FUEL ECONOMY CALCULATION
  List<FuelEntryModel> _calculateFuelEconomy(List<FuelEntryModel> entries) {
    if (entries.length < 2) return entries;

    final result = <FuelEntryModel>[];
    for (int i = 0; i < entries.length; i++) {
      if (i == entries.length - 1) {
        // Last entry (oldest) - no previous entry to calculate from
        result.add(entries[i]);
      } else {
        // Calculate fuel economy using next entry (older)
        final current = entries[i];
        final previous = entries[i + 1];

        if (current.isFullTank && previous.isFullTank) {
          final distanceTraveled = (current.odometer - previous.odometer).toDouble();
          if (distanceTraveled > 0) {
            // MPG = distance / gallons or L/100km = (liters / distance) * 100
            final economy = distanceTraveled / current.volume; // MPG style
            result.add(current.copyWith(fuelEconomy: economy));
          } else {
            result.add(current);
          }
        } else {
          result.add(current);
        }
      }
    }
    return result;
  }

  // SYNC OPERATIONS
  Future<void> syncUnsyncedEntries(String userId) async {
    if (!await _isOnline()) return;

    final db = await _dbHelper.database;
    final unsyncedRows = await db.rawQuery(
      FuelEntryModel.queryGetUnsynced,
      [userId],
    );

    for (final row in unsyncedRows) {
      try {
        final entry = FuelEntryModel.fromMap(row);
        await _syncEntryToFirestore(entry);
      } catch (e) {
        print('Failed to sync fuel entry: $e');
      }
    }
  }

  Future<void> _syncEntryToFirestore(FuelEntryModel entry) async {
    final firebaseId = await FirestoreHelper.pushFuelEntry(entry);

    final db = await _dbHelper.database;
    await db.rawUpdate(FuelEntryModel.queryMarkSynced, [
      firebaseId,
      DateTime.now().toIso8601String(),
      entry.id,
    ]);
  }

  Future<void> _deleteFromFirestore(String userId, String firebaseId) async {
    await FirestoreHelper.deleteFuelEntry(userId, firebaseId);
  }

  Future<void> _updateVehicleOdometer(String vehicleId, int odometer) async {
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

- [ ] Create FuelEntryModel with all fields
- [ ] Add static SQL queries
- [ ] Add Firestore conversion methods
- [ ] Create FuelEntryService with CRUD operations
- [ ] Implement fuel economy calculation algorithm
- [ ] Add statistics methods (total cost, volume, average price)
- [ ] Integrate fuel_entries table in DatabaseHelper
- [ ] Add fuel sync methods to FirestoreHelper
- [ ] Test fuel economy calculations
- [ ] Test statistics queries

---

## Notes

- Fuel economy calculated between consecutive full-tank fill-ups
- Automatically updates vehicle odometer
- Supports partial fill-ups (isFullTank flag)
- Statistical queries for cost analysis
- Price per unit stored for historical price tracking
