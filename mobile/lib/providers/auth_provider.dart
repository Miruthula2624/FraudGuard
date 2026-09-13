import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initializing,
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initializing;
  User? _currentUser;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    restoreSession();
  }

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading =>
      _status == AuthStatus.initializing || _status == AuthStatus.authenticating;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Check storage on startup and restore cached session
  Future<void> restoreSession() async {
    _status = AuthStatus.initializing;
    notifyListeners();

    try {
      final restoredUser = await _authService.restoreSession();
      if (restoredUser != null) {
        _currentUser = restoredUser;
        _status = AuthStatus.authenticated;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  /// Authenticate with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email: email, password: password);

    if (result.success && result.user != null) {
      _currentUser = result.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.unauthenticated;
      _errorMessage = result.message ?? 'Login failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Register a new account
  Future<bool> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      fullname: fullname,
      email: email,
      password: password,
    );

    if (result.success) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.unauthenticated;
      _errorMessage = result.message ?? 'Registration failed.';
      notifyListeners();
      return false;
    }
  }

  /// Log out the user
  Future<void> logout() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await _authService.logout();

    _currentUser = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
