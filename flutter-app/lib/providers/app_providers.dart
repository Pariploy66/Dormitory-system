import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../data/api_repository.dart';
import '../data/models.dart';

// ── Locale & Strings ─────────────────────────────────────────

/// Persists the user's chosen locale (EN / TH).
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

// ── Parent profile ───────────────────────────────────────────

/// Fetches the authenticated parent's own profile (name, phone, email).
/// Automatically invalidates auth on 401.
final profileProvider = FutureProvider<ParentProfile>((ref) async {
  final isLoggedIn = await ref.watch(authStateProvider.future);
  if (!isLoggedIn) throw Exception('Not logged in');
  try {
    return await ref.read(apiRepositoryProvider).getMyProfile();
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) ref.invalidate(authStateProvider);
    rethrow;
  }
});

// ── Students list ────────────────────────────────────────────

final studentsProvider = FutureProvider<List<Student>>((ref) async {
  final isLoggedIn = await ref.watch(authStateProvider.future);
  if (!isLoggedIn) return [];
  try {
    return await ref.read(apiRepositoryProvider).getMyStudents();
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) ref.invalidate(authStateProvider);
    rethrow;
  }
});

// ── Polling configuration ────────────────────────────────────
//
// Both log providers auto-poll every [_kPollInterval] seconds.
// The timer lives inside each AsyncNotifier and is automatically cancelled
// when no widget is watching the provider (autoDispose).
// Background refreshes NEVER show a loading spinner — existing data stays
// visible while the network call is in flight (no UI flicker).

const _kPollInterval = Duration(seconds: 30);

// ── Today's logs — AsyncNotifier with background polling ────
//
// Hits GET /me/students/:id/logs?days=2 and applies a client-side filter
// to keep only records whose local date == today.
// days=2 ensures Thai midnight records are included even when the server
// clock is UTC (Thai 00:00–07:00 ICT falls on the previous UTC day).

class _TodayLogsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<AccessLog>, String> {
  Timer? _timer;

  @override
  Future<List<AccessLog>> build(String studentId) async {
    ref.onDispose(() => _timer?.cancel());
    _timer = Timer.periodic(_kPollInterval, (_) => _bgRefresh());
    return _fetch();
  }

  Future<List<AccessLog>> _fetch() async {
    final isLoggedIn = await ref.read(authStateProvider.future);
    if (!isLoggedIn) return [];
    try {
      return await ref.read(apiRepositoryProvider).getTodayLogs(arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) ref.invalidate(authStateProvider);
      rethrow;
    }
  }

  /// Silent background refresh — keeps current data while fetching.
  /// Errors are swallowed so stale data stays visible instead of flashing.
  Future<void> _bgRefresh() async {
    try {
      final fresh = await _fetch();
      state = AsyncData(fresh);
    } catch (_) {}
  }
}

final todayLogsProvider = AsyncNotifierProvider.autoDispose
    .family<_TodayLogsNotifier, List<AccessLog>, String>(
  _TodayLogsNotifier.new,
);

// ── 7-day access logs — AsyncNotifier with background polling ─
//
// Hits GET /me/students/:id/logs?days=7 (up to 500 records, newest first).
// Used by Dashboard > Recent Activity (shows allLogs.first = absolute latest)
// and by History page when the user selects Last 3 Days / Last 7 Days.

class _AccessLogsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<AccessLog>, String> {
  Timer? _timer;

  @override
  Future<List<AccessLog>> build(String studentId) async {
    ref.onDispose(() => _timer?.cancel());
    _timer = Timer.periodic(_kPollInterval, (_) => _bgRefresh());
    return _fetch();
  }

  Future<List<AccessLog>> _fetch() async {
    final isLoggedIn = await ref.read(authStateProvider.future);
    if (!isLoggedIn) return [];
    try {
      return await ref.read(apiRepositoryProvider).getAccessLogs(arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) ref.invalidate(authStateProvider);
      rethrow;
    }
  }

  Future<void> _bgRefresh() async {
    try {
      final fresh = await _fetch();
      state = AsyncData(fresh);
    } catch (_) {}
  }
}

final accessLogsProvider = AsyncNotifierProvider.autoDispose
    .family<_AccessLogsNotifier, List<AccessLog>, String>(
  _AccessLogsNotifier.new,
);

// ── Selected student ─────────────────────────────────────────

final selectedStudentProvider = StateProvider<Student?>((ref) => null);

// ── Selected tab (allows Dashboard to switch to History tab) ──

final selectedTabProvider = StateProvider<int>((ref) => 0);
