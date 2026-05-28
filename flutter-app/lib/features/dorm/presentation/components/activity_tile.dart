import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/access_log_model.dart';
import '../../../locale/bloc/locale_bloc.dart';

/// Single latest-activity tile used on the Dashboard.
/// Tapping navigates to History tab via [onTap] callback.
class ActivityTile extends StatelessWidget {
  final AccessLogModel log;
  final VoidCallback onTap;

  const ActivityTile({super.key, required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    final timeStr = DateFormat('HH:mm').format(log.accessTime);
    final borderColor =
        log.isLate ? Colors.orange : (log.isEntry ? Colors.green : Colors.red);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$timeStr ${log.isEntry ? s.entry : s.exit}'
                    '${log.isLate ? " (${s.lateStatus})" : ""}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(log.gateName,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.black38, size: 24),
          ],
        ),
      ),
    );
  }
}
