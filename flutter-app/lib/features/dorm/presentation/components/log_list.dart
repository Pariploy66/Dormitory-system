import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/access_log_model.dart';
import '../../../locale/bloc/locale_bloc.dart';
import '../../../../core/l10n/strings.dart';

// ── Day-section builder ───────────────────────────────────────────────────────

/// Groups [logs] by calendar day into labelled sections.
/// [locale] is the language code ('en'|'th') for date formatting.
List<MapEntry<String, List<AccessLogModel>>> buildDaySections(
  List<AccessLogModel> logs,
  DateTime now,
  AppStrings s, {
  required String locale,
  int daysBack = 7,
}) {
  final sections = <MapEntry<String, List<AccessLogModel>>>[];
  for (var i = 0; i < daysBack; i++) {
    final day =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final label = i == 0
        ? s.today
        : i == 1
            ? s.yesterday
            : DateFormat('EEE, d MMM', locale).format(day);
    final dayLogs = logs
        .where((l) =>
            l.accessTime.year == day.year &&
            l.accessTime.month == day.month &&
            l.accessTime.day == day.day)
        .toList();
    if (dayLogs.isNotEmpty) sections.add(MapEntry(label, dayLogs));
  }
  return sections;
}

// ── LogList ───────────────────────────────────────────────────────────────────

/// Scrollable grouped list of access-log entries.
class LogList extends StatelessWidget {
  final List<MapEntry<String, List<AccessLogModel>>> sections;
  final String noDataLabel;

  const LogList({super.key, required this.sections, required this.noDataLabel});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.search_rounded,
                  color: Colors.orangeAccent, size: 40),
            ),
            const SizedBox(height: 16),
            Text(noDataLabel,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        for (final section in sections) ...[
          DayHeader(label: section.key),
          ...section.value.map((l) => HistoryTile(log: l)),
        ],
      ],
    );
  }
}

// ── DayHeader ─────────────────────────────────────────────────────────────────

class DayHeader extends StatelessWidget {
  final String label;
  const DayHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            const Expanded(child: Divider(color: Colors.black12)),
          ],
        ),
      );
}

// ── HistoryTile ───────────────────────────────────────────────────────────────

/// Single access-log row used in the History log list.
class HistoryTile extends StatelessWidget {
  final AccessLogModel log;
  const HistoryTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    final timeStr = DateFormat('HH:mm').format(log.accessTime);
    final bottomColor =
        log.isEntry ? Colors.green : const Color(0xFFD61A22);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: bottomColor, width: 3),
              top: const BorderSide(color: Colors.black12, width: 0.5),
              left: const BorderSide(color: Colors.black12, width: 0.5),
              right: const BorderSide(color: Colors.black12, width: 0.5),
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              '$timeStr ${log.isEntry ? s.entry : s.exit}',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.gateName,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  if (log.isEntry) ...[
                    const SizedBox(height: 4),
                    Text(s.faceScanLabel,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: log.isLate
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: log.isLate
                              ? Colors.orange.shade300
                              : Colors.green.shade300,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        log.isLate ? s.lateStatus : s.onTime,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: log.isLate
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black87,
              child: Icon(Icons.person_rounded,
                  size: 24, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
