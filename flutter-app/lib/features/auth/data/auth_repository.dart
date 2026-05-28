import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/token_storage.dart';
import '../domain/parent_model.dart';

/// Auth operations: login, register, logout, FCM token registration.
/// Company pattern: features/auth/data/auth_repository.dart
class AuthRepository {
  const AuthRepository(this._api, this._storage);
  final ApiClient _api;
  final TokenStorage _storage;

  /// Login with email + password.
  /// Saves JWT and parentId to secure storage on success.
  Future<void> login(String email, String password) async {
    try {
      final res = await _api.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = res.data as Map<String, dynamic>? ?? {};
      final accessToken = data['accessToken'] as String?;
      final parentId = data['parentId'] as String?;
      if (accessToken == null || parentId == null) {
        throw Exception('Invalid server response: missing token fields');
      }
      await _storage.saveToken(accessToken);
      await _storage.saveParentId(parentId);
      _api.setToken(accessToken);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Register new parent account.
  /// Does NOT auto-login — caller must redirect to /login.
  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      await _api.post('/auth/register', data: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _api.clearToken();
  }

  Future<bool> isLoggedIn() => _storage.isLoggedIn();

  /// Register FCM device token for push notifications.
  Future<void> registerFcmToken(String fcmToken) async {
    try {
      await _api.post('/auth/device', data: {'fcmToken': fcmToken});
    } catch (_) {
      // FCM registration failure is non-fatal
    }
  }

  /// Fetch authenticated parent's profile.
  Future<ParentModel> getProfile() async {
    try {
      final res = await _api.get('/me/profile');
      return ParentModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown;
    if (isNetworkError) return Exception('NETWORK_ERROR');
    final status = e.response?.statusCode;
    if (status == 401 || status == 400) return Exception('WRONG_CREDENTIALS');
    if (status == 409) return Exception('ALREADY_REGISTERED');
    return Exception('SERVER_ERROR');
  }
}
