import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferencesHelper - Static class for all key-value operations
///
/// Centralized access to SharedPreferences for consistent data storage
/// Following CLAUDE.md guidelines: All shared preferences operations must go through this class
class SharedPreferencesHelper {
  // ==================== KEYS ====================

  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyIsFirstSignIn = 'isFirstSignIn';
  static const String _keyLastSyncTimestamp = 'lastSyncTimestamp';
  static const String _keyFirstSyncCompleted = 'firstSyncCompleted';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  // ==================== USER ID ====================

  /// Get Firebase user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Set Firebase user ID
  static Future<bool> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserId, userId);
  }

  /// Clear user ID (on logout)
  static Future<bool> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyUserId);
  }

  // ==================== USER EMAIL ====================

  /// Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Set user email
  static Future<bool> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserEmail, email);
  }

  // ==================== FIRST SIGN-IN TRACKING ====================

  /// Check if this is user's first sign-in
  static Future<bool> getIsFirstSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstSignIn) ?? true; // Default to true
  }

  /// Set first sign-in flag
  static Future<bool> setIsFirstSignIn(bool isFirst) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyIsFirstSignIn, isFirst);
  }

  // ==================== SYNC TRACKING ====================

  /// Get last sync timestamp
  static Future<String?> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSyncTimestamp);
  }

  /// Set last sync timestamp
  static Future<bool> setLastSyncTimestamp(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyLastSyncTimestamp, timestamp);
  }

  /// Check if first sync has been completed
  static Future<bool> getFirstSyncCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstSyncCompleted) ?? false;
  }

  /// Mark first sync as completed
  static Future<bool> setFirstSyncCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyFirstSyncCompleted, completed);
  }

  // ==================== LOGIN STATE ====================

  /// Check if user is logged in
  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Set login state
  static Future<bool> setIsLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  // ==================== CLEAR ALL ====================

  /// Clear all user data (on logout)
  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyIsFirstSignIn);
    await prefs.remove(_keyLastSyncTimestamp);
    await prefs.remove(_keyFirstSyncCompleted);
    await prefs.remove(_keyIsLoggedIn);
  }

  // ==================== UTILITY METHODS ====================

  /// Check if user data exists (user has signed in before)
  static Future<bool> hasUserData() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }
}
