import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../common/data/database_helper.dart';
import '../../../common/data/firestore_helper.dart';
import '../../vehicle/service/vehicle_service.dart';
import '../data/models/service_entry_model.dart';

/// ServiceEntryService - Service class for maintenance/service entry management
class ServiceEntryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final VehicleService _vehicleService = VehicleService();

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
      ServiceEntryModel.partsToJson(entry.parts),
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
        debugPrint('Sync failed: $e');
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
    final results =
        await db.rawQuery(ServiceEntryModel.queryGetByVehicle, [vehicleId]);
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
      ServiceEntryModel.partsToJson(updatedEntry.parts),
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
        debugPrint('Sync failed: $e');
      }
    }
  }

  // DELETE (soft delete)
  Future<void> deleteServiceEntry(String id) async {
    final db = await _dbHelper.database;
    final entry = await getEntryById(id);

    await db.rawUpdate(ServiceEntryModel.querySoftDelete, [
      DateTime.now().toIso8601String(),
      id,
    ]);

    // Try to sync deletion to Firestore
    if (await _isOnline() && entry != null && entry.firebaseId != null) {
      try {
        await _deleteFromFirestore(entry.userId, entry.firebaseId!);
      } catch (e) {
        debugPrint('Sync failed: $e');
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
        debugPrint('Failed to sync service entry: $e');
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
    final vehicle = await _vehicleService.getVehicleById(vehicleId);
    if (vehicle != null && odometer > vehicle.currentOdometer) {
      await _vehicleService.updateOdometer(vehicleId, odometer);
    }
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
