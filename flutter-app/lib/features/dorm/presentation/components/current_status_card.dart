import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/access_log_model.dart';
import '../../../locale/bloc/locale_bloc.dart';

/// Card showing the student's latest access log status for today.
class CurrentStatusCard extends StatelessWidget {
  final AccessLogModel? latestLogToday;
  const CurrentStatusCard({super.key, required this.latestLogToday});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    final isTh = context.watch<LocaleBloc>().state.locale.languageCode == 'th';

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.currentStatus,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 20),
          if (latestLogToday != null) ...[
            Row(
              children: [
                Text(s.statusLabel,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
                Text(
                  latestLogToday!.isLate ? s.lateStatus : s.onTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: latestLogToday!.isLate
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Container(height: 30, width: 1, color: Colors.black12),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${s.entry} : ${latestLogToday!.displayGate(isTh)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ] else
            Text(s.noActivityToday,
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}
