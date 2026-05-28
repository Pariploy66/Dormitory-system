import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/dorm_bloc.dart';
import '../../../../core/theme/mfu_theme.dart';
import '../components/mfu_custom_app_bar.dart';
import '../components/dashboard_body.dart';
import '../components/empty_view.dart';
import '../components/error_view.dart';

/// Dashboard page — orchestrates data loading and component composition.
/// Timer.periodic dispatches DormRefreshDashboard every 30 s (company pattern).
/// [onViewHistory] callback lets the Dashboard link to the History tab
/// without tight coupling to HomeScreen state.
class DashboardPage extends StatefulWidget {
  final VoidCallback onViewHistory;
  const DashboardPage({super.key, required this.onViewHistory});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    context.read<DormBloc>().add(const DormRefreshDashboard());
    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) => context.read<DormBloc>().add(const DormRefreshDashboard()),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
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
            child: DashboardBody(
              state: state,
              onViewHistory: widget.onViewHistory,
            ),
          );
        },
      ),
    );
  }
}
