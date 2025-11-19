import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../common/data/database_helper.dart';
import '../../../common/data/firestore_helper.dart';
import '../../../common/data/shared_preferences_helper.dart';
import '../../vehicle/data/models/vehicle_model.dart';
import '../../service_log/data/models/service_entry_model.dart';
import '../../fuel/data/models/fuel_entry_model.dart';
import '../../reminders/data/models/reminder_model.dart';
import '../../expenses/data/models/expense_model.dart';

/// FirebaseSyncService - Optimized O(k) sync implementation
///
/// This service implements Firebase Cloud Firestore sync with O(k) time complexity
/// where k = number of unsynced elements (not all n elements).
///
/// Key Features:
/// - First sign-in: Full sync (one-time O(n))
/// - Subsequent syncs: Incremental sync (O(k) only)
/// - Uses isSynced flag for implicit offline queue
/// - Indexed queries for fast performance
class FirebaseSyncService {
  static final FirebaseSyncService instance = FirebaseSyncService._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  factory FirebaseSyncService() => instance;

  FirebaseSyncService._internal();

  // ==================== CORE SYNC METHODS ====================

  /// Main sync method - orchestrates full bidirectional sync
  /// Returns true if sync was successful
  Future<bool> syncAll() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('🔄 Sync skipped: No authenticated user');
        return false;
      }

      final userId = user.uid;
      debugPrint('🔄 Starting sync for user: $userId');

      // Check if this is the first sync
      final isFirstSync = !(await SharedPreferencesHelper.getFirstSyncCompleted());

      if (isFirstSync) {
        debugPrint('🔄 First sync detected - performing full sync');
        await _performFirstSync(userId);
      } else {
        debugPrint('🔄 Incremental sync - O(k) optimization');
        await _performIncrementalSync(userId);
      }

      // Update last sync timestamp
      await SharedPreferencesHelper.setLastSyncTimestamp(
        DateTime.now().toIso8601String(),
      );

      debugPrint('✅ Sync completed successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Sync failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Perform first-time full sync (one-time O(n) operation)
  Future<void> _performFirstSync(String userId) async {
    // Step 1: Pull all data from Firestore (if any exists)
    await _pullAllFromFirestore(userId);

    // Step 2: Push all local data to Firestore (if any exists)
    await _pushAllToFirestore(userId);

    // Mark first sync as completed
    await SharedPreferencesHelper.setFirstSyncCompleted(true);
  }

  /// Perform incremental sync (O(k) where k = unsynced/updated count)
  Future<void> _performIncrementalSync(String userId) async {
    // Step 1: Push unsynced local changes to Firestore (O(k))
    await _pushUnsyncedToFirestore(userId);

    // Step 2: Pull updated records from Firestore since last sync (O(k))
    await _pullUpdatedFromFirestore(userId);
  }

  // ==================== PUSH OPERATIONS (Local → Cloud) ====================

  /// Push ALL local data to Firestore (used only on first sync)
  Future<void> _pushAllToFirestore(String userId) async {
    final db = await _dbHelper.database;

    // Push vehicles
    await _pushAllVehicles(db, userId);

    // Push service entries
    await _pushAllServiceEntries(db, userId);

    // Push fuel entries
    await _pushAllFuelEntries(db, userId);

    // Push reminders
    await _pushAllReminders(db, userId);

    // Push expenses
    await _pushAllExpenses(db, userId);
  }

  /// Push ONLY unsynced local data to Firestore (O(k) optimization)
  Future<void> _pushUnsyncedToFirestore(String userId) async {
    final db = await _dbHelper.database;

    // Push unsynced vehicles
    await _pushUnsyncedVehicles(db, userId);

    // Push unsynced service entries
    await _pushUnsyncedServiceEntries(db, userId);

    // Push unsynced fuel entries
    await _pushUnsyncedFuelEntries(db, userId);

    // Push unsynced reminders
    await _pushUnsyncedReminders(db, userId);

    // Push unsynced expenses
    await _pushUnsyncedExpenses(db, userId);
  }

  // ==================== PULL OPERATIONS (Cloud → Local) ====================

  /// Pull ALL data from Firestore (used only on first sync)
  Future<void> _pullAllFromFirestore(String userId) async {
    final lastSyncTime = null; // Pull everything

    await _pullVehicles(userId, lastSyncTime);
    await _pullServiceEntries(userId, lastSyncTime);
    await _pullFuelEntries(userId, lastSyncTime);
    await _pullReminders(userId, lastSyncTime);
    await _pullExpenses(userId, lastSyncTime);
  }

  /// Pull ONLY updated data from Firestore since last sync (O(k) optimization)
  Future<void> _pullUpdatedFromFirestore(String userId) async {
    final lastSyncTimestampStr =
        await SharedPreferencesHelper.getLastSyncTimestamp();
    final lastSyncTime = lastSyncTimestampStr != null
        ? DateTime.parse(lastSyncTimestampStr)
        : null;

    await _pullVehicles(userId, lastSyncTime);
    await _pullServiceEntries(userId, lastSyncTime);
    await _pullFuelEntries(userId, lastSyncTime);
    await _pullReminders(userId, lastSyncTime);
    await _pullExpenses(userId, lastSyncTime);
  }

  // ==================== VEHICLE SYNC ====================

  Future<void> _pushAllVehicles(Database db, String userId) async {
    final rows = await db.rawQuery(VehicleModel.queryGetAll, [userId]);
    debugPrint('📤 Pushing ${rows.length} vehicles to Firestore');

    for (final row in rows) {
      try {
        final vehicle = VehicleModel.fromMap(row);
        final firebaseId = await FirestoreHelper.pushVehicle(vehicle);

        // Mark as synced
        await db.rawUpdate(
          VehicleModel.queryMarkSynced,
          [firebaseId, DateTime.now().toIso8601String(), vehicle.id],
        );
      } catch (e) {
        debugPrint('❌ Failed to push vehicle ${row['id']}: $e');
      }
    }
  }

  Future<void> _pushUnsyncedVehicles(Database db, String userId) async {
    final rows = await db.rawQuery(VehicleModel.queryGetUnsynced, [userId]);
    debugPrint('📤 Pushing ${rows.length} unsynced vehicles to Firestore');

    for (final row in rows) {
      try {
        final vehicle = VehicleModel.fromMap(row);

        // Check if this is a delete operation
        if (vehicle.isDeleted && vehicle.firebaseId != null) {
          // Delete from Firestore
          await FirestoreHelper.deleteVehicle(userId, vehicle.firebaseId!);

          // Mark as synced (deletion synced)
          await db.rawUpdate(
            VehicleModel.queryMarkSynced,
            [vehicle.firebaseId, DateTime.now().toIso8601String(), vehicle.id],
          );
        } else if (!vehicle.isDeleted) {
          // Normal push (create or update)
          final firebaseId = await FirestoreHelper.pushVehicle(vehicle);

          // Mark as synced
          await db.rawUpdate(
            VehicleModel.queryMarkSynced,
            [firebaseId, DateTime.now().toIso8601String(), vehicle.id],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to push vehicle ${row['id']}: $e');
      }
    }
  }

  Future<void> _pullVehicles(String userId, DateTime? lastSyncTime) async {
    final vehicles = await FirestoreHelper.pullVehicles(userId, lastSyncTime);
    debugPrint('📥 Pulling ${vehicles.length} vehicles from Firestore');

    final db = await _dbHelper.database;
    for (final data in vehicles) {
      try {
        final docId = data['docId'] as String;
        final vehicle = VehicleModel.fromFirestore(data, docId);

        // Check if vehicle exists locally
        final existing = await db.rawQuery(
          VehicleModel.queryGetById,
          [vehicle.id],
        );

        if (existing.isEmpty) {
          // Insert new vehicle
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
            1, // isSynced = true (from cloud)
            vehicle.firebaseId,
            DateTime.now().toIso8601String(), // lastSyncedAt
          ]);
        } else {
          // Update existing vehicle (cloud wins)
          await db.rawUpdate(
            '''UPDATE vehicles SET
               vin = ?, make = ?, model = ?, trim = ?, year = ?,
               licensePlate = ?, currentOdometer = ?, fuelType = ?,
               purchaseDate = ?, estimatedValue = ?, tags = ?,
               updatedAt = ?, isDeleted = ?, isSynced = 1,
               firebaseId = ?, lastSyncedAt = ?
               WHERE id = ?''',
            [
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
              vehicle.updatedAt.toIso8601String(),
              vehicle.isDeleted ? 1 : 0,
              vehicle.firebaseId,
              DateTime.now().toIso8601String(),
              vehicle.id,
            ],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to pull vehicle: $e');
      }
    }
  }

  // ==================== SERVICE ENTRY SYNC ====================

  Future<void> _pushAllServiceEntries(Database db, String userId) async {
    final rows = await db.rawQuery(ServiceEntryModel.queryGetAll, [userId]);
    debugPrint('📤 Pushing ${rows.length} service entries to Firestore');

    for (final row in rows) {
      try {
        final entry = ServiceEntryModel.fromMap(row);
        final firebaseId = await FirestoreHelper.pushServiceEntry(entry);

        await db.rawUpdate(
          ServiceEntryModel.queryMarkSynced,
          [firebaseId, DateTime.now().toIso8601String(), entry.id],
        );
      } catch (e) {
        debugPrint('❌ Failed to push service entry ${row['id']}: $e');
      }
    }
  }

  Future<void> _pushUnsyncedServiceEntries(Database db, String userId) async {
    final rows = await db.rawQuery(ServiceEntryModel.queryGetUnsynced, [userId]);
    debugPrint('📤 Pushing ${rows.length} unsynced service entries to Firestore');

    for (final row in rows) {
      try {
        final entry = ServiceEntryModel.fromMap(row);

        if (entry.isDeleted && entry.firebaseId != null) {
          await FirestoreHelper.deleteServiceEntry(userId, entry.firebaseId!);
          await db.rawUpdate(
            ServiceEntryModel.queryMarkSynced,
            [entry.firebaseId, DateTime.now().toIso8601String(), entry.id],
          );
        } else if (!entry.isDeleted) {
          final firebaseId = await FirestoreHelper.pushServiceEntry(entry);
          await db.rawUpdate(
            ServiceEntryModel.queryMarkSynced,
            [firebaseId, DateTime.now().toIso8601String(), entry.id],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to push service entry ${row['id']}: $e');
      }
    }
  }

  Future<void> _pullServiceEntries(String userId, DateTime? lastSyncTime) async {
    final entries = await FirestoreHelper.pullServiceEntries(userId, lastSyncTime);
    debugPrint('📥 Pulling ${entries.length} service entries from Firestore');

    final db = await _dbHelper.database;
    for (final data in entries) {
      try {
        final docId = data['docId'] as String;
        final entry = ServiceEntryModel.fromFirestore(data, docId);

        final existing = await db.rawQuery(
          ServiceEntryModel.queryGetById,
          [entry.id],
        );

        if (existing.isEmpty) {
          await db.rawInsert(ServiceEntryModel.queryInsert, [
            entry.id,
            entry.vehicleId,
            entry.userId,
            entry.date.toIso8601String(),
            entry.odometer,
            entry.serviceType,
            entry.parts.isNotEmpty ? ServiceEntryModel.partsToJson(entry.parts) : null,
            entry.totalCost,
            entry.shopId,
            entry.shopName,
            entry.notes,
            entry.receiptUrls.isNotEmpty ? entry.receiptUrls.join(',') : null,
            entry.warrantyCovered ? 1 : 0,
            entry.createdAt.toIso8601String(),
            entry.updatedAt.toIso8601String(),
            entry.isDeleted ? 1 : 0,
            1, // isSynced
            entry.firebaseId,
            DateTime.now().toIso8601String(),
          ]);
        } else {
          await db.rawUpdate(
            '''UPDATE service_entries SET
               vehicleId = ?, date = ?, odometer = ?, serviceType = ?,
               parts = ?, totalCost = ?, shopId = ?, shopName = ?, notes = ?,
               receiptUrls = ?, warrantyCovered = ?, updatedAt = ?, isDeleted = ?,
               isSynced = 1, firebaseId = ?, lastSyncedAt = ?
               WHERE id = ?''',
            [
              entry.vehicleId,
              entry.date.toIso8601String(),
              entry.odometer,
              entry.serviceType,
              entry.parts.isNotEmpty ? ServiceEntryModel.partsToJson(entry.parts) : null,
              entry.totalCost,
              entry.shopId,
              entry.shopName,
              entry.notes,
              entry.receiptUrls.isNotEmpty ? entry.receiptUrls.join(',') : null,
              entry.warrantyCovered ? 1 : 0,
              entry.updatedAt.toIso8601String(),
              entry.isDeleted ? 1 : 0,
              entry.firebaseId,
              DateTime.now().toIso8601String(),
              entry.id,
            ],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to pull service entry: $e');
      }
    }
  }

  // ==================== FUEL ENTRY SYNC ====================

  Future<void> _pushAllFuelEntries(Database db, String userId) async {
    final rows = await db.rawQuery(FuelEntryModel.queryGetAll, [userId]);
    debugPrint('📤 Pushing ${rows.length} fuel entries to Firestore');

    for (final row in rows) {
      try {
        final entry = FuelEntryModel.fromMap(row);
        final firebaseId = await FirestoreHelper.pushFuelEntry(entry);

        await db.rawUpdate(
          FuelEntryModel.queryMarkSynced,
          [firebaseId, DateTime.now().toIso8601String(), entry.id],
        );
      } catch (e) {
        debugPrint('❌ Failed to push fuel entry ${row['id']}: $e');
      }
    }
  }

  Future<void> _pushUnsyncedFuelEntries(Database db, String userId) async {
    final rows = await db.rawQuery(FuelEntryModel.queryGetUnsynced, [userId]);
    debugPrint('📤 Pushing ${rows.length} unsynced fuel entries to Firestore');

    for (final row in rows) {
      try {
        final entry = FuelEntryModel.fromMap(row);

        if (entry.isDeleted && entry.firebaseId != null) {
          await FirestoreHelper.deleteFuelEntry(userId, entry.firebaseId!);
          await db.rawUpdate(
            FuelEntryModel.queryMarkSynced,
            [entry.firebaseId, DateTime.now().toIso8601String(), entry.id],
          );
        } else if (!entry.isDeleted) {
          final firebaseId = await FirestoreHelper.pushFuelEntry(entry);
          await db.rawUpdate(
            FuelEntryModel.queryMarkSynced,
            [firebaseId, DateTime.now().toIso8601String(), entry.id],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to push fuel entry ${row['id']}: $e');
      }
    }
  }

  Future<void> _pullFuelEntries(String userId, DateTime? lastSyncTime) async {
    final entries = await FirestoreHelper.pullFuelEntries(userId, lastSyncTime);
    debugPrint('📥 Pulling ${entries.length} fuel entries from Firestore');

    final db = await _dbHelper.database;
    for (final data in entries) {
      try {
        final docId = data['docId'] as String;
        final entry = FuelEntryModel.fromFirestore(data, docId);

        final existing = await db.rawQuery(
          FuelEntryModel.queryGetById,
          [entry.id],
        );

        if (existing.isEmpty) {
          await db.insert(
            FuelEntryModel.tableName,
            entry.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          await db.update(
            FuelEntryModel.tableName,
            entry.toMap(),
            where: 'id = ?',
            whereArgs: [entry.id],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to pull fuel entry: $e');
      }
    }
  }

  // ==================== REMINDER SYNC ====================

  Future<void> _pushAllReminders(Database db, String userId) async {
    final rows = await db.rawQuery(ReminderModel.queryGetAll, [userId]);
    debugPrint('📤 Pushing ${rows.length} reminders to Firestore');

    for (final row in rows) {
      try {
        final reminder = ReminderModel.fromMap(row);
        final firebaseId = await FirestoreHelper.pushReminder(reminder);

        await db.rawUpdate(
          ReminderModel.queryMarkSynced,
          [firebaseId, DateTime.now().toIso8601String(), reminder.id],
        );
      } catch (e) {
        debugPrint('❌ Failed to push reminder ${row['id']}: $e');
      }
    }
  }

  Future<void> _pushUnsyncedReminders(Database db, String userId) async {
    final rows = await db.rawQuery(ReminderModel.queryGetUnsynced, [userId]);
    debugPrint('📤 Pushing ${rows.length} unsynced reminders to Firestore');

    for (final row in rows) {
      try {
        final reminder = ReminderModel.fromMap(row);

        if (reminder.isDeleted && reminder.firebaseId != null) {
          await FirestoreHelper.deleteReminder(userId, reminder.firebaseId!);
          await db.rawUpdate(
            ReminderModel.queryMarkSynced,
            [reminder.firebaseId, DateTime.now().toIso8601String(), reminder.id],
          );
        } else if (!reminder.isDeleted) {
          final firebaseId = await FirestoreHelper.pushReminder(reminder);
          await db.rawUpdate(
            ReminderModel.queryMarkSynced,
            [firebaseId, DateTime.now().toIso8601String(), reminder.id],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to push reminder ${row['id']}: $e');
      }
    }
  }

  Future<void> _pullReminders(String userId, DateTime? lastSyncTime) async {
    final reminders = await FirestoreHelper.pullReminders(userId, lastSyncTime);
    debugPrint('📥 Pulling ${reminders.length} reminders from Firestore');

    final db = await _dbHelper.database;
    for (final data in reminders) {
      try {
        final docId = data['docId'] as String;
        final reminder = ReminderModel.fromFirestore(data, docId);

        final existing = await db.rawQuery(
          ReminderModel.queryGetById,
          [reminder.id],
        );

        if (existing.isEmpty) {
          await db.rawInsert(ReminderModel.queryInsert, [
            reminder.id,
            reminder.vehicleId,
            reminder.userId,
            reminder.title,
            reminder.description,
            reminder.type,
            reminder.dueDate?.toIso8601String(),
            reminder.dueOdometer,
            reminder.isCompleted ? 1 : 0,
            reminder.completedDate?.toIso8601String(),
            reminder.createdAt.toIso8601String(),
            reminder.updatedAt.toIso8601String(),
            reminder.isDeleted ? 1 : 0,
            1, // isSynced
            reminder.firebaseId,
            DateTime.now().toIso8601String(),
          ]);
        } else {
          await db.rawUpdate(
            '''UPDATE reminders SET
               vehicleId = ?, title = ?, description = ?, reminderType = ?,
               dueDate = ?, dueOdometer = ?, isCompleted = ?, completedAt = ?,
               updatedAt = ?, isDeleted = ?, isSynced = 1,
               firebaseId = ?, lastSyncedAt = ?
               WHERE id = ?''',
            [
              reminder.vehicleId,
              reminder.title,
              reminder.description,
              reminder.type,
              reminder.dueDate?.toIso8601String(),
              reminder.dueOdometer,
              reminder.isCompleted ? 1 : 0,
              reminder.completedDate?.toIso8601String(),
              reminder.updatedAt.toIso8601String(),
              reminder.isDeleted ? 1 : 0,
              reminder.firebaseId,
              DateTime.now().toIso8601String(),
              reminder.id,
            ],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to pull reminder: $e');
      }
    }
  }

  // ==================== EXPENSE SYNC ====================

  Future<void> _pushAllExpenses(Database db, String userId) async {
    final rows = await db.rawQuery(ExpenseModel.queryGetAll, [userId]);
    debugPrint('📤 Pushing ${rows.length} expenses to Firestore');

    for (final row in rows) {
      try {
        final expense = ExpenseModel.fromMap(row);
        final firebaseId = await FirestoreHelper.pushExpense(expense);

        await db.rawUpdate(
          ExpenseModel.queryMarkSynced,
          [firebaseId, DateTime.now().toIso8601String(), expense.id],
        );
      } catch (e) {
        debugPrint('❌ Failed to push expense ${row['id']}: $e');
      }
    }
  }

  Future<void> _pushUnsyncedExpenses(Database db, String userId) async {
    final rows = await db.rawQuery(ExpenseModel.queryGetUnsynced, [userId]);
    debugPrint('📤 Pushing ${rows.length} unsynced expenses to Firestore');

    for (final row in rows) {
      try {
        final expense = ExpenseModel.fromMap(row);

        if (expense.isDeleted && expense.firebaseId != null) {
          await FirestoreHelper.deleteExpense(userId, expense.firebaseId!);
          await db.rawUpdate(
            ExpenseModel.queryMarkSynced,
            [expense.firebaseId, DateTime.now().toIso8601String(), expense.id],
          );
        } else if (!expense.isDeleted) {
          final firebaseId = await FirestoreHelper.pushExpense(expense);
          await db.rawUpdate(
            ExpenseModel.queryMarkSynced,
            [firebaseId, DateTime.now().toIso8601String(), expense.id],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to push expense ${row['id']}: $e');
      }
    }
  }

  Future<void> _pullExpenses(String userId, DateTime? lastSyncTime) async {
    final expenses = await FirestoreHelper.pullExpenses(userId, lastSyncTime);
    debugPrint('📥 Pulling ${expenses.length} expenses from Firestore');

    final db = await _dbHelper.database;
    for (final data in expenses) {
      try {
        final docId = data['docId'] as String;
        final expense = ExpenseModel.fromFirestore(data, docId);

        final existing = await db.rawQuery(
          ExpenseModel.queryGetById,
          [expense.id],
        );

        if (existing.isEmpty) {
          await db.insert(
            ExpenseModel.tableName,
            expense.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          await db.update(
            ExpenseModel.tableName,
            expense.toMap(),
            where: 'id = ?',
            whereArgs: [expense.id],
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to pull expense: $e');
      }
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Manually trigger sync (can be called from UI or background worker)
  Future<bool> triggerManualSync() async {
    debugPrint('🔄 Manual sync triggered');
    return await syncAll();
  }

  /// Check if user has unsynced data
  Future<bool> hasUnsyncedData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final db = await _dbHelper.database;
      final userId = user.uid;

      // Check for unsynced records in each table
      final vehicles = await db.rawQuery(VehicleModel.queryGetUnsynced, [userId]);
      if (vehicles.isNotEmpty) return true;

      final serviceEntries = await db.rawQuery(ServiceEntryModel.queryGetUnsynced, [userId]);
      if (serviceEntries.isNotEmpty) return true;

      final fuelEntries = await db.rawQuery(FuelEntryModel.queryGetUnsynced, [userId]);
      if (fuelEntries.isNotEmpty) return true;

      final reminders = await db.rawQuery(ReminderModel.queryGetUnsynced, [userId]);
      if (reminders.isNotEmpty) return true;

      final expenses = await db.rawQuery(ExpenseModel.queryGetUnsynced, [userId]);
      if (expenses.isNotEmpty) return true;

      return false;
    } catch (e) {
      debugPrint('❌ Error checking unsynced data: $e');
      return false;
    }
  }

  /// Get unsynced data count
  Future<int> getUnsyncedCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 0;

      final db = await _dbHelper.database;
      final userId = user.uid;

      int count = 0;

      final vehicles = await db.rawQuery(VehicleModel.queryGetUnsynced, [userId]);
      count += vehicles.length;

      final serviceEntries = await db.rawQuery(ServiceEntryModel.queryGetUnsynced, [userId]);
      count += serviceEntries.length;

      final fuelEntries = await db.rawQuery(FuelEntryModel.queryGetUnsynced, [userId]);
      count += fuelEntries.length;

      final reminders = await db.rawQuery(ReminderModel.queryGetUnsynced, [userId]);
      count += reminders.length;

      final expenses = await db.rawQuery(ExpenseModel.queryGetUnsynced, [userId]);
      count += expenses.length;

      return count;
    } catch (e) {
      debugPrint('❌ Error getting unsynced count: $e');
      return 0;
    }
  }

  /// Reset sync state (for testing/debugging)
  Future<void> resetSyncState() async {
    await SharedPreferencesHelper.setFirstSyncCompleted(false);
    await SharedPreferencesHelper.setLastSyncTimestamp('');
    debugPrint('🔄 Sync state reset');
  }
}
