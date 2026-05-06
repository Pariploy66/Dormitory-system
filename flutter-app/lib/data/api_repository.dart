import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';
import '../core/dio_client.dart';
import 'models.dart';

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  return ApiRepository(ref.watch(dioProvider));
});

class ApiRepository {
  ApiRepository(this._dio);
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  // ── Auth ─────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    final resp = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _storage.write(
      key: AppConstants.jwtStorageKey,
      value: resp.data['accessToken'] as String,
    );
    await _storage.write(
      key: AppConstants.parentIdStorageKey,
      value: resp.data['parentId'] as String,
    );
  }

  /// Creates the account but does NOT store the JWT.
  /// The caller is responsible for redirecting to /login so the user
  /// authenticates explicitly — this prevents stale-state bugs.
  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.jwtStorageKey);
    return token != null;
  }

  Future<void> registerFcmToken(String fcmToken) async {
    await _dio.post('/auth/device', data: {'fcmToken': fcmToken});
  }

  // ── Profile ──────────────────────────────────────────────────

  /// Fetch the authenticated parent's own profile (name, phone, email).
  Future<ParentProfile> getMyProfile() async {
    final resp = await _dio.get('/me/profile');
    return ParentProfile.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── Students & Logs ──────────────────────────────────────────

  Future<List<Student>> getMyStudents() async {
    final resp = await _dio.get('/me/students');
    return (resp.data as List)
        .map((e) => Student.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch only today's logs for [studentId].
  ///
  /// Uses the existing /logs?days=2 endpoint (always deployed, no 404 risk)
  /// and applies a client-side local-date filter so only records whose local
  /// date equals today are returned.  Requesting days=2 instead of days=1
  /// ensures Thai midnight records are captured even on a UTC server
  /// (Thai 00:00–07:00 ICT maps to the previous UTC calendar day).
  Future<List<AccessLog>> getTodayLogs(String studentId) async {
    final resp = await _dio.get(
      '/me/students/$studentId/logs',
      queryParameters: {'days': 2},
    );
    final today = DateTime.now();
    return (resp.data as List)
        .map((e) => AccessLog.fromJson(e as Map<String, dynamic>))
        .where((l) =>
            l.accessTime.year == today.year &&
            l.accessTime.month == today.month &&
            l.accessTime.day == today.day)
        .toList();
  }

  Future<List<AccessLog>> getAccessLogs(String studentId,
      {int days = 7}) async {
    final resp = await _dio.get(
      '/me/students/$studentId/logs',
      queryParameters: {'days': days},
    );
    return (resp.data as List)
        .map((e) => AccessLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
