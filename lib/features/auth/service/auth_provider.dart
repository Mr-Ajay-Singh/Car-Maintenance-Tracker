import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../../sync/service/firebase_sync_service.dart';
import 'firebase_auth_service.dart';

/// Auth state provider for managing authentication state throughout the app
class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseSyncService _syncService = FirebaseSyncService.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get userId => _currentUser?.id;

  /// Initialize auth state - call on app startup
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to auto sign in using stored credentials
      final userId = await _authService.autoSignIn();

      if (userId != null) {
        final user = _authService.getCurrentUser();
        if (user != null) {
          _currentUser = UserModel(
            id: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            createdAt: user.metadata.creationTime ?? DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          // Trigger background sync after successful auto-login
          _syncService.syncAll().catchError((e) {
            print('Background sync failed: $e');
            return false;
          });
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = await _authService.signInWithEmail(email, password);

      if (userId != null) {
        final user = _authService.getCurrentUser();
        if (user != null) {
          _currentUser = UserModel(
            id: user.uid,
            email: user.email ?? email,
            displayName: user.displayName,
            createdAt: user.metadata.creationTime ?? DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          _isLoading = false;
          notifyListeners();

          // Trigger background sync after successful login
          _syncService.syncAll().catchError((e) {
            print('Background sync failed: $e');
            return false;
          });

          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = await _authService.signUpWithEmail(email, password);

      if (userId != null) {
        final user = _authService.getCurrentUser();
        if (user != null) {
          _currentUser = UserModel(
            id: user.uid,
            email: user.email ?? email,
            displayName: user.displayName,
            createdAt: user.metadata.creationTime ?? DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          _isLoading = false;
          notifyListeners();

          // Trigger background sync after successful signup
          _syncService.syncAll().catchError((e) {
            print('Background sync failed: $e');
            return false;
          });

          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = await _authService.signInWithGoogle();

      if (userId != null) {
        final user = _authService.getCurrentUser();
        if (user != null) {
          _currentUser = UserModel(
            id: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            createdAt: user.metadata.creationTime ?? DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          _isLoading = false;
          notifyListeners();

          // Trigger background sync after successful login
          _syncService.syncAll().catchError((e) {
            print('Background sync failed: $e');
            return false;
          });

          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Apple (iOS only)
  Future<bool> signInWithApple() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = await _authService.signInWithApple();

      if (userId != null) {
        final user = _authService.getCurrentUser();
        if (user != null) {
          _currentUser = UserModel(
            id: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            createdAt: user.metadata.creationTime ?? DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          _isLoading = false;
          notifyListeners();

          // Trigger background sync after successful login
          _syncService.syncAll().catchError((e) {
            print('Background sync failed: $e');
            return false;
          });

          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Manually trigger sync
  Future<bool> syncData() async {
    try {
      return await _syncService.syncAll();
    } catch (e) {
      print('Manual sync failed: $e');
      return false;
    }
  }
}
