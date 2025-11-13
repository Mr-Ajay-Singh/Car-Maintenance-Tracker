import 'package:cloud_firestore/cloud_firestore.dart';

/// FirestoreHelper - Class for all Firestore cloud sync operations
///
/// Centralized access to Firestore for cloud backup and multi-device sync
/// Following CLAUDE.md guidelines: All Firestore operations must go through this class
class FirestoreHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== VEHICLES ====================

  static Future<String> pushVehicle(dynamic vehicle) async {
    final docRef = _firestore
        .collection('users')
        .doc(vehicle.userId as String)
        .collection('vehicles')
        .doc(vehicle.firebaseId ?? vehicle.id as String);

    await docRef.set(vehicle.toFirestore() as Map<String, dynamic>);
    return docRef.id;
  }

  static Future<void> deleteVehicle(String userId, String firebaseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(firebaseId)
        .delete();
  }

  // ==================== SERVICE ENTRIES ====================

  static Future<String> pushServiceEntry(dynamic entry) async {
    final docRef = _firestore
        .collection('users')
        .doc(entry.userId as String)
        .collection('service_entries')
        .doc(entry.firebaseId ?? entry.id as String);

    await docRef.set(entry.toFirestore() as Map<String, dynamic>);
    return docRef.id;
  }

  static Future<void> deleteServiceEntry(String userId, String firebaseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('service_entries')
        .doc(firebaseId)
        .delete();
  }

  // ==================== FUEL ENTRIES ====================

  static Future<String> pushFuelEntry(dynamic entry) async {
    final docRef = _firestore
        .collection('users')
        .doc(entry.userId as String)
        .collection('fuel_entries')
        .doc(entry.firebaseId ?? entry.id as String);

    await docRef.set(entry.toFirestore() as Map<String, dynamic>);
    return docRef.id;
  }

  static Future<void> deleteFuelEntry(String userId, String firebaseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('fuel_entries')
        .doc(firebaseId)
        .delete();
  }

  // ==================== REMINDERS ====================

  static Future<String> pushReminder(dynamic reminder) async {
    final docRef = _firestore
        .collection('users')
        .doc(reminder.userId as String)
        .collection('reminders')
        .doc(reminder.firebaseId ?? reminder.id as String);

    await docRef.set(reminder.toFirestore() as Map<String, dynamic>);
    return docRef.id;
  }

  static Future<void> deleteReminder(String userId, String firebaseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(firebaseId)
        .delete();
  }

  // ==================== EXPENSES ====================

  static Future<String> pushExpense(dynamic expense) async {
    final docRef = _firestore
        .collection('users')
        .doc(expense.userId as String)
        .collection('expenses')
        .doc(expense.firebaseId ?? expense.id as String);

    await docRef.set(expense.toFirestore() as Map<String, dynamic>);
    return docRef.id;
  }

  static Future<void> deleteExpense(String userId, String firebaseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(firebaseId)
        .delete();
  }

  // ==================== USER DATA ====================

  static Future<void> deleteUserData(String userId) async {
    // Delete all collections for a user
    final batch = _firestore.batch();

    // Delete vehicles
    final vehicles = await _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .get();
    for (final doc in vehicles.docs) {
      batch.delete(doc.reference);
    }

    // Delete service entries
    final serviceEntries = await _firestore
        .collection('users')
        .doc(userId)
        .collection('service_entries')
        .get();
    for (final doc in serviceEntries.docs) {
      batch.delete(doc.reference);
    }

    // Delete fuel entries
    final fuelEntries = await _firestore
        .collection('users')
        .doc(userId)
        .collection('fuel_entries')
        .get();
    for (final doc in fuelEntries.docs) {
      batch.delete(doc.reference);
    }

    // Delete reminders
    final reminders = await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .get();
    for (final doc in reminders.docs) {
      batch.delete(doc.reference);
    }

    // Delete expenses
    final expenses = await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();
    for (final doc in expenses.docs) {
      batch.delete(doc.reference);
    }

    // Delete user document
    batch.delete(_firestore.collection('users').doc(userId));

    await batch.commit();
  }

  // ==================== PULL SYNC ====================

  static Future<List<Map<String, dynamic>>> pullVehicles(
    String userId,
    DateTime? lastSyncTime,
  ) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles');

    if (lastSyncTime != null) {
      query = query.where('updatedAt',
          isGreaterThan: Timestamp.fromDate(lastSyncTime));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id})
        .toList();
  }

  static Future<List<Map<String, dynamic>>> pullServiceEntries(
    String userId,
    DateTime? lastSyncTime,
  ) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('service_entries');

    if (lastSyncTime != null) {
      query = query.where('updatedAt',
          isGreaterThan: Timestamp.fromDate(lastSyncTime));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id})
        .toList();
  }

  static Future<List<Map<String, dynamic>>> pullFuelEntries(
    String userId,
    DateTime? lastSyncTime,
  ) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('fuel_entries');

    if (lastSyncTime != null) {
      query = query.where('updatedAt',
          isGreaterThan: Timestamp.fromDate(lastSyncTime));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id})
        .toList();
  }

  static Future<List<Map<String, dynamic>>> pullReminders(
    String userId,
    DateTime? lastSyncTime,
  ) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders');

    if (lastSyncTime != null) {
      query = query.where('updatedAt',
          isGreaterThan: Timestamp.fromDate(lastSyncTime));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id})
        .toList();
  }

  static Future<List<Map<String, dynamic>>> pullExpenses(
    String userId,
    DateTime? lastSyncTime,
  ) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses');

    if (lastSyncTime != null) {
      query = query.where('updatedAt',
          isGreaterThan: Timestamp.fromDate(lastSyncTime));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id})
        .toList();
  }
}
