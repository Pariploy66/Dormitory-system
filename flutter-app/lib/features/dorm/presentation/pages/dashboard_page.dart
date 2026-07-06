import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/dorm_bloc.dart';
import '../../../locale/bloc/locale_bloc.dart';
import '../../../../core/theme/mfu_theme.dart';
import '../../../../shared/widgets/mfu_custom_app_bar.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../components/student_info_card.dart';
import '../components/current_status_card.dart';
import '../components/today_summary_card.dart';
import '../components/recent_activity_card.dart';

/// Dashboard page — orchestrates data loading and widget composition.
/// Triggers initial DormRefreshDashboard; auto-poll is managed by DormBloc.
/// [onViewHistory] callback lets the Dashboard link to the History tab
/// without tight coupling to HomeScreen state.
class DashboardPage extends StatefulWidget {
  final VoidCallback onViewHistory;
  const DashboardPage({super.key, required this.onViewHistory});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DormBloc>().add(const DormRefreshDashboard());
  }

  @override
  Widget build(BuildContext context) {
    // Multi-child parents get a back button to return to the child picker.
    final multiChild = context.select<DormBloc, bool>(
      (b) => b.state.students.length >= 2,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: MfuCustomAppBar(
        showBack: multiChild,
        onBack: () =>
            context.read<DormBloc>().add(const DormClearSelection()),
      ),
      body: BlocBuilder<DormBloc, DormState>(
        builder: (context, state) {
          final s = context.watch<LocaleBloc>().state.strings;
          if (state.status == DormStatus.loading &&
              state.students.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: MfuTheme.primary));
          }
          if (state.status == DormStatus.failure &&
              state.students.isEmpty) {
            return ErrorView(
              message: '${s.failedToLoad}\n${state.error ?? ''}',
              retryLabel: s.retry,
              onRetry: () =>
                  context.read<DormBloc>().add(const DormRefreshDashboard()),
            );
          }
          if (state.students.isEmpty) {
            return EmptyView(
              onRetry: () =>
                  context.read<DormBloc>().add(const DormRefreshDashboard()),
            );
          }
          return RefreshIndicator(
            color: MfuTheme.primary,
            onRefresh: () async =>
                context.read<DormBloc>().add(const DormRefreshDashboard()),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              children: [
                StudentInfoCard(
                  student: state.activeStudent!,
                  // Registrar photo first; fall back to the latest gate photo.
                  photoUrl: state.activeStudent!.photoUrl ??
                      state.studentPhotoUrl,
                ),
                const SizedBox(height: 16),
                CurrentStatusCard(
                    latestLogToday: state.latestCheckInToday),
                const SizedBox(height: 16),
                TodaySummaryCard(inCount: state.todayInCount),
                const SizedBox(height: 24),
                RecentActivityCard(
                  checkIns: state.todayCheckIns,
                  onViewHistory: widget.onViewHistory,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
