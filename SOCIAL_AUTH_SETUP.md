# Social Authentication Setup Guide

This guide will help you configure Google Sign-In and Apple Sign-In for the Car Maintenance Tracker app.

## Prerequisites

- Firebase project with Authentication enabled
- Google Cloud Console access (for Google Sign-In)
- Apple Developer account (for Apple Sign-In on iOS)
- Xcode (for iOS configuration)
- Android Studio (for Android configuration)

---

## Firebase Console Configuration

### 1. Enable Google Sign-In

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Toggle **Enable**
6. Set a **Project support email**
7. Click **Save**

### 2. Enable Apple Sign-In (iOS only)

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Apple** provider
3. Toggle **Enable**
4. You'll need to configure this further in Apple Developer portal (see iOS Setup below)
5. Click **Save**

---

## iOS Configuration

### 1. Enable Sign in with Apple Capability

1. Open your project in Xcode
2. Select your app target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and add **Sign in with Apple**

### 2. Configure Apple Developer Portal

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** → Your App ID
4. Enable **Sign in with Apple** capability
5. Click **Save**

### 3. Create Service ID (for Firebase)

1. In Apple Developer Portal, go to **Identifiers**
2. Click **+** to create a new identifier
3. Select **Services IDs** and click **Continue**
4. Enter a description and identifier (e.g., `com.yourapp.firebase`)
5. Enable **Sign in with Apple**
6. Click **Configure** next to Sign in with Apple
7. Add your Firebase OAuth redirect URL:
   - Format: `https://YOUR_PROJECT_ID.firebaseapp.com/__/auth/handler`
   - Get YOUR_PROJECT_ID from Firebase Console → Project Settings
8. Click **Save** and **Continue**

### 4. Update Firebase with Apple Credentials

1. Go back to Firebase Console → Authentication → Sign-in method → Apple
2. Enter your **Service ID** from step 3
3. Upload your **Apple Team ID** (found in Apple Developer Portal membership)
4. Click **Save**

### 5. Update Info.plist (if needed)

The `sign_in_with_apple` package should handle this automatically, but verify that your `Info.plist` doesn't block the authentication flow.

---

## Android Configuration

### 1. Get SHA-1 Fingerprint

For **Debug** builds:
```bash
cd android
./gradlew signingReport
```

Look for the **SHA-1** fingerprint under the `debug` variant.

For **Release** builds, you'll need the SHA-1 from your release keystore:
```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

### 2. Add SHA-1 to Firebase

1. Go to Firebase Console → Project Settings
2. Scroll down to **Your apps** section
3. Select your Android app
4. Click **Add fingerprint**
5. Paste your SHA-1 fingerprint
6. Click **Save**

### 3. Download Updated google-services.json

1. After adding SHA-1, download the updated `google-services.json`
2. Replace the existing file in `android/app/google-services.json`

### 4. Verify Google Sign-In Configuration

Ensure your `android/app/build.gradle` has:
```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.0.0')
    implementation 'com.google.firebase:firebase-auth'
}
```

And your `android/build.gradle` has:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

---

## Testing

### Test on iOS Simulator

> [!NOTE]
> Apple Sign-In requires a real iOS device for full testing. The simulator may not work properly.

1. Run the app: `flutter run -d <ios-device>`
2. Navigate to Login/Signup page
3. Verify both Google and Apple Sign-In buttons are visible
4. Test Google Sign-In flow
5. Test Apple Sign-In flow (on real device)

### Test on Android Emulator/Device

1. Run the app: `flutter run -d <android-device>`
2. Navigate to Login/Signup page
3. Verify only Google Sign-In button is visible (Apple button should NOT appear)
4. Test Google Sign-In flow

---

## Troubleshooting

### Google Sign-In Issues

**Error: "PlatformException(sign_in_failed)"**
- Verify SHA-1 fingerprint is added to Firebase Console
- Ensure `google-services.json` is up to date
- Check that Google Sign-In is enabled in Firebase Authentication

**Error: "ApiException: 10"**
- SHA-1 fingerprint mismatch
- Re-download `google-services.json` after adding SHA-1

**Error: "DEVELOPER_ERROR"**
- OAuth client ID not configured properly
- Verify Firebase project configuration

### Apple Sign-In Issues

**Error: "Sign in with Apple is not available"**
- Verify you're testing on a real iOS device (not simulator)
- Check that Sign in with Apple capability is enabled in Xcode
- Ensure iOS version is 13.0 or higher

**Error: "Invalid client"**
- Service ID not configured correctly in Apple Developer Portal
- Verify redirect URL matches Firebase OAuth handler URL

**User cancels sign-in**
- This is expected behavior - the app should handle gracefully

### General Issues

**Error: "No user logged in" after successful sign-in**
- Check that user data is being saved to SharedPreferences
- Verify Firebase user object is not null
- Check network connectivity

**Sync not working after social sign-in**
- Verify `isFirstSignIn` flag is set correctly for new users
- Check Firestore rules allow authenticated users to read/write

---

## Security Best Practices

1. **Never commit** `google-services.json` or `GoogleService-Info.plist` to public repositories
2. **Use environment-specific** Firebase projects (dev, staging, production)
3. **Enable App Check** in Firebase for additional security
4. **Review Firestore security rules** to ensure proper access control
5. **Monitor authentication** in Firebase Console for suspicious activity

---

## Additional Resources

- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple for Flutter](https://pub.dev/packages/sign_in_with_apple)
- [Apple Sign In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)

---

## Support

If you encounter issues not covered in this guide:
1. Check the [Flutter Firebase Auth documentation](https://firebase.flutter.dev/docs/auth/overview)
2. Review package-specific issues on GitHub
3. Verify all configuration steps were completed correctly
4. Check Firebase Console logs for authentication errors
