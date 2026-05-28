import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/dorm_bloc.dart';
import '../../../locale/bloc/locale_bloc.dart';
import 'live_badge.dart';
import 'activity_tile.dart';

/// Main content area of the Dashboard page.
/// Receives [state] and [onViewHistory] callback — no direct BLoC reads.
/// Company pattern: components receive data as parameters, pages own BLoC access.
class DashboardBody extends StatelessWidget {
  final DormState state;
  final VoidCallback onViewHistory;

  const DashboardBody({
    super.key,
    required this.state,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    final student = state.activeStudent!;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Profile card ────────────────────────────────────────────
        _buildCard(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.black87,
                child: Icon(Icons.person_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFA31219))),
                    const SizedBox(height: 4),
                    Text(student.studentCode,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    if (student.locationLabel.isNotEmpty)
                      Text(student.locationLabel,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Current Status card ─────────────────────────────────────
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.currentStatus,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                  const Icon(Icons.more_horiz_rounded,
                      color: Colors.black38, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              if (state.latestLogToday != null) ...[
                Row(
                  children: [
                    Text(s.statusLabel,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54)),
                    Text(
                      state.latestLogToday!.isLate
                          ? s.lateStatus
                          : s.onTime,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: state.latestLogToday!.isLate
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                        height: 30, width: 1, color: Colors.black12),
                    const SizedBox(width: 12),
                    Text(
                      state.latestLogToday!.isEntry
                          ? '${s.entry} : ${state.latestLogToday!.gateName}'
                          : '${s.exit} : ${state.latestLogToday!.gateName}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${s.updateLabel} ${DateFormat('HH:mm').format(state.latestLogToday!.accessTime)}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black38),
                ),
              ] else
                Text(s.noActivityToday,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Today summary bar ───────────────────────────────────────
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD61A22), Color(0xFFA31219)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD61A22).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(s.today,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Spacer(),
              Row(children: [
                const Icon(Icons.login_rounded,
                    size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text('${state.todayInCount} ${s.entry}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ]),
              const SizedBox(width: 16),
              Row(children: [
                const Icon(Icons.logout_rounded,
                    size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text('${state.todayOutCount} ${s.exit}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Recent Activity ─────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(s.recentActivity,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87)),
            const SizedBox(width: 8),
            const LiveBadge(),
            const Spacer(),
            if (state.lastUpdated != null)
              Text(
                '${s.updateLabel} ${DateFormat('HH:mm').format(state.lastUpdated!)}',
                style: const TextStyle(
                    fontSize: 11, color: Colors.black38),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (state.latestLog == null)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(s.noData,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54)),
            ),
          )
        else
          ActivityTile(log: state.latestLog!, onTap: onViewHistory),
      ],
    );
  }

  Widget _buildCard({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: child,
      );
}
