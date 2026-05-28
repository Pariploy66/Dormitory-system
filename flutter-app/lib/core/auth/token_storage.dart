import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart';

/// Wrapper around FlutterSecureStorage for JWT + parentId management.
/// Company pattern from mobile-flutter/core/auth/token_storage.dart
class TokenStorage {
  const TokenStorage(this._storage);
  final FlutterSecureStorage _storage;

  Future<String?> getToken() =>
      _storage.read(key: AppConstants.jwtStorageKey);

  Future<String?> getParentId() =>
      _storage.read(key: AppConstants.parentIdStorageKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.jwtStorageKey, value: token);

  Future<void> saveParentId(String parentId) =>
      _storage.write(key: AppConstants.parentIdStorageKey, value: parentId);

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> deleteAll() => _storage.deleteAll();
}
