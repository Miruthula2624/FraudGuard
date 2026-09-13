import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Token Storage Service
/// Manages the JWT Bearer token lifecycle using encrypted platform storage.
class TokenStorage {
  static const String _tokenKey = 'fraudguard_jwt_token';
  static const String _userKey = 'fraudguard_user_data';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save the JWT Bearer token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieve the JWT Bearer token
  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the JWT Bearer token (on logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Check whether a valid token exists
  Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }

  /// Optionally save serialized user profile information
  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: _userKey, value: userDataJson);
  }

  /// Optionally read serialized user profile information
  Future<String?> readUserData() async {
    return await _storage.read(key: _userKey);
  }
}
