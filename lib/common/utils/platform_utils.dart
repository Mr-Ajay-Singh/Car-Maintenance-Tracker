import 'dart:io';

/// Platform detection utilities
class PlatformUtils {
  /// Check if the current platform is iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if the current platform is Android
  static bool get isAndroid => Platform.isAndroid;

  /// Check if the current platform is Web
  static bool get isWeb => identical(0, 0.0); // Simple web detection

  /// Check if Apple Sign-In is available (iOS only)
  static bool get isAppleSignInAvailable => isIOS;
}
