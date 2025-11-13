import 'package:flutter/material.dart';
import '../../../common/data/database_helper.dart';
import '../../../common/data/firestore_helper.dart';
import '../../../common/data/shared_preferences_helper.dart';
import '../data/models/settings_model.dart';

/// SettingsService - Service class for app settings and preferences management
class SettingsService {
  // LOAD SETTINGS
  Future<SettingsModel> loadSettings(String userId) async {
    return SettingsModel(
      userId: await SharedPreferencesHelper.getString(SettingsModel.keyUserId) ??
          userId,
      displayName:
          await SharedPreferencesHelper.getString(SettingsModel.keyDisplayName),
      email: await SharedPreferencesHelper.getString(SettingsModel.keyEmail),
      profilePhotoUrl: await SharedPreferencesHelper.getString(
          SettingsModel.keyProfilePhotoUrl),
      themeMode: _parseThemeMode(
          await SharedPreferencesHelper.getString(SettingsModel.keyThemeMode)),
      language:
          await SharedPreferencesHelper.getString(SettingsModel.keyLanguage) ??
              'en',
      distanceUnit: _parseDistanceUnit(await SharedPreferencesHelper.getString(
          SettingsModel.keyDistanceUnit)),
      volumeUnit: _parseVolumeUnit(await SharedPreferencesHelper.getString(
          SettingsModel.keyVolumeUnit)),
      currency:
          await SharedPreferencesHelper.getString(SettingsModel.keyCurrency) ??
              'USD',
      notificationsEnabled: await SharedPreferencesHelper.getBool(
              SettingsModel.keyNotificationsEnabled) ??
          true,
      reminderNotifications: await SharedPreferencesHelper.getBool(
              SettingsModel.keyReminderNotifications) ??
          true,
      syncNotifications: await SharedPreferencesHelper.getBool(
              SettingsModel.keySyncNotifications) ??
          false,
      promotionalNotifications: await SharedPreferencesHelper.getBool(
              SettingsModel.keyPromotionalNotifications) ??
          false,
      notificationSound: await SharedPreferencesHelper.getString(
              SettingsModel.keyNotificationSound) ??
          'default',
      vibrationEnabled: await SharedPreferencesHelper.getBool(
              SettingsModel.keyVibrationEnabled) ??
          true,
      syncMode: _parseSyncMode(
          await SharedPreferencesHelper.getString(SettingsModel.keySyncMode)),
      autoBackup:
          await SharedPreferencesHelper.getBool(SettingsModel.keyAutoBackup) ??
              true,
      lastSyncTime: _parseDateTime(
          await SharedPreferencesHelper.getString(SettingsModel.keyLastSyncTime)),
      cloudBackupEnabled: await SharedPreferencesHelper.getBool(
              SettingsModel.keyCloudBackupEnabled) ??
          true,
      analyticsEnabled: await SharedPreferencesHelper.getBool(
              SettingsModel.keyAnalyticsEnabled) ??
          true,
      crashReportingEnabled: await SharedPreferencesHelper.getBool(
              SettingsModel.keyCrashReportingEnabled) ??
          true,
      dataSharingEnabled: await SharedPreferencesHelper.getBool(
              SettingsModel.keyDataSharingEnabled) ??
          false,
      biometricLockEnabled: await SharedPreferencesHelper.getBool(
              SettingsModel.keyBiometricLockEnabled) ??
          false,
      autoLockTimeout: await SharedPreferencesHelper.getInt(
              SettingsModel.keyAutoLockTimeout) ??
          0,
      showOnboarding: await SharedPreferencesHelper.getBool(
              SettingsModel.keyShowOnboarding) ??
          true,
    );
  }

