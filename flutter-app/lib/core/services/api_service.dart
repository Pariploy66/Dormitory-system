import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../auth/token_storage.dart';
import '../../features/auth/domain/parent_model.dart';
import '../../features/dorm/domain/student_model.dart';
import '../../features/dorm/domain/access_log_model.dart';

/// Centralized API service — single entry point for all HTTP calls.
/// Unwraps the NestJS response envelope { code, message, data } automatically.
class ApiService {
  const ApiService(this._api, this._storage);
  final ApiClient _api;
  final TokenStorage _storage;

  // ── Auth (ThaID) ────────────────────────────────────────────────────────────

  /// Get the ThaID authorization URL to open in the in-app webview.
  Future<String> getThaidLoginUrl() async {
    try {
      final res = await _api.get('/auth/thaid/login-url');
      final payload = _unwrapMap(res.data);
      final url = payload['url'] as String?;
      if (url == null) throw Exception('SERVER_ERROR');
      return url;
    } on DioException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Exchange the ThaID authorization code (30s TTL) for our JWT.
  Future<void> thaidLogin(String code) async {
    try {
      final res = await _api.post('/auth/thaid', data: {'code': code});
      final payload = _unwrapMap(res.data);
      final accessToken = payload['accessToken'] as String?;
      final parentId = payload['parentId'] as String?;
      if (accessToken == null || parentId == null) {
        throw Exception('SERVER_ERROR');
      }
      await _storage.saveToken(accessToken);
      await _storage.saveParentId(parentId);
      _api.setToken(accessToken);
    } on DioException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout'); // best-effort sign-out audit log
    } catch (_) {
      // logout audit failure is non-fatal
    }
    await _storage.deleteAll();
    _api.clearToken();
  }

  Future<bool> isLoggedIn() => _storage.isLoggedIn();

  Future<void> registerFcmToken(String fcmToken) async {
    try {
      await _api.post('/auth/device', data: {'fcmToken': fcmToken});
    } catch (_) {
      // FCM registration failure is non-fatal
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<ParentModel> getProfile() async {
    try {
      final res = await _api.get('/me/profile');
      return ParentModel.fromJson(_unwrapMap(res.data));
    } on DioException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ── Students & Logs ───────────────────────────────────────────────────────

  Future<List<StudentModel>> getStudents() async {
    try {
      final res = await _api.get('/me/students');
      final list = _unwrapList(res.data);
      return list
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDormError(e);
    }
  }

  Future<List<AccessLogModel>> getLogsToday(String studentId) async {
    try {
      final res = await _api.get(
        '/me/students/$studentId/logs',
        queryParameters: {'days': 2},
      );
      final today = DateTime.now();
      final list = _unwrapList(res.data);
      return list
          .map((e) => AccessLogModel.fromJson(e as Map<String, dynamic>))
          .where((l) =>
              l.accessTime.year == today.year &&
              l.accessTime.month == today.month &&
              l.accessTime.day == today.day)
          .toList();
    } on DioException catch (e) {
      throw _mapDormError(e);
    }
  }

  Future<List<AccessLogModel>> getLogs(String studentId,
      {int days = 7}) async {
    try {
      final res = await _api.get(
        '/me/students/$studentId/logs',
        queryParameters: {'days': days},
      );
      final list = _unwrapList(res.data);
      return list
          .map((e) => AccessLogModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDormError(e);
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  /// Unwrap { code, message, data: Map } → Map
  Map<String, dynamic> _unwrapMap(dynamic raw) {
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as Map<String, dynamic>? ?? {};
    }
    return raw as Map<String, dynamic>? ?? {};
  }

  /// Unwrap { code, message, data: List } → List
  List<dynamic> _unwrapList(dynamic raw) {
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'] as List<dynamic>? ?? [];
    }
    return raw as List<dynamic>? ?? [];
  }

  Exception _mapAuthError(DioException e) {
    final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown;
    if (isNetworkError) return Exception('NETWORK_ERROR');
    // 403 = ThaID identity is not a registered guardian of an active student.
    if (e.response?.statusCode == 403) return Exception('NO_ACCESS');
    return Exception('SERVER_ERROR');
  }

  Exception _mapDormError(DioException e) {
    final msg =
        (e.response?.data is Map ? e.response?.data['message'] : null) ??
            e.message ??
            'Network error';
    return Exception(msg);
  }
}
