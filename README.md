# Fiber Tracker

A Flutter application for tracking Fiber intake and fitness data.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Analytics Integration

This app uses Mixpanel for analytics tracking. Key features include:

- User engagement tracking
- Screen view analytics
- Premium conversion tracking
- Trial usage metrics

### Setting up Mixpanel

1. Get your Mixpanel project token from the Mixpanel dashboard
2. Replace the token in `lib/utils/mixpanel_utils.dart`
3. Analytics will be automatically captured for key app events

### Available Analytics Methods

The `MixpanelUtils` class provides these static methods:

- `init()` - Initialize Mixpanel
- `track(eventName, {properties})` - Track custom events
- `setUserProfile(userId, {properties})` - Set user profile data
- `reset()` - Reset user identity
- `trackScreen(screenName)` - Track screen views
- `setOptOutTracking(optOut)` - Enable/disable tracking for GDPR compliance
