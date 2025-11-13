# Settings Feature - Implementation Plan

## Feature Overview
The Settings feature provides users with control over app preferences, account management, data synchronization, notifications, theme customization, units configuration, privacy controls, and app information. This feature serves as the central hub for app configuration.

## Architecture
Following CLAUDE.md guidelines:
- **Data Layer**: Settings model stored in Shared Preferences
- **Service Layer**: Business logic for settings management
- **Presentation Layer**: UI components (implemented in UI.md)

---

## Data Layer

### Settings Model

**File**: `lib/features/settings/data/models/settings_model.dart`

```dart
class SettingsModel {
  // Account Settings
  final String userId;
  final String? displayName;
  final String? email;
  final String? profilePhotoUrl;

  // App Preferences
  final ThemeMode themeMode; // light, dark, system
  final String language; // en, es, fr, etc.

  // Units
  final DistanceUnit distanceUnit; // km or miles
  final VolumeUnit volumeUnit; // liters or gallons
  final String currency; // USD, EUR, GBP, etc.

  // Notification Settings
  final bool notificationsEnabled;
  final bool reminderNotifications;
  final bool syncNotifications;
  final bool promotionalNotifications;
  final String notificationSound;
  final bool vibrationEnabled;

  // Sync Settings
  final SyncMode syncMode; // auto, manual, wifiOnly
  final bool autoBackup;
  final DateTime? lastSyncTime;
  final bool cloudBackupEnabled;

  // Privacy Settings
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool dataSharingEnabled;

  // App Settings
  final bool biometricLockEnabled;
  final int autoLockTimeout; // minutes, 0 = never
  final bool showOnboarding;

  SettingsModel({
    required this.userId,
    this.displayName,
    this.email,
    this.profilePhotoUrl,
    this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.distanceUnit = DistanceUnit.km,
    this.volumeUnit = VolumeUnit.liters,
    this.currency = 'USD',
    this.notificationsEnabled = true,
    this.reminderNotifications = true,
    this.syncNotifications = false,
    this.promotionalNotifications = false,
    this.notificationSound = 'default',
    this.vibrationEnabled = true,
    this.syncMode = SyncMode.auto,
    this.autoBackup = true,
    this.lastSyncTime,
    this.cloudBackupEnabled = true,
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.dataSharingEnabled = false,
    this.biometricLockEnabled = false,
    this.autoLockTimeout = 0,
    this.showOnboarding = true,
  });

  // SharedPreferences keys
  static const String keyUserId = 'settings_userId';
  static const String keyDisplayName = 'settings_displayName';
  static const String keyEmail = 'settings_email';
  static const String keyProfilePhotoUrl = 'settings_profilePhotoUrl';
  static const String keyThemeMode = 'settings_themeMode';
  static const String keyLanguage = 'settings_language';
  static const String keyDistanceUnit = 'settings_distanceUnit';
  static const String keyVolumeUnit = 'settings_volumeUnit';
  static const String keyCurrency = 'settings_currency';
  static const String keyNotificationsEnabled = 'settings_notificationsEnabled';
  static const String keyReminderNotifications = 'settings_reminderNotifications';
  static const String keySyncNotifications = 'settings_syncNotifications';
  static const String keyPromotionalNotifications = 'settings_promotionalNotifications';
  static const String keyNotificationSound = 'settings_notificationSound';
  static const String keyVibrationEnabled = 'settings_vibrationEnabled';
  static const String keySyncMode = 'settings_syncMode';
  static const String keyAutoBackup = 'settings_autoBackup';
  static const String keyLastSyncTime = 'settings_lastSyncTime';
  static const String keyCloudBackupEnabled = 'settings_cloudBackupEnabled';
  static const String keyAnalyticsEnabled = 'settings_analyticsEnabled';
  static const String keyCrashReportingEnabled = 'settings_crashReportingEnabled';
  static const String keyDataSharingEnabled = 'settings_dataSharingEnabled';
  static const String keyBiometricLockEnabled = 'settings_biometricLockEnabled';
  static const String keyAutoLockTimeout = 'settings_autoLockTimeout';
  static const String keyShowOnboarding = 'settings_showOnboarding';

  Map<String, dynamic> toMap() {
    return {
      keyUserId: userId,
      keyDisplayName: displayName,
      keyEmail: email,
      keyProfilePhotoUrl: profilePhotoUrl,
      keyThemeMode: themeMode.name,
      keyLanguage: language,
      keyDistanceUnit: distanceUnit.name,
      keyVolumeUnit: volumeUnit.name,
      keyCurrency: currency,
      keyNotificationsEnabled: notificationsEnabled,
      keyReminderNotifications: reminderNotifications,
      keySyncNotifications: syncNotifications,
      keyPromotionalNotifications: promotionalNotifications,
      keyNotificationSound: notificationSound,
      keyVibrationEnabled: vibrationEnabled,
      keySyncMode: syncMode.name,
      keyAutoBackup: autoBackup,
      keyLastSyncTime: lastSyncTime?.toIso8601String(),
      keyCloudBackupEnabled: cloudBackupEnabled,
      keyAnalyticsEnabled: analyticsEnabled,
      keyCrashReportingEnabled: crashReportingEnabled,
      keyDataSharingEnabled: dataSharingEnabled,
      keyBiometricLockEnabled: biometricLockEnabled,
      keyAutoLockTimeout: autoLockTimeout,
      keyShowOnboarding: showOnboarding,
    };
  }

  SettingsModel copyWith({
    String? userId,
    String? displayName,
    String? email,
    String? profilePhotoUrl,
    ThemeMode? themeMode,
    String? language,
    DistanceUnit? distanceUnit,
    VolumeUnit? volumeUnit,
    String? currency,
    bool? notificationsEnabled,
    bool? reminderNotifications,
    bool? syncNotifications,
    bool? promotionalNotifications,
    String? notificationSound,
    bool? vibrationEnabled,
    SyncMode? syncMode,
    bool? autoBackup,
    DateTime? lastSyncTime,
    bool? cloudBackupEnabled,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? dataSharingEnabled,
    bool? biometricLockEnabled,
    int? autoLockTimeout,
    bool? showOnboarding,
  }) {
    return SettingsModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      syncNotifications: syncNotifications ?? this.syncNotifications,
      promotionalNotifications: promotionalNotifications ?? this.promotionalNotifications,
      notificationSound: notificationSound ?? this.notificationSound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      syncMode: syncMode ?? this.syncMode,
      autoBackup: autoBackup ?? this.autoBackup,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      cloudBackupEnabled: cloudBackupEnabled ?? this.cloudBackupEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      showOnboarding: showOnboarding ?? this.showOnboarding,
    );
  }
}

// Enums
enum DistanceUnit {
  km,
  miles;

  String get displayName => this == km ? 'Kilometers' : 'Miles';
  String get abbreviation => this == km ? 'km' : 'mi';
}

enum VolumeUnit {
  liters,
  gallons;

  String get displayName => this == liters ? 'Liters' : 'Gallons';
  String get abbreviation => this == liters ? 'L' : 'gal';
}

enum SyncMode {
  auto,
  manual,
  wifiOnly;

  String get displayName {
    switch (this) {
      case auto:
        return 'Automatic';
      case manual:
        return 'Manual';
      case wifiOnly:
        return 'Wi-Fi Only';
    }
  }
}
```

