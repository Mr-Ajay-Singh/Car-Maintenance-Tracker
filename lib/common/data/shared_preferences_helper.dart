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
  static const String _keyCurrency = 'currency';
  static const String _keyVolumeUnit = 'volumeUnit';
  static const String _keyDistanceUnit = 'distanceUnit';
  static const String _keyOnboardingCompleted = 'onboardingCompleted';

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

  // ==================== USER PREFERENCES ====================

  /// Get currency preference (default: USD)
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency) ?? 'USD';
  }

  /// Set currency preference
  static Future<bool> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyCurrency, currency);
  }

  /// Get volume unit preference (default: L for Liters)
  static Future<String> getVolumeUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVolumeUnit) ?? 'L';
  }

  /// Set volume unit preference
  static Future<bool> setVolumeUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyVolumeUnit, unit);
  }

  /// Get distance unit preference (default: km)
  static Future<String> getDistanceUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDistanceUnit) ?? 'km';
  }

  /// Set distance unit preference
  static Future<bool> setDistanceUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyDistanceUnit, unit);
  }

  // ==================== ONBOARDING ====================

  /// Check if onboarding has been completed
  static Future<bool> getOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Set onboarding completion status
  static Future<bool> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyOnboardingCompleted, completed);
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
    // Note: We keep user preferences (currency, volume unit, etc.) even after logout
  }

  // ==================== UTILITY METHODS ====================

  /// Check if user data exists (user has signed in before)
  static Future<bool> hasUserData() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }

  // ==================== GENERIC METHODS ====================
  // These methods provide generic access to SharedPreferences for Settings and other features

  /// Get a string value by key
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Set a string value by key
  static Future<bool> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  /// Get an integer value by key
  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// Set an integer value by key
  static Future<bool> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(key, value);
  }

  /// Get a boolean value by key
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Set a boolean value by key
  static Future<bool> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(key, value);
  }

  /// Get a double value by key
  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  /// Set a double value by key
  static Future<bool> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble(key, value);
  }

  /// Remove a value by key
  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  /// Clear all SharedPreferences data
  static Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  /// Check if a key exists
  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
