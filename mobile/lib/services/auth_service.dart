import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? token;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
    this.token,
  });
}

class AuthService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  /// Register a new user with fullname, email, and password.
  Future<AuthResult> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.registerEndpoint,
        data: {
          'fullname': fullname.trim(),
          'email': email.trim(),
          'password': password,
        },
      );

      final message = response.data?['message']?.toString() ?? 'Registration successful';
      return AuthResult(success: true, message: message);
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _extractErrorMessage(e, defaultMessage: 'Registration failed. Please check your details.'),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred during registration.',
      );
    }
  }

  /// Login user with email and password.
  /// On success, extracts JWT & user, and saves both securely.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        return const AuthResult(
          success: false,
          message: 'Invalid server response.',
        );
      }

      final token = data['token']?.toString();
      final userJson = data['user'] as Map<String, dynamic>?;

      if (token == null || token.isEmpty || userJson == null) {
        return const AuthResult(
          success: false,
          message: 'Server did not return a valid authentication token.',
        );
      }

      final user = User.fromJson(userJson);

      // Persist token and user data securely
      await _tokenStorage.saveToken(token);
      await _tokenStorage.saveUserData(jsonEncode(user.toJson()));

      return AuthResult(
        success: true,
        message: data['message']?.toString() ?? 'Login successful',
        user: user,
        token: token,
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _extractErrorMessage(e, defaultMessage: 'Login failed. Please verify your credentials.'),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred during login.',
      );
    }
  }

  /// Logout user:
  /// Clears stored JWT token and user profile, and invokes backend logout endpoint.
  Future<void> logout() async {
    try {
      // Fire logout request to the server (best effort)
      await _apiClient.dio.post(ApiConstants.logoutEndpoint);
    } catch (_) {
      // Ignore network errors on logout since we unconditionally clear local session
    } finally {
      await _tokenStorage.deleteToken();
    }
  }

  /// Restores cached session from secure storage.
  /// Returns the cached User if token exists, or null.
  Future<User?> restoreSession() async {
    try {
      final hasToken = await _tokenStorage.hasToken();
      if (!hasToken) return null;

      final userDataStr = await _tokenStorage.readUserData();
      if (userDataStr != null && userDataStr.isNotEmpty) {
        final decoded = jsonDecode(userDataStr) as Map<String, dynamic>;
        return User.fromJson(decoded);
      }
      return null;
    } catch (_) {
      await _tokenStorage.deleteToken();
      return null;
    }
  }

  /// Helper to convert API errors / Dio exceptions into clean user-friendly messages
  String _extractErrorMessage(DioException e, {required String defaultMessage}) {
    if (e.response != null && e.response?.data is Map) {
      final message = e.response!.data['message'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your network connection.';
      case DioExceptionType.connectionError:
        return 'Unable to reach the server. Please ensure the backend is running.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return 'Invalid email or password.';
        if (status == 400) return 'Invalid request. Please verify the input.';
        if (status == 500) return 'Server error. Please try again later.';
        return defaultMessage;
      default:
        return defaultMessage;
    }
  }
}
