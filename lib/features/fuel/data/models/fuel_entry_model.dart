
/// FuelEntryModel - Data model for fuel fill-up entries
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
