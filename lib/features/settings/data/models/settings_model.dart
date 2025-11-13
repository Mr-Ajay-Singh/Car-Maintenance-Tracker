import 'package:flutter/material.dart';

/// SettingsModel - Data model for app settings and preferences
/// Stored in SharedPreferences (device-specific, not synced to cloud)
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
  static const String keyPromotionalNotifications =
      'settings_promotionalNotifications';
  static const String keyNotificationSound = 'settings_notificationSound';
  static const String keyVibrationEnabled = 'settings_vibrationEnabled';
  static const String keySyncMode = 'settings_syncMode';
  static const String keyAutoBackup = 'settings_autoBackup';
  static const String keyLastSyncTime = 'settings_lastSyncTime';
  static const String keyCloudBackupEnabled = 'settings_cloudBackupEnabled';
  static const String keyAnalyticsEnabled = 'settings_analyticsEnabled';
  static const String keyCrashReportingEnabled =
      'settings_crashReportingEnabled';
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
      reminderNotifications:
          reminderNotifications ?? this.reminderNotifications,
      syncNotifications: syncNotifications ?? this.syncNotifications,
      promotionalNotifications:
          promotionalNotifications ?? this.promotionalNotifications,
      notificationSound: notificationSound ?? this.notificationSound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      syncMode: syncMode ?? this.syncMode,
      autoBackup: autoBackup ?? this.autoBackup,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      cloudBackupEnabled: cloudBackupEnabled ?? this.cloudBackupEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled:
          crashReportingEnabled ?? this.crashReportingEnabled,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      showOnboarding: showOnboarding ?? this.showOnboarding,
    );
  }
}

// ==================== ENUMS ====================

/// DistanceUnit - Unit for distance/odometer measurements
enum DistanceUnit {
  km,
  miles;

  String get displayName => this == km ? 'Kilometers' : 'Miles';
  String get abbreviation => this == km ? 'km' : 'mi';
}

/// VolumeUnit - Unit for fuel volume measurements
enum VolumeUnit {
  liters,
  gallons;

  String get displayName => this == liters ? 'Liters' : 'Gallons';
  String get abbreviation => this == liters ? 'L' : 'gal';
}

/// SyncMode - Cloud synchronization mode
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
