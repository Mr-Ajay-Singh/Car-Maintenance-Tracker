import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RevenueCatConfig {
  static const String apiKeyAndroid = 'goog_jHOOxYAnPdwigoJPTqmjSbnHojp';
  static const String apiKeyIOS = 'appl_otfrLIfyfMbYXZJgyaBfrDVmHbG';
  static const String entitlementId = 'Premium';
}

class RevenueCatUtils {
  static Future<void> initialize() async {
    try {
      PurchasesConfiguration configuration;

      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(RevenueCatConfig.apiKeyAndroid);
          null;
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(RevenueCatConfig.apiKeyIOS)
          ..appUserID = null;
      } else {
        debugPrint('RevenueCat: Unsupported platform');
        return;
      }

      await Purchases.configure(configuration);
      await Purchases.setLogLevel(LogLevel.debug);
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
    }
  }


  static Future<bool> isPremiumActive() async {
    // return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_premium') ?? false;
  }

  static Future<void> syncPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final hasEntitlement = customerInfo.entitlements.all[RevenueCatConfig.entitlementId]?.isActive ?? false;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('is_premium', hasEntitlement);

      // Priority 1: Try to show rating dialog first (for all users)
      bool ratingShown = await _showRatingIfEligible();

      // Priority 2: If rating was not shown and user is not premium, show paywall
      if (!ratingShown && !hasEntitlement) {
        await showPaywall();
      }
    } catch (e) {
      debugPrint('Error syncing RevenueCat premium status: $e');
    }
  }

  /// Shows rating dialog only if user hasn't rated yet or based on specific criteria
  /// Returns true if rating dialog was shown, false otherwise
  static Future<bool> _showRatingIfEligible() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const String hasRatedKey = 'has_rated_app';

      // Check if user has already rated the app
      bool hasRated = prefs.getBool(hasRatedKey) ?? false;

      if (!hasRated) {
        final InAppReview inAppReview = InAppReview.instance;

        if (await inAppReview.isAvailable()) {
          debugPrint('Showing rating dialog');
          await inAppReview.requestReview();

          // Mark as rated to avoid showing again
          await prefs.setBool(hasRatedKey, true);
          return true; // Rating was shown
        }
      } else {
        debugPrint('User has already rated the app, skipping rating dialog');
      }
      return false; // Rating was not shown
    } catch (e) {
      debugPrint('Error showing rating dialog: $e');
      return false;
    }
  }


  static Future<PaywallResult?> showPaywall() async {
    try {

      await Future.delayed(const Duration(milliseconds: 300));

      final PaywallResult paywallResult;

      paywallResult = await RevenueCatUI.presentPaywallIfNeeded(RevenueCatConfig.entitlementId);

      if (paywallResult case PaywallResult.purchased) {
        await syncPremiumStatus();
        // MixpanelUtils.track('purchase_success');
      } else if (paywallResult case PaywallResult.restored) {
        await syncPremiumStatus();
      }
      return paywallResult;
    } catch (e) {
      debugPrint('Error showing paywall: $e');
      return null;
    }
  }

  /// Tracks app openings and shows in-app review dialog at specific intervals:
  /// - 3rd, 6th, 10th, 14th opening
  /// - After 14th: every 5th opening (19th, 24th, 29th, etc.)
  static Future<void> checkAndShowReviewDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const String appOpenCountKey = 'app_open_count';

      // Increment app open count
      int appOpenCount = (prefs.getInt(appOpenCountKey) ?? 0) + 1;
      await prefs.setInt(appOpenCountKey, appOpenCount);

      debugPrint('App opened $appOpenCount times');

      // Determine if we should show review dialog
      bool shouldShowReview = false;

      if (appOpenCount == 3 || appOpenCount == 6 || appOpenCount == 10 || appOpenCount == 14) {
        // Show at specific milestones: 3rd, 6th, 10th, 14th opening
        shouldShowReview = true;
      } else if (appOpenCount > 14 && (appOpenCount - 14) % 5 == 0) {
        // After 14th opening, show every 5th opening (19th, 24th, 29th, etc.)
        shouldShowReview = true;
      }

      if (shouldShowReview) {
        final InAppReview inAppReview = InAppReview.instance;

        // Check if review is available on this platform
        if (await inAppReview.isAvailable()) {
          debugPrint('Requesting in-app review (opening #$appOpenCount)');
          await inAppReview.requestReview();
        } else {
          debugPrint('In-app review not available on this platform');
        }
      }
    } catch (e) {
      debugPrint('Error checking/showing review dialog: $e');
    }
  }


}
