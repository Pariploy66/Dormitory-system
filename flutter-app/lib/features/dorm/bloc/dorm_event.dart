part of 'dorm_bloc.dart';

abstract class DormEvent extends Equatable {
  const DormEvent();
  @override
  List<Object?> get props => [];
}

/// Full dashboard refresh: students + today-logs + 7-day-logs.
class DormRefreshDashboard extends DormEvent {
  const DormRefreshDashboard();
}

/// Refresh only the history log list for the current filter period.
class DormRefreshHistory extends DormEvent {
  const DormRefreshHistory();
}

/// Set the period filter for history (days: 1 | 3 | 7).
class DormSetFilterDays extends DormEvent {
  final int days;
  const DormSetFilterDays(this.days);
  @override
  List<Object?> get props => [days];
}

/// Set the type filter for history (DormState.filterType{All,Entry,Exit}:
/// 'all_status' | 'entry' | 'exit').
class DormSetFilterType extends DormEvent {
  final String filterType;
  const DormSetFilterType(this.filterType);
  @override
  List<Object?> get props => [filterType];
}

/// Load authenticated parent's profile (Account screen).
class DormFetchProfile extends DormEvent {
  const DormFetchProfile();
}

/// Clear all dorm data on logout — stops polling and resets to initial state.
/// The BLoC stays alive (it is owned by the app shell, not the screen).
class DormReset extends DormEvent {
  const DormReset();
}