---

## Service Layer

### Settings Service

**File**: `lib/features/settings/service/settings_service.dart`

```dart
class SettingsService {
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  // LOAD SETTINGS
  Future<SettingsModel> loadSettings(String userId) async {
    return SettingsModel(
      userId: await _prefsHelper.getString(SettingsModel.keyUserId) ?? userId,
      displayName: await _prefsHelper.getString(SettingsModel.keyDisplayName),
      email: await _prefsHelper.getString(SettingsModel.keyEmail),
      profilePhotoUrl: await _prefsHelper.getString(SettingsModel.keyProfilePhotoUrl),
      themeMode: _parseThemeMode(await _prefsHelper.getString(SettingsModel.keyThemeMode)),
      language: await _prefsHelper.getString(SettingsModel.keyLanguage) ?? 'en',
      distanceUnit: _parseDistanceUnit(await _prefsHelper.getString(SettingsModel.keyDistanceUnit)),
      volumeUnit: _parseVolumeUnit(await _prefsHelper.getString(SettingsModel.keyVolumeUnit)),
      currency: await _prefsHelper.getString(SettingsModel.keyCurrency) ?? 'USD',
      notificationsEnabled: await _prefsHelper.getBool(SettingsModel.keyNotificationsEnabled) ?? true,
      reminderNotifications: await _prefsHelper.getBool(SettingsModel.keyReminderNotifications) ?? true,
      syncNotifications: await _prefsHelper.getBool(SettingsModel.keySyncNotifications) ?? false,
      promotionalNotifications: await _prefsHelper.getBool(SettingsModel.keyPromotionalNotifications) ?? false,
      notificationSound: await _prefsHelper.getString(SettingsModel.keyNotificationSound) ?? 'default',
      vibrationEnabled: await _prefsHelper.getBool(SettingsModel.keyVibrationEnabled) ?? true,
      syncMode: _parseSyncMode(await _prefsHelper.getString(SettingsModel.keySyncMode)),
      autoBackup: await _prefsHelper.getBool(SettingsModel.keyAutoBackup) ?? true,
      lastSyncTime: _parseDateTime(await _prefsHelper.getString(SettingsModel.keyLastSyncTime)),
      cloudBackupEnabled: await _prefsHelper.getBool(SettingsModel.keyCloudBackupEnabled) ?? true,
      analyticsEnabled: await _prefsHelper.getBool(SettingsModel.keyAnalyticsEnabled) ?? true,
      crashReportingEnabled: await _prefsHelper.getBool(SettingsModel.keyCrashReportingEnabled) ?? true,
      dataSharingEnabled: await _prefsHelper.getBool(SettingsModel.keyDataSharingEnabled) ?? false,
      biometricLockEnabled: await _prefsHelper.getBool(SettingsModel.keyBiometricLockEnabled) ?? false,
      autoLockTimeout: await _prefsHelper.getInt(SettingsModel.keyAutoLockTimeout) ?? 0,
      showOnboarding: await _prefsHelper.getBool(SettingsModel.keyShowOnboarding) ?? true,
    );
  }

  // SAVE SETTINGS
  Future<void> saveSettings(SettingsModel settings) async {
    final map = settings.toMap();
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is String) {
        await _prefsHelper.setString(entry.key, value);
      } else if (value is bool) {
        await _prefsHelper.setBool(entry.key, value);
      } else if (value is int) {
        await _prefsHelper.setInt(entry.key, value);
      } else if (value == null) {
        await _prefsHelper.remove(entry.key);
      }
    }
  }

  // UPDATE SPECIFIC SETTINGS
  Future<void> updateThemeMode(ThemeMode mode) async {
    await _prefsHelper.setString(SettingsModel.keyThemeMode, mode.name);
  }

  Future<void> updateLanguage(String language) async {
    await _prefsHelper.setString(SettingsModel.keyLanguage, language);
  }

  Future<void> updateDistanceUnit(DistanceUnit unit) async {
    await _prefsHelper.setString(SettingsModel.keyDistanceUnit, unit.name);
  }

  Future<void> updateVolumeUnit(VolumeUnit unit) async {
    await _prefsHelper.setString(SettingsModel.keyVolumeUnit, unit.name);
  }

  Future<void> updateCurrency(String currency) async {
    await _prefsHelper.setString(SettingsModel.keyCurrency, currency);
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    await _prefsHelper.setBool(SettingsModel.keyNotificationsEnabled, enabled);
  }

  Future<void> updateSyncMode(SyncMode mode) async {
    await _prefsHelper.setString(SettingsModel.keySyncMode, mode.name);
  }

  Future<void> updateLastSyncTime(DateTime time) async {
    await _prefsHelper.setString(SettingsModel.keyLastSyncTime, time.toIso8601String());
  }

  Future<void> updateBiometricLock(bool enabled) async {
    await _prefsHelper.setBool(SettingsModel.keyBiometricLockEnabled, enabled);
  }

  Future<void> updateShowOnboarding(bool show) async {
    await _prefsHelper.setBool(SettingsModel.keyShowOnboarding, show);
  }

  // RESET SETTINGS
  Future<void> resetSettings(String userId) async {
    final defaultSettings = SettingsModel(userId: userId);
    await saveSettings(defaultSettings);
  }

  // CLEAR ALL DATA
  Future<void> clearAllData() async {
    await _prefsHelper.clear();
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
  Future<void> deleteAccount(String userId) async {
    // Delete all local data
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteAllUserData(userId);

    // Delete from Firestore
    await FirestoreHelper.deleteUserData(userId);

    // Clear settings
    await clearAllData();

    // Delete Firebase Auth account
    await FirebaseAuth.instance.currentUser?.delete();
  }

  Future<void> exportAllData(String userId) async {
    // Export logic handled by data_export feature
    print('Exporting all data for user: $userId');
  }

  // BIOMETRIC AUTH
  Future<bool> isBiometricsAvailable() async {
    // Check if device supports biometrics
    try {
      final localAuth = LocalAuthentication();
      return await localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final localAuth = LocalAuthentication();
      return await localAuth.authenticate(
        localizedReason: 'Authenticate to access your vehicle data',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

---

## Implementation Checklist

- [ ] Create SettingsModel with all configuration fields
- [ ] Create unit enums (DistanceUnit, VolumeUnit, SyncMode)
- [ ] Create SettingsService for managing preferences
- [ ] Integrate with SharedPreferencesHelper
- [ ] Implement theme mode switching
- [ ] Implement unit conversion helpers
- [ ] Implement notification preferences
- [ ] Implement sync mode management
- [ ] Implement biometric authentication
- [ ] Implement data export/deletion
- [ ] Test settings persistence
- [ ] Test biometric authentication

---

## Notes

- Settings stored in SharedPreferences (not SQLite or Firestore)
- Theme mode changes apply immediately app-wide
- Unit preferences affect display throughout app
- Biometric lock optional for added security
- Delete account removes all user data (local + cloud)
- Settings not synced to cloud (device-specific)
