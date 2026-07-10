import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart';
import 'cert_pinning_stub.dart'
    if (dart.library.io) 'cert_pinning_io.dart';

/// Centralized Dio wrapper — company pattern from mobile-flutter/core/api/api_client.dart
/// Reads JWT from FlutterSecureStorage on every request (no stale-token risk).
/// On 401, clears stored tokens automatically.
class ApiClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient({required String baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    // Certificate pinning — active only when fingerprints are embedded at
    // build time (production HTTPS); no-op in dev (plain HTTP) and on web.
    applyCertificatePinning(_dio, AppConstants.pinnedCertSha256);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.jwtStorageKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Clear tokens so isLoggedIn() returns false on next check
          await _storage.delete(key: AppConstants.jwtStorageKey);
          await _storage.delete(key: AppConstants.parentIdStorageKey);
        }
        handler.next(error);
      },
    ));
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Response<T>> get<T>(String path,
          {Map<String, dynamic>? queryParameters}) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}
