import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../common/data/shared_preferences_helper.dart';
import '../../../common/utils/platform_utils.dart';

/// FirebaseAuthService - Authentication with first sign-in detection
///
/// Handles user authentication and triggers appropriate sync strategy:
/// - First sign-in: Full sync (O(n) - one time only)
/// - Returning user: Incremental sync (O(k) - fast)
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ==================== SIGN UP ====================

  /// Sign up with email and password
  /// Creates new Firebase user and triggers first-time full sync
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      // Create Firebase user
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String userId = userCredential.user!.uid;

      // Store user data locally
      await SharedPreferencesHelper.setUserId(userId);
      await SharedPreferencesHelper.setUserEmail(email);
      await SharedPreferencesHelper.setIsLoggedIn(true);
      await SharedPreferencesHelper.setIsFirstSignIn(true);

      // Trigger full sync for first sign-in

      return userId;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // ==================== SIGN IN ====================

  /// Sign in with email and password
  /// Automatically detects first sign-in and performs appropriate sync
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      // Authenticate user
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String userId = userCredential.user!.uid;

      // Store user data locally
      await SharedPreferencesHelper.setUserId(userId);
      await SharedPreferencesHelper.setUserEmail(email);
      await SharedPreferencesHelper.setIsLoggedIn(true);

      return userId;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // ==================== SOCIAL SIGN-IN ====================

  /// Sign in with Google
  /// Works on both iOS and Android
  Future<String?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final String userId = userCredential.user!.uid;
      final String email = userCredential.user!.email ?? googleUser.email;

      // Store user data locally
      await SharedPreferencesHelper.setUserId(userId);
      await SharedPreferencesHelper.setUserEmail(email);
      await SharedPreferencesHelper.setIsLoggedIn(true);

      // Check if this is a new user (first sign-in)
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await SharedPreferencesHelper.setIsFirstSignIn(true);
      }

      return userId;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign in with Apple
  /// Only available on iOS
  Future<String?> signInWithApple() async {
    if (!PlatformUtils.isAppleSignInAvailable) {
      throw Exception('Apple Sign-In is only available on iOS');
    }

    try {
      // Check if Apple Sign-In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign-In is not available on this device');
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);

      final String userId = userCredential.user!.uid;
      final String email = userCredential.user!.email ??
          appleCredential.email ??
          '$userId@privaterelay.appleid.com';

      // Store user data locally
      await SharedPreferencesHelper.setUserId(userId);
      await SharedPreferencesHelper.setUserEmail(email);
      await SharedPreferencesHelper.setIsLoggedIn(true);

      // Check if this is a new user (first sign-in)
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await SharedPreferencesHelper.setIsFirstSignIn(true);
      }

      // Update display name if provided by Apple
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      return userId;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return null; // User canceled
        case AuthorizationErrorCode.failed:
          throw Exception('Apple Sign-In failed');
        case AuthorizationErrorCode.invalidResponse:
          throw Exception('Invalid response from Apple');
        case AuthorizationErrorCode.notHandled:
          throw Exception('Apple Sign-In not handled');
        case AuthorizationErrorCode.unknown:
          throw Exception('Unknown Apple Sign-In error');
        default:
          throw Exception('Apple Sign-In error: ${e.code}');
      }
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out user and clear local data
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();
      await SharedPreferencesHelper.clearAllUserData();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // ==================== AUTO SIGN-IN ====================

  /// Check if user is already signed in and perform auto-login
  /// Called on app startup
  Future<String?> autoSignIn() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final userId = currentUser.uid;

        // Restore user data from SharedPreferences or Firebase
        final storedUserId = await SharedPreferencesHelper.getUserId();

        if (storedUserId == null || storedUserId != userId) {
          // User data not in SharedPreferences, restore from Firebase
          await SharedPreferencesHelper.setUserId(userId);
          await SharedPreferencesHelper.setUserEmail(currentUser.email ?? '');
          await SharedPreferencesHelper.setIsLoggedIn(true);
        }

        return userId;
      }

      return null;
    } catch (e) {
      // debugPrint('Auto sign-in failed: $e');
      return null;
    }
  }

  // ==================== GETTERS ====================

  /// Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Check if user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  /// Get current Firebase user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // ==================== UPDATE PROFILE ====================

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      await SharedPreferencesHelper.setUserEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Email update failed: $e');
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  // ==================== RE-AUTHENTICATION ====================

  /// Re-authenticate user (required before sensitive operations)
  Future<void> reauthenticate(String email, String password) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final credential =
            EmailAuthProvider.credential(email: email, password: password);
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Re-authentication failed: $e');
    }
  }

  // ==================== DELETE ACCOUNT ====================

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        await SharedPreferencesHelper.clearAllUserData();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Handle Firebase Auth exceptions with user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this operation.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

}
