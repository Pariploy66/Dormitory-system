import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/dorm/bloc/dorm_bloc.dart';
import '../../core/theme/mfu_theme.dart';
import '../../shared/widgets/mfu_custom_app_bar.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/student_info_card.dart';
import 'widgets/current_status_card.dart';
import 'widgets/today_summary_card.dart';
import 'widgets/recent_activity_card.dart';

/// Dashboard screen — orchestrates data loading and widget composition.
/// Triggers initial DormRefreshDashboard; auto-poll is managed by DormBloc.
/// [onViewHistory] callback lets the Dashboard link to the History tab
/// without tight coupling to HomeScreen state.
class DashboardScreen extends StatefulWidget {
  final VoidCallback onViewHistory;
  const DashboardScreen({super.key, required this.onViewHistory});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DormBloc>().add(const DormRefreshDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: MfuCustomAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.black54, size: 24),
            onPressed: () =>
                context.read<DormBloc>().add(const DormRefreshDashboard()),
          ),
        ],
      ),
      body: BlocBuilder<DormBloc, DormState>(
        builder: (context, state) {
          if (state.status == DormStatus.loading &&
              state.students.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: MfuTheme.primary));
          }
          if (state.status == DormStatus.failure &&
              state.students.isEmpty) {
            return ErrorView(
              message: 'Failed to load data\n${state.error ?? ''}',
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
                StudentInfoCard(student: state.activeStudent!),
                const SizedBox(height: 16),
                CurrentStatusCard(
                    latestLogToday: state.latestLogToday),
                const SizedBox(height: 16),
                TodaySummaryCard(
                    inCount: state.todayInCount,
                    outCount: state.todayOutCount),
                const SizedBox(height: 24),
                RecentActivityCard(
                  latestLog: state.latestLog,
                  lastUpdated: state.lastUpdated,
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
