import 'dart:convert';

/// ServicePart - Nested model for parts used in service
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

/// ServiceEntryModel - Data model for service/maintenance entries
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

  // Helper methods for parts JSON conversion
  static String partsToJson(List<ServicePart> parts) {
    if (parts.isEmpty) return '[]';
    final list = parts.map((p) => p.toMap()).toList();
    return jsonEncode(list);
  }

  static List<ServicePart> partsFromJson(String? json) {
    if (json == null || json.isEmpty || json == '[]') return [];
    try {
      final List<dynamic> list = jsonDecode(json);
      return list
          .map((item) => ServicePart.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'serviceType': serviceType,
      'parts': partsToJson(parts),
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
      parts: partsFromJson(map['parts'] as String?),
      totalCost: (map['totalCost'] as num).toDouble(),
      shopId: map['shopId'] as String?,
      shopName: map['shopName'] as String?,
      notes: map['notes'] as String?,
      receiptUrls: map['receiptUrls'] != null &&
              (map['receiptUrls'] as String).isNotEmpty
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

  factory ServiceEntryModel.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return ServiceEntryModel(
      id: data['id'] as String,
      vehicleId: data['vehicleId'] as String,
      userId: data['userId'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] as int),
      odometer: data['odometer'] as int,
      serviceType: data['serviceType'] as String,
      parts: (data['parts'] as List?)
              ?.map((p) => ServicePart.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
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
