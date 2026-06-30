import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/student_model.dart';
import '../domain/access_log_model.dart';
import '../../auth/domain/parent_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/socket_service.dart';

part 'dorm_event.dart';
part 'dorm_state.dart';

/// Manages all dorm data: students, logs, history filters, profile.
/// Auto-polling (30s) + real-time Socket.IO via [SocketService.logCreatedStream].
class DormBloc extends Bloc<DormEvent, DormState> {
  final ApiService _api;
  final SocketService _socket;
  Timer? _pollTimer;
  StreamSubscription<String>? _socketSub;
  static const _pollInterval = Duration(seconds: 30);

  DormBloc(this._api, this._socket) : super(const DormState()) {
    on<DormRefreshDashboard>(_onRefreshDashboard);
    on<DormRefreshHistory>(_onRefreshHistory);
    on<DormSetFilterDays>(_onSetFilterDays);
    on<DormSetFilterType>(_onSetFilterType);
    on<DormFetchProfile>(_onFetchProfile);
    on<DormSelectStudent>(_onSelectStudent);
    on<DormClearSelection>(_onClearSelection);
    on<DormReset>(_onReset);

    _socketSub = _socket.logCreatedStream.listen((studentId) {
      final tracked = state.students.any((s) => s.id == studentId);
      if (tracked) add(const DormRefreshDashboard());
    });
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    _pollTimer?.cancel();
    return super.close();
  }

  // ── Dashboard ────────────────────────────────────────────────

  Future<void> _onRefreshDashboard(
      DormRefreshDashboard event, Emitter<DormState> emit) async {
    // Start 30-second auto-poll on first dispatch (lazy, owned by BLoC)
    _pollTimer ??= Timer.periodic(
      _pollInterval,
      (_) => add(const DormRefreshDashboard()),
    );

    if (state.students.isEmpty) {
      emit(state.copyWith(status: DormStatus.loading));
    }
    try {
      final students = await _api.getStudents();

      // Resolve which child to load: keep the current selection if still valid,
      // auto-select when there is exactly one child.
      String? activeId;
      if (state.selectedStudentId != null &&
          students.any((s) => s.id == state.selectedStudentId)) {
        activeId = state.selectedStudentId;
      } else if (students.length == 1) {
        activeId = students.first.id;
      }

      // No students, or multi-child parent awaiting selection → no logs to load.
      if (activeId == null) {
        emit(state.copyWith(
          status: DormStatus.success,
          students: students,
          selectedStudentId: students.length == 1 ? students.first.id : null,
          lastUpdated: DateTime.now(),
        ));
        return;
      }

      final logsToday = await _api.getLogsToday(activeId);
      final logs = await _api.getLogs(activeId);
      emit(state.copyWith(
        status: DormStatus.success,
        students: students,
        selectedStudentId: activeId,
        logsToday: logsToday,
        logs: logs,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status:
            state.students.isEmpty ? DormStatus.failure : DormStatus.success,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  // ── History ──────────────────────────────────────────────────

  Future<void> _onRefreshHistory(
      DormRefreshHistory event, Emitter<DormState> emit) async {
    final id = state.activeStudent?.id;
    if (id == null) return;
    try {
      if (state.filterDays == 1) {
        final logsToday = await _api.getLogsToday(id);
        emit(state.copyWith(
            logsToday: logsToday, lastUpdated: DateTime.now()));
      } else {
        final logs = await _api.getLogs(id, days: state.filterDays);
        emit(state.copyWith(logs: logs, lastUpdated: DateTime.now()));
      }
    } catch (_) {
      // Swallow background refresh errors — keep stale data visible
    }
  }

  Future<void> _onSetFilterDays(
      DormSetFilterDays event, Emitter<DormState> emit) async {
    emit(state.copyWith(filterDays: event.days));
    add(const DormRefreshHistory());
  }

  Future<void> _onSetFilterType(
      DormSetFilterType event, Emitter<DormState> emit) async {
    emit(state.copyWith(filterType: event.filterType));
  }

  // ── Profile ──────────────────────────────────────────────────

  Future<void> _onFetchProfile(
      DormFetchProfile event, Emitter<DormState> emit) async {
    if (state.profile != null) return;
    emit(state.copyWith(profileLoading: true));
    try {
      final profile = await _api.getProfile();
      emit(state.copyWith(profile: profile, profileLoading: false));
    } catch (e) {
      emit(state.copyWith(
          profileLoading: false,
          error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ── Child selection (multi-child parents) ────────────────────

  void _onSelectStudent(DormSelectStudent event, Emitter<DormState> emit) {
    emit(state.copyWith(
      selectedStudentId: event.studentId,
      logsToday: const [],
      logs: const [],
    ));
    add(const DormRefreshDashboard()); // load the chosen child's logs
  }

  void _onClearSelection(DormClearSelection event, Emitter<DormState> emit) {
    emit(state.copyWith(
      selectedStudentId: null,
      logsToday: const [],
      logs: const [],
    ));
  }

  // ── Logout reset ─────────────────────────────────────────────
  /// Stop polling and clear all data so the next user starts clean.
  /// Nulls the timer so it lazily restarts on the next dashboard load.
  void _onReset(DormReset event, Emitter<DormState> emit) {
    _pollTimer?.cancel();
    _pollTimer = null;
    emit(const DormState());
  }
}
