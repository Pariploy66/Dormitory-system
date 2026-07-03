import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/access_log_model.dart';
import '../../../locale/bloc/locale_bloc.dart';
import '../../../../shared/widgets/activity_tile.dart';

/// Recent activity section: every check-in for today, newest first.
class RecentActivityCard extends StatelessWidget {
  final List<AccessLogModel> checkIns;
  final VoidCallback onViewHistory;

  const RecentActivityCard({
    super.key,
    required this.checkIns,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.recentActivity,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87)),
        const SizedBox(height: 12),
        if (checkIns.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(s.noActivityToday,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54)),
            ),
          )
        else
          for (final log in checkIns)
            ActivityTile(log: log, onTap: onViewHistory),
      ],
    );
  }
}
