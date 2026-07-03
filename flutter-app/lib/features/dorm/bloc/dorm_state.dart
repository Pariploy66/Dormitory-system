part of 'dorm_bloc.dart';

enum DormStatus { initial, loading, success, failure }

// Sentinel so copyWith can distinguish "keep" from "set to null" for
// selectedStudentId (needed to clear the selection / go back to the picker).
const Object _keep = Object();

class DormState extends Equatable {
  static const String filterTypeAll = 'all_status';
  static const String filterTypeEntry = 'entry';
  static const String filterTypeExit = 'exit';

  final DormStatus status;
  final List<StudentModel> students;
  final List<AccessLogModel> logsToday; // today's logs (filtered from days=2)
  final List<AccessLogModel> logs; // 7-day rolling logs
  final DateTime? lastUpdated;
  final String? error;
  final int filterDays; // History filter: 1 | 3 | 7
  final String filterType; // History filter code: all_status | entry | exit
  final ParentModel? profile;
  final bool profileLoading;
  final String? selectedStudentId; // chosen child (multi-child parents)

  const DormState({
    this.status = DormStatus.initial,
    this.students = const [],
    this.logsToday = const [],
    this.logs = const [],
    this.lastUpdated,
    this.error,
    this.filterDays = 1,
    this.filterType = filterTypeAll,
    this.profile,
    this.profileLoading = false,
    this.selectedStudentId,
  });

  // ── Computed getters ─────────────────────────────────────────
  /// The child currently being viewed:
  ///   - explicit selection if set,
  ///   - the only child if there is exactly one,
  ///   - null when a multi-child parent has not chosen yet (→ show picker).
  StudentModel? get activeStudent {
    if (students.isEmpty) return null;
    if (selectedStudentId != null) {
      for (final s in students) {
        if (s.id == selectedStudentId) return s;
      }
    }
    return students.length == 1 ? students.first : null;
  }

  /// Multi-child parent who has not picked a child yet.
  bool get needsChildSelection =>
      students.length >= 2 && activeStudent == null;

  AccessLogModel? get latestLogToday =>
      logsToday.isNotEmpty ? logsToday.first : null;

  AccessLogModel? get latestLog => logs.isNotEmpty ? logs.first : null;

  int get todayInCount => logsToday.where((l) => l.type == 'IN').length;

  int get todayOutCount => logsToday.where((l) => l.type == 'OUT').length;

  // ── Check-in only (we count/show arrivals, never exits) ──────
  /// All of today's check-ins (IN only), newest first.
  List<AccessLogModel> get todayCheckIns =>
      logsToday.where((l) => l.type == 'IN').toList();

  /// The most recent check-in today, or null.
  AccessLogModel? get latestCheckInToday =>
      todayCheckIns.isNotEmpty ? todayCheckIns.first : null;

  /// Student profile photo (รูปภาพ from Access Control) — taken from the most
  /// recent log that carries one; null when no log has a photo yet.
  String? get studentPhotoUrl {
    for (final l in [...logsToday, ...logs]) {
      if (l.imageUrl != null && l.imageUrl!.isNotEmpty) return l.imageUrl;
    }
    return null;
  }

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
    Object? selectedStudentId = _keep,
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
        selectedStudentId: identical(selectedStudentId, _keep)
            ? this.selectedStudentId
            : selectedStudentId as String?,
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
        selectedStudentId,
      ];
}
