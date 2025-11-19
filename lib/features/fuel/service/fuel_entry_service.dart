import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../../common/data/database_helper.dart';
import '../../../common/data/firestore_helper.dart';
import '../../vehicle/service/vehicle_service.dart';
import '../data/models/fuel_entry_model.dart';

/// FuelEntryService - Service class for fuel tracking and economy calculations
class FuelEntryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final VehicleService _vehicleService = VehicleService();

  // CREATE
  Future<String> addFuelEntry(FuelEntryModel entry) async {
    final db = await _dbHelper.database;

    await db.insert(
      FuelEntryModel.tableName,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

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
  Future<List<FuelEntryModel>> getAllEntries(String userId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(FuelEntryModel.queryGetAll, [userId]);
    final entries = results.map((map) => FuelEntryModel.fromMap(map)).toList();
    return _calculateFuelEconomy(entries);
  }

  Future<List<FuelEntryModel>> getEntriesByVehicle(String vehicleId) async {
    final db = await _dbHelper.database;
    final results =
        await db.rawQuery(FuelEntryModel.queryGetByVehicle, [vehicleId]);
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

    await db.update(
      FuelEntryModel.tableName,
      updatedEntry.toMap(),
      where: 'id = ?',
      whereArgs: [updatedEntry.id],
    );

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
  Future<void> deleteFuelEntry(String id) async {
    final db = await _dbHelper.database;
    final entry = await getEntryById(id);

    await db.rawUpdate(FuelEntryModel.querySoftDelete, [
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

  // FUEL ECONOMY CALCULATION
  /// Calculates fuel economy between consecutive full-tank fill-ups
  /// MPG = distance traveled / gallons used
  /// L/100km = (liters / distance) * 100
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

        // Only calculate if both are full tank fill-ups
        if (current.isFullTank && previous.isFullTank) {
          final distanceTraveled =
              (current.odometer - previous.odometer).toDouble();

          if (distanceTraveled > 0 && current.volume > 0) {
            // MPG style calculation (distance per volume)
            final economy = distanceTraveled / current.volume;
            result.add(current.copyWith(fuelEconomy: economy));
          } else {
            result.add(current);
          }
        } else {
          // Not a full tank, can't calculate economy
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
        debugPrint('Error adding fuel entry: $e');
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
