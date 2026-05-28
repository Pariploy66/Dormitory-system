import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../domain/student_model.dart';
import '../domain/access_log_model.dart';

/// Dorm-related data: students, access logs.
/// Company pattern: features/dorm/data/dorm_repository.dart
class DormRepository {
  const DormRepository(this._api);
  final ApiClient _api;

  /// Students linked to the authenticated parent.
  Future<List<StudentModel>> getStudents() async {
    try {
      final res = await _api.get('/me/students');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Today's access logs for [studentId].
  /// Fetches days=2 and filters client-side to catch Thai-midnight records
  /// that fall on the previous UTC calendar day.
  Future<List<AccessLogModel>> getLogsToday(String studentId) async {
    try {
      final res = await _api.get(
        '/me/students/$studentId/logs',
        queryParameters: {'days': 2},
      );
      final today = DateTime.now();
      final list = res.data as List<dynamic>;
      return list
          .map((e) =>
              AccessLogModel.fromJson(e as Map<String, dynamic>))
          .where((l) =>
              l.accessTime.year == today.year &&
              l.accessTime.month == today.month &&
              l.accessTime.day == today.day)
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Access logs for [studentId] up to [days] days back (max 7).
  Future<List<AccessLogModel>> getLogs(String studentId,
      {int days = 7}) async {
    try {
      final res = await _api.get(
        '/me/students/$studentId/logs',
        queryParameters: {'days': days},
      );
      final list = res.data as List<dynamic>;
      return list
          .map((e) =>
              AccessLogModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final msg =
        (e.response?.data is Map ? e.response?.data['message'] : null) ??
            e.message ??
            'Network error';
    return Exception(msg);
  }
}
