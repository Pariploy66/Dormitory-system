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

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final resp = await _dio.post('/auth/register', data: {
      'name': name,
      'phone': phone,
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

  // ── Students & Logs ──────────────────────────────────────────

  Future<List<Student>> getMyStudents() async {
    final resp = await _dio.get('/me/students');
    return (resp.data as List)
        .map((e) => Student.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AccessLog>> getAccessLogs(String studentId,
      {int limit = 50}) async {
    final resp = await _dio.get(
      '/me/students/$studentId/logs',
      queryParameters: {'limit': limit},
    );
    return (resp.data as List)
        .map((e) => AccessLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
