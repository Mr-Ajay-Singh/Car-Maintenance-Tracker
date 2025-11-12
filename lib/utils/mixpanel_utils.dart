import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// A utility class for Mixpanel analytics integration
class MixpanelUtils {
  static Mixpanel? _instance;
  static const String _mixpanelToken = ""; // Replace with your actual token
  
  /// Initialize the Mixpanel instance
  static Future<void> init() async {
    if (_instance != null) return;
    
    try {
      _instance = await Mixpanel.init(_mixpanelToken, 
        optOutTrackingDefault: false,
        trackAutomaticEvents: true
      );
      
      debugPrint('Mixpanel initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Mixpanel: $e');
    }
  }
  
  /// Track a custom event with optional properties
  static void track(String eventName, {Map<String, dynamic>? properties}) {
    if (_instance == null) {
      debugPrint('Mixpanel not initialized, skipping event: $eventName');
      return;
    }
    
    try {
      _instance!.track(eventName, properties: properties);
      if (kDebugMode) {
        _instance?.flush();
        debugPrint('Tracked event: $eventName');
      }
    } catch (e) {
      debugPrint('Failed to track event $eventName: $e');
    }
  }

  static void trackEventForClick(String eventName, String clickName) {
    if (_instance == null) {
      debugPrint('Mixpanel not initialized, skipping event: $eventName');
      return;
    }
    track(eventName, properties: {'click': clickName});
  }

  static void trackEventForOpen(String eventName) {
    if (_instance == null) {
      debugPrint('Mixpanel not initialized, skipping event: $eventName');
      return;
    }
    track(eventName, properties: {'open_page': true});
  }
  
  /// Set user profile properties
  static void setUserProfile(String userId, {Map<String, dynamic>? properties}) {
    if (_instance == null) {
      debugPrint('Mixpanel not initialized, skipping set user: $userId');
      return;
    }
    
    try {
      _instance!.identify(userId);
      
      if (properties != null && properties.isNotEmpty) {
        properties.forEach((key, value) {
          _instance!.getPeople().set(key, value);
        });
      }
      
      debugPrint('Set user profile: $userId');
    } catch (e) {
      debugPrint('Failed to set user profile $userId: $e');
    }
  }
  
  /// Reset the current user profile
  static void reset() {
    if (_instance == null) {
      debugPrint('Mixpanel not initialized, skipping reset');
      return;
    }
    
    try {
      _instance!.reset();
      debugPrint('Reset user profile');
    } catch (e) {
      debugPrint('Failed to reset user profile: $e');
    }
  }
  
  /// Track screen view
  static void trackScreen(String screenName) {
    track('Screen View', properties: {'screen_name': screenName});
  }
  
  /// Enable or disable tracking for GDPR compliance
  static void setOptOutTracking(bool optOut) {
    if (_instance == null) {
      debugPrint('Mixpanel not initialized, skipping opt out');
      return;
    }
    
    try {
      if (optOut) {
        _instance!.optOutTracking();
      } else {
        _instance!.optInTracking();
      }
      debugPrint('Set opt out tracking: $optOut');
    } catch (e) {
      debugPrint('Failed to set opt out tracking: $e');
    }
  }
} 