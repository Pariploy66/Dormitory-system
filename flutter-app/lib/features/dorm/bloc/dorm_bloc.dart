import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/dorm_repository.dart';
import '../domain/student_model.dart';
import '../domain/access_log_model.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/parent_model.dart';

part 'dorm_event.dart';
part 'dorm_state.dart';

/// Manages all dorm data: students, logs, history filters, profile.
/// Company pattern: features/dorm/bloc/dorm_bloc.dart
/// Auto-polling (30s) is driven by the Dashboard screen via Timer.periodic
/// dispatching DormRefreshDashboard — keeping the BLoC stateless.
class DormBloc extends Bloc<DormEvent, DormState> {
  final DormRepository _dormRepo;
  final AuthRepository _authRepo;

  DormBloc(this._dormRepo, this._authRepo) : super(const DormState()) {
    on<DormRefreshDashboard>(_onRefreshDashboard);
    on<DormRefreshHistory>(_onRefreshHistory);
    on<DormSetFilterDays>(_onSetFilterDays);
    on<DormSetFilterType>(_onSetFilterType);
    on<DormFetchProfile>(_onFetchProfile);
  }

  // ── Dashboard ────────────────────────────────────────────────

  Future<void> _onRefreshDashboard(
      DormRefreshDashboard event, Emitter<DormState> emit) async {
    // Only show loading spinner on first load (students list empty)
    if (state.students.isEmpty) {
      emit(state.copyWith(status: DormStatus.loading));
    }
    try {
      final students = await _dormRepo.getStudents();
      if (students.isEmpty) {
        emit(state.copyWith(
            status: DormStatus.success,
            students: students,
            lastUpdated: DateTime.now()));
        return;
      }
      final id = students.first.id;
      final logsToday = await _dormRepo.getLogsToday(id);
      final logs = await _dormRepo.getLogs(id);
      emit(state.copyWith(
        status: DormStatus.success,
        students: students,
        logsToday: logsToday,
        logs: logs,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      // On background poll error keep existing data visible
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
        final logsToday = await _dormRepo.getLogsToday(id);
        emit(state.copyWith(
            logsToday: logsToday, lastUpdated: DateTime.now()));
      } else {
        final logs =
            await _dormRepo.getLogs(id, days: state.filterDays);
        emit(state.copyWith(logs: logs, lastUpdated: DateTime.now()));
      }
    } catch (_) {
      // Swallow background refresh errors — keep stale data visible
    }
  }

  Future<void> _onSetFilterDays(
      DormSetFilterDays event, Emitter<DormState> emit) async {
    emit(state.copyWith(filterDays: event.days));
    // Refresh with new period
    add(const DormRefreshHistory());
  }

  Future<void> _onSetFilterType(
      DormSetFilterType event, Emitter<DormState> emit) async {
    emit(state.copyWith(filterType: event.filterType));
  }

  // ── Profile ──────────────────────────────────────────────────

  Future<void> _onFetchProfile(
      DormFetchProfile event, Emitter<DormState> emit) async {
    if (state.profile != null) return; // already loaded
    emit(state.copyWith(profileLoading: true));
    try {
      final profile = await _authRepo.getProfile();
      emit(state.copyWith(profile: profile, profileLoading: false));
    } catch (e) {
      emit(state.copyWith(
          profileLoading: false,
          error: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
