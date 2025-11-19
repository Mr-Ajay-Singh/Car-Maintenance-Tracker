

/// VehicleModel - Data model for vehicles
///
/// Represents a vehicle with all its metadata and sync tracking
class VehicleModel {
  final String id;
  final String userId;
  final String? vin;
  final String make;
  final String model;
  final String? trim;
  final int year;
  final String? licensePlate;
  final int currentOdometer;
  final String fuelType;
  final DateTime? purchaseDate;
  final double? estimatedValue;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // Sync tracking fields
  final bool isSynced;
  final String? firebaseId;
  final DateTime? lastSyncedAt;

  VehicleModel({
    required this.id,
    required this.userId,
    this.vin,
    required this.make,
    required this.model,
    this.trim,
    required this.year,
    this.licensePlate,
    required this.currentOdometer,
    required this.fuelType,
    this.purchaseDate,
    this.estimatedValue,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseId,
    this.lastSyncedAt,
  });

  // Static SQL queries
  static const String tableName = 'vehicles';

  static const String tableCreate = '''
    CREATE TABLE vehicles (
      id TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      vin TEXT,
      make TEXT NOT NULL,
      model TEXT NOT NULL,
      trim TEXT,
      year INTEGER NOT NULL,
      licensePlate TEXT,
      currentOdometer INTEGER NOT NULL DEFAULT 0,
      fuelType TEXT NOT NULL,
      purchaseDate TEXT,
      estimatedValue REAL,
      tags TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      isSynced INTEGER NOT NULL DEFAULT 0,
      firebaseId TEXT,
      lastSyncedAt TEXT
    )
  ''';

  static const String createIndexUserId =
      'CREATE INDEX idx_vehicles_userId ON vehicles(userId)';

  static const String createIndexSync =
      'CREATE INDEX idx_vehicles_isSynced ON vehicles(isSynced)';

  static const String queryGetAll = '''
    SELECT * FROM vehicles
    WHERE userId = ? AND isDeleted = 0
    ORDER BY createdAt DESC
  ''';

  static const String queryGetById = '''
    SELECT * FROM vehicles WHERE id = ? AND isDeleted = 0
  ''';

  static const String queryGetUnsynced = '''
    SELECT * FROM vehicles WHERE isSynced = 0 AND userId = ?
  ''';

  static const String queryInsert = '''
    INSERT INTO vehicles (
      id, userId, vin, make, model, trim, year, licensePlate,
      currentOdometer, fuelType, purchaseDate, estimatedValue, tags,
      createdAt, updatedAt, isDeleted, isSynced, firebaseId, lastSyncedAt
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''';

  static const String queryUpdate = '''
    UPDATE vehicles SET
      vin = ?, make = ?, model = ?, trim = ?, year = ?,
      licensePlate = ?, currentOdometer = ?, fuelType = ?,
      purchaseDate = ?, estimatedValue = ?, tags = ?,
      updatedAt = ?, isSynced = 0
    WHERE id = ?
  ''';

  static const String querySoftDelete = '''
    UPDATE vehicles SET isDeleted = 1, updatedAt = ?, isSynced = 0 WHERE id = ?
  ''';

  static const String queryMarkSynced = '''
    UPDATE vehicles SET isSynced = 1, firebaseId = ?, lastSyncedAt = ? WHERE id = ?
  ''';

  static const String queryUpdateOdometer = '''
    UPDATE vehicles SET currentOdometer = ?, updatedAt = ?, isSynced = 0 WHERE id = ?
  ''';

  // Conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vin': vin,
      'make': make,
      'model': model,
      'trim': trim,
      'year': year,
      'licensePlate': licensePlate,
      'currentOdometer': currentOdometer,
      'fuelType': fuelType,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'estimatedValue': estimatedValue,
      'tags': tags.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
      'firebaseId': firebaseId,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      vin: map['vin'] as String?,
      make: map['make'] as String,
      model: map['model'] as String,
      trim: map['trim'] as String?,
      year: map['year'] as int,
      licensePlate: map['licensePlate'] as String?,
      currentOdometer: map['currentOdometer'] as int,
      fuelType: map['fuelType'] as String,
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.parse(map['purchaseDate'] as String)
          : null,
      estimatedValue: map['estimatedValue'] as double?,
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
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
  static const String firestoreCollection = 'vehicles';

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'vin': vin,
      'make': make,
      'model': model,
      'trim': trim,
      'year': year,
      'licensePlate': licensePlate,
      'currentOdometer': currentOdometer,
      'fuelType': fuelType,
      'purchaseDate': purchaseDate?.millisecondsSinceEpoch,
      'estimatedValue': estimatedValue,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory VehicleModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return VehicleModel(
      id: data['id'] as String,
      userId: data['userId'] as String,
      vin: data['vin'] as String?,
      make: data['make'] as String,
      model: data['model'] as String,
      trim: data['trim'] as String?,
      year: data['year'] as int,
      licensePlate: data['licensePlate'] as String?,
      currentOdometer: data['currentOdometer'] as int,
      fuelType: data['fuelType'] as String,
      purchaseDate: data['purchaseDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['purchaseDate'] as int)
          : null,
      estimatedValue: data['estimatedValue'] as double?,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int),
      isDeleted: data['isDeleted'] as bool? ?? false,
      isSynced: true,
      firebaseId: docId,
      lastSyncedAt: DateTime.now(),
    );
  }

  VehicleModel copyWith({
    String? id,
    String? userId,
    String? vin,
    String? make,
    String? model,
    String? trim,
    int? year,
    String? licensePlate,
    int? currentOdometer,
    String? fuelType,
    DateTime? purchaseDate,
    double? estimatedValue,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
    String? firebaseId,
    DateTime? lastSyncedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vin: vin ?? this.vin,
      make: make ?? this.make,
      model: model ?? this.model,
      trim: trim ?? this.trim,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      fuelType: fuelType ?? this.fuelType,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
