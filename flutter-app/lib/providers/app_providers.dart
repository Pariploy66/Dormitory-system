import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_repository.dart';
import '../data/models.dart';

// ── Auth state ───────────────────────────────────────────────

final authStateProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(apiRepositoryProvider);
  return repo.isLoggedIn();
});

// ── Students list ────────────────────────────────────────────

final studentsProvider = FutureProvider<List<Student>>((ref) async {
  final repo = ref.watch(apiRepositoryProvider);
  return repo.getMyStudents();
});

// ── Access logs for a specific student ──────────────────────

final accessLogsProvider =
    FutureProvider.family<List<AccessLog>, String>((ref, studentId) async {
  final repo = ref.watch(apiRepositoryProvider);
  return repo.getAccessLogs(studentId);
});

// ── Selected student ─────────────────────────────────────────

final selectedStudentProvider = StateProvider<Student?>((ref) => null);