  // SAVE SETTINGS
  Future<void> saveSettings(SettingsModel settings) async {
    final map = settings.toMap();
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is String) {
        await SharedPreferencesHelper.setString(entry.key, value);
      } else if (value is bool) {
        await SharedPreferencesHelper.setBool(entry.key, value);
      } else if (value is int) {
        await SharedPreferencesHelper.setInt(entry.key, value);
      } else if (value == null) {
        await SharedPreferencesHelper.remove(entry.key);
      }
    }
  }

  // UPDATE SPECIFIC SETTINGS
  Future<void> updateThemeMode(ThemeMode mode) async {
    await SharedPreferencesHelper.setString(SettingsModel.keyThemeMode, mode.name);
  }

  Future<void> updateLanguage(String language) async {
    await SharedPreferencesHelper.setString(SettingsModel.keyLanguage, language);
  }

  Future<void> updateDistanceUnit(DistanceUnit unit) async {
    await SharedPreferencesHelper.setString(
        SettingsModel.keyDistanceUnit, unit.name);
  }

  Future<void> updateVolumeUnit(VolumeUnit unit) async {
    await SharedPreferencesHelper.setString(
        SettingsModel.keyVolumeUnit, unit.name);
  }

  Future<void> updateCurrency(String currency) async {
    await SharedPreferencesHelper.setString(SettingsModel.keyCurrency, currency);
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    await SharedPreferencesHelper.setBool(
        SettingsModel.keyNotificationsEnabled, enabled);
  }

  Future<void> updateSyncMode(SyncMode mode) async {
    await SharedPreferencesHelper.setString(SettingsModel.keySyncMode, mode.name);
  }

  Future<void> updateLastSyncTime(DateTime time) async {
    await SharedPreferencesHelper.setString(
        SettingsModel.keyLastSyncTime, time.toIso8601String());
  }

  Future<void> updateBiometricLock(bool enabled) async {
    await SharedPreferencesHelper.setBool(
        SettingsModel.keyBiometricLockEnabled, enabled);
  }

  Future<void> updateShowOnboarding(bool show) async {
    await SharedPreferencesHelper.setBool(
        SettingsModel.keyShowOnboarding, show);
  }

  // RESET SETTINGS
  Future<void> resetSettings(String userId) async {
    final defaultSettings = SettingsModel(userId: userId);
    await saveSettings(defaultSettings);
  }

  // CLEAR ALL DATA
  Future<void> clearAllData() async {
    await SharedPreferencesHelper.clear();
  }

  // HELPER PARSERS
  ThemeMode _parseThemeMode(String? value) {
    if (value == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  DistanceUnit _parseDistanceUnit(String? value) {
    if (value == null) return DistanceUnit.km;
    return DistanceUnit.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DistanceUnit.km,
    );
  }

  VolumeUnit _parseVolumeUnit(String? value) {
    if (value == null) return VolumeUnit.liters;
    return VolumeUnit.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VolumeUnit.liters,
    );
  }

  SyncMode _parseSyncMode(String? value) {
    if (value == null) return SyncMode.auto;
    return SyncMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncMode.auto,
    );
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  // ACCOUNT ACTIONS
  /// Delete all user data from local database and cloud
  /// TODO: Integrate with Firebase Auth when package is added
  Future<void> deleteAccount(String userId) async {
    // Delete all local data
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteAllUserData(userId);

    // Delete from Firestore
    await FirestoreHelper.deleteUserData(userId);

    // Clear settings
    await clearAllData();

    // Delete Firebase Auth account
    // TODO: Uncomment when firebase_auth is added to pubspec.yaml
    // await FirebaseAuth.instance.currentUser?.delete();
    print('Account deletion: Firebase Auth integration pending');
  }

  /// Export all user data
  /// TODO: Implement full data export functionality
  Future<void> exportAllData(String userId) async {
    // Export logic handled by data_export feature
    print('Exporting all data for user: $userId');
    // TODO: Implement CSV/JSON export for all user data
  }

  // BIOMETRIC AUTH
  /// Check if device supports biometric authentication
  /// TODO: Integrate with local_auth package
  Future<bool> isBiometricsAvailable() async {
    // Check if device supports biometrics
    try {
      // TODO: Uncomment when local_auth is added to pubspec.yaml
      // final localAuth = LocalAuthentication();
      // return await localAuth.canCheckBiometrics;
      print('Biometric check: local_auth package integration pending');
      return false; // Placeholder
    } catch (e) {
      return false;
    }
  }

  /// Authenticate using biometrics (fingerprint, face ID)
  /// TODO: Integrate with local_auth package
  Future<bool> authenticateWithBiometrics() async {
    try {
      // TODO: Uncomment when local_auth is added to pubspec.yaml
      // final localAuth = LocalAuthentication();
      // return await localAuth.authenticate(
      //   localizedReason: 'Authenticate to access your vehicle data',
      //   options: const AuthenticationOptions(
      //     useErrorDialogs: true,
      //     stickyAuth: true,
      //   ),
      // );
      print('Biometric auth: local_auth package integration pending');
      return false; // Placeholder
    } catch (e) {
      return false;
    }
  }
}
