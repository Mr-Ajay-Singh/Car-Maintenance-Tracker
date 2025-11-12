import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../common/data/database_helper.dart';
import '../../../common/data/firestore_helper.dart';
import '../data/models/vehicle_model.dart';

/// VehicleService - Service class for vehicle management
///
/// Handles CRUD operations and sync for vehicles
class VehicleService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CREATE
  Future<String> addVehicle(VehicleModel vehicle) async {
    final db = await _dbHelper.database;

    await db.rawInsert(VehicleModel.queryInsert, [
      vehicle.id,
      vehicle.userId,
      vehicle.vin,
      vehicle.make,
      vehicle.model,
      vehicle.trim,
      vehicle.year,
      vehicle.licensePlate,
      vehicle.currentOdometer,
      vehicle.fuelType,
      vehicle.purchaseDate?.toIso8601String(),
      vehicle.estimatedValue,
      vehicle.tags.join(','),
      vehicle.createdAt.toIso8601String(),
      vehicle.updatedAt.toIso8601String(),
      vehicle.isDeleted ? 1 : 0,
      vehicle.isSynced ? 1 : 0,
      vehicle.firebaseId,
      vehicle.lastSyncedAt?.toIso8601String(),
    ]);

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        await _syncVehicleToFirestore(vehicle);
      } catch (e) {
        print('Sync failed: $e');
      }
    }

    return vehicle.id;
  }

  // READ
  Future<List<VehicleModel>> getAllVehicles(String userId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(VehicleModel.queryGetAll, [userId]);
    return results.map((map) => VehicleModel.fromMap(map)).toList();
  }

  Future<VehicleModel?> getVehicleById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(VehicleModel.queryGetById, [id]);
    if (results.isEmpty) return null;
    return VehicleModel.fromMap(results.first);
  }

  // UPDATE
  Future<void> updateVehicle(VehicleModel vehicle) async {
    final db = await _dbHelper.database;
    final updatedVehicle = vehicle.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await db.rawUpdate(VehicleModel.queryUpdate, [
      updatedVehicle.vin,
      updatedVehicle.make,
      updatedVehicle.model,
      updatedVehicle.trim,
      updatedVehicle.year,
      updatedVehicle.licensePlate,
      updatedVehicle.currentOdometer,
      updatedVehicle.fuelType,
      updatedVehicle.purchaseDate?.toIso8601String(),
      updatedVehicle.estimatedValue,
      updatedVehicle.tags.join(','),
      updatedVehicle.updatedAt.toIso8601String(),
      updatedVehicle.id,
    ]);

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        await _syncVehicleToFirestore(updatedVehicle);
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // UPDATE ODOMETER
  Future<void> updateOdometer(String vehicleId, int newOdometer) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(VehicleModel.queryUpdateOdometer, [
      newOdometer,
      DateTime.now().toIso8601String(),
      vehicleId,
    ]);

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        final vehicle = await getVehicleById(vehicleId);
        if (vehicle != null) {
          await _syncVehicleToFirestore(vehicle);
        }
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // DELETE (soft delete)
  Future<void> deleteVehicle(String id) async {
    final db = await _dbHelper.database;
    final vehicle = await getVehicleById(id);

    await db.rawUpdate(VehicleModel.querySoftDelete, [
      DateTime.now().toIso8601String(),
      id,
    ]);

    // Try to sync deletion to Firestore
    if (await _isOnline() && vehicle != null && vehicle.firebaseId != null) {
      try {
        await _deleteFromFirestore(vehicle.userId, vehicle.firebaseId!);
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // SYNC OPERATIONS
  Future<void> syncUnsyncedVehicles(String userId) async {
    if (!await _isOnline()) return;

    final db = await _dbHelper.database;
    final unsyncedRows = await db.rawQuery(
      VehicleModel.queryGetUnsynced,
      [userId],
    );

    for (final row in unsyncedRows) {
      try {
        final vehicle = VehicleModel.fromMap(row);
        await _syncVehicleToFirestore(vehicle);
      } catch (e) {
        print('Failed to sync vehicle: $e');
      }
    }
  }

  Future<void> _syncVehicleToFirestore(VehicleModel vehicle) async {
    // Push to Firestore and mark as synced
    final firebaseId = await FirestoreHelper.pushVehicle(vehicle);

    final db = await _dbHelper.database;
    await db.rawUpdate(VehicleModel.queryMarkSynced, [
      firebaseId,
      DateTime.now().toIso8601String(),
      vehicle.id,
    ]);
  }

  Future<void> _deleteFromFirestore(String userId, String firebaseId) async {
    await FirestoreHelper.deleteVehicle(userId, firebaseId);
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
