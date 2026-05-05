import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n.dart';
import '../data/api_repository.dart';
import '../data/models.dart';

// ── Locale & Strings ─────────────────────────────────────────

/// Persists the user's chosen locale (EN / TH).
/// Toggle: ref.read(localeProvider.notifier).state = const Locale('th')
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

/// Derives the correct string bundle from [localeProvider].
final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'th' ? AppStrings.th : AppStrings.en;
});

// ── Auth state ───────────────────────────────────────────────

final authStateProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(apiRepositoryProvider);
  return repo.isLoggedIn();
});

// ── Students list ────────────────────────────────────────────

final studentsProvider = FutureProvider<List<Student>>((ref) async {
  // Wait for auth check — provider auto-reruns when authStateProvider changes,
  // which means it refreshes automatically after login and after a 401 redirect.
  final isLoggedIn = await ref.watch(authStateProvider.future);
  if (!isLoggedIn) return [];

  try {
    return await ref.read(apiRepositoryProvider).getMyStudents();
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      // Tokens were already cleared by the Dio interceptor.
      // Trigger the router to redirect back to /login.
      ref.invalidate(authStateProvider);
    }
    rethrow;
  }
});

// ── Access logs for a specific student ──────────────────────

final accessLogsProvider =
    FutureProvider.family<List<AccessLog>, String>((ref, studentId) async {
  final isLoggedIn = await ref.watch(authStateProvider.future);
  if (!isLoggedIn) return [];

  try {
    return await ref.read(apiRepositoryProvider).getAccessLogs(studentId);
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      ref.invalidate(authStateProvider);
    }
    rethrow;
  }
});

// ── Selected student ─────────────────────────────────────────

final selectedStudentProvider = StateProvider<Student?>((ref) => null);
