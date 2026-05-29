import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../features/dorm/domain/access_log_model.dart';
import '../../../features/locale/bloc/locale_bloc.dart';
import '../../../shared/widgets/live_badge.dart';
import '../../../shared/widgets/activity_tile.dart';

/// Recent activity section: header row with LiveBadge + latest log tile.
class RecentActivityCard extends StatelessWidget {
  final AccessLogModel? latestLog;
  final DateTime? lastUpdated;
  final VoidCallback onViewHistory;

  const RecentActivityCard({
    super.key,
    required this.latestLog,
    required this.lastUpdated,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            if (lastUpdated != null)
              Text(
                '${s.updateLabel} ${DateFormat('HH:mm').format(lastUpdated!)}',
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (latestLog == null)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(s.noData,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54)),
            ),
          )
        else
          ActivityTile(log: latestLog!, onTap: onViewHistory),
      ],
    );
  }
}
