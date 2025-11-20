import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../common/data/database_helper.dart';
import '../../../common/data/firestore_helper.dart';
import '../data/models/expense_model.dart';

/// ExpenseService - Service class for expense tracking and statistics
class ExpenseService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CREATE
  Future<String> addExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;

    try {
      await db.insert(
        ExpenseModel.tableName,
        expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Try to sync immediately if online
      if (await _isOnline()) {
        try {
          await _syncExpenseToFirestore(expense);
        } catch (e) {
          debugPrint('Sync failed for addExpense: $e');
          // Do not rethrow here, local save was successful.
          // The expense will remain unsynced and picked up by syncUnsyncedExpenses later.
        }
      }
    } catch (e) {
      debugPrint('Error adding expense to local DB: $e');
      rethrow; // Rethrow if local DB insert fails
    }

    return expense.id;
  }

  // READ
  Future<List<ExpenseModel>> getAllExpenses(String userId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ExpenseModel.queryGetAll, [userId]);
    return results.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<List<ExpenseModel>> getExpensesByVehicle(String vehicleId) async {
    final db = await _dbHelper.database;
    final results =
        await db.rawQuery(ExpenseModel.queryGetByVehicle, [vehicleId]);
    return results.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(ExpenseModel.queryGetById, [id]);
    if (results.isEmpty) return null;
    return ExpenseModel.fromMap(results.first);
  }

  Future<List<ExpenseModel>> getExpensesByCategory(
    String vehicleId,
    String category,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ExpenseModel.queryGetByCategory,
      [vehicleId, category],
    );
    return results.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<List<ExpenseModel>> getExpensesInRange(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ExpenseModel.queryGetInRange,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    return results.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // STATISTICS
  Future<double> getTotalExpenses(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ExpenseModel.queryGetTotalByVehicle,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    if (results.isEmpty || results.first['total'] == null) return 0.0;
    return (results.first['total'] as num).toDouble();
  }

  Future<Map<String, double>> getExpenseTotalsByCategory(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      ExpenseModel.queryGetTotalByCategory,
      [
        vehicleId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );

    final categoryTotals = <String, double>{};
    for (final row in results) {
      final category = row['category'] as String;
      final total = (row['total'] as num).toDouble();
      categoryTotals[category] = total;
    }

    return categoryTotals;
  }

  Future<double> getMonthlyAverage(String vehicleId, int months) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months, 1);
    final total = await getTotalExpenses(vehicleId, startDate, now);
    return total / months;
  }

  // UPDATE
  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    final updatedExpense = expense.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await db.update(
      ExpenseModel.tableName,
      updatedExpense.toMap(),
      where: 'id = ?',
      whereArgs: [updatedExpense.id],
    );

    // Try to sync immediately if online
    if (await _isOnline()) {
      try {
        await _syncExpenseToFirestore(updatedExpense);
      } catch (e) {
        debugPrint('Sync failed: $e');
      }
    }
  }

  // DELETE (soft delete)
  Future<void> deleteExpense(String id) async {
    final db = await _dbHelper.database;
    final expense = await getExpenseById(id);

    await db.rawUpdate(ExpenseModel.querySoftDelete, [
      DateTime.now().toIso8601String(),
      id,
    ]);

    // Try to sync deletion to Firestore
    if (await _isOnline() && expense != null && expense.firebaseId != null) {
      try {
        await _deleteFromFirestore(expense.userId, expense.firebaseId!);
      } catch (e) {
        debugPrint('Sync failed: $e');
      }
    }
  }

  // SYNC OPERATIONS
  Future<void> syncUnsyncedExpenses(String userId) async {
    if (!await _isOnline()) return;

    final db = await _dbHelper.database;
    final unsyncedRows = await db.rawQuery(
      ExpenseModel.queryGetUnsynced,
      [userId],
    );

    for (final row in unsyncedRows) {
      try {
        final expense = ExpenseModel.fromMap(row);
        await _syncExpenseToFirestore(expense);
      } catch (e) {
        debugPrint('Error adding expense: $e');
      }
    }
  }

  Future<void> _syncExpenseToFirestore(ExpenseModel expense) async {
    final firebaseId = await FirestoreHelper.pushExpense(expense);

    final db = await _dbHelper.database;
    await db.rawUpdate(ExpenseModel.queryMarkSynced, [
      firebaseId,
      DateTime.now().toIso8601String(),
      expense.id,
    ]);
  }

  Future<void> _deleteFromFirestore(String userId, String firebaseId) async {
    await FirestoreHelper.deleteExpense(userId, firebaseId);
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
