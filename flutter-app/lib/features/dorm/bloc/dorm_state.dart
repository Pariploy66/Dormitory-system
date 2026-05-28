part of 'dorm_bloc.dart';

enum DormStatus { initial, loading, success, failure }

class DormState extends Equatable {
  final DormStatus status;
  final List<StudentModel> students;
  final List<AccessLogModel> logsToday; // today's logs (filtered from days=2)
  final List<AccessLogModel> logs; // 7-day rolling logs
  final DateTime? lastUpdated;
  final String? error;
  final int filterDays; // History filter: 1 | 3 | 7
  final String filterType; // History filter: 'All Status' | 'Entry' | 'Exit'
  final ParentModel? profile;
  final bool profileLoading;

  const DormState({
    this.status = DormStatus.initial,
    this.students = const [],
    this.logsToday = const [],
    this.logs = const [],
    this.lastUpdated,
    this.error,
    this.filterDays = 1,
    this.filterType = 'All Status',
    this.profile,
    this.profileLoading = false,
  });

  // ── Computed getters ─────────────────────────────────────────
  StudentModel? get activeStudent =>
      students.isNotEmpty ? students.first : null;

  AccessLogModel? get latestLogToday =>
      logsToday.isNotEmpty ? logsToday.first : null;

  AccessLogModel? get latestLog =>
      logs.isNotEmpty ? logs.first : null;

  int get todayInCount =>
      logsToday.where((l) => l.type == 'IN').length;

  int get todayOutCount =>
      logsToday.where((l) => l.type == 'OUT').length;

  DormState copyWith({
    DormStatus? status,
    List<StudentModel>? students,
    List<AccessLogModel>? logsToday,
    List<AccessLogModel>? logs,
    DateTime? lastUpdated,
    String? error,
    int? filterDays,
    String? filterType,
    ParentModel? profile,
    bool? profileLoading,
  }) =>
      DormState(
        status: status ?? this.status,
        students: students ?? this.students,
        logsToday: logsToday ?? this.logsToday,
        logs: logs ?? this.logs,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        error: error,
        filterDays: filterDays ?? this.filterDays,
        filterType: filterType ?? this.filterType,
        profile: profile ?? this.profile,
        profileLoading: profileLoading ?? this.profileLoading,
      );

  @override
  List<Object?> get props => [
        status,
        students,
        logsToday,
        logs,
        lastUpdated,
        error,
        filterDays,
        filterType,
        profile,
        profileLoading,
      ];
}
