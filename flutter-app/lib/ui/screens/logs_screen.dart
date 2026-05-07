import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/l10n.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../theme/mfu_theme.dart';
import '../widgets/mfu_app_bar.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key, required this.studentId});
  final String studentId;

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  String _searchQuery = '';
  String _filterType  = 'All Status';
  int _daysBack       = 1; // default: Today only — user can tap chip to widen range
  final _searchCtrl   = TextEditingController();
  DateTime? _lastRefreshedAt;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _periodLabel(AppStrings s) {
    if (_daysBack == 1) return s.today;
    if (_daysBack == 3) return s.last3Days;
    return s.last7Days;
  }

  void _showPeriodSheet(BuildContext ctx, AppStrings s) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(children: [
                Text(s.history,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
            ),
            const Divider(height: 1),
            ...[
              (1, s.today),
              (3, s.last3Days),
              (7, s.last7Days),
            ].map((pair) => ListTile(
                  leading: Icon(
                    pair.$1 == 1
                        ? Icons.today_rounded
                        : Icons.date_range_rounded,
                    color: _daysBack == pair.$1
                        ? MfuTheme.primary
                        : MfuTheme.textSub,
                    size: 22,
                  ),
                  title: Text(pair.$2,
                      style: TextStyle(
                          fontWeight: _daysBack == pair.$1
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _daysBack == pair.$1
                              ? MfuTheme.primary
                              : MfuTheme.textPrimary)),
                  trailing: _daysBack == pair.$1
                      ? const Icon(Icons.check_circle_rounded,
                          color: MfuTheme.primary, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _daysBack = pair.$1);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── UI — MFU style ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final students = ref.watch(studentsProvider).valueOrNull ?? [];
    final student =
        students.where((st) => st.id == widget.studentId).firstOrNull;

    // Use the today-specific provider when showing only today's data;
    // fall back to the 7-day provider for wider ranges.
    final bool isTodayView = _daysBack == 1;
    final logsAsync = isTodayView
        ? ref.watch(todayLogsProvider(widget.studentId))
        : ref.watch(accessLogsProvider(widget.studentId));

    // Update last-refreshed timestamp on each successful background poll.
    ref.listen(
      isTodayView
          ? todayLogsProvider(widget.studentId)
          : accessLogsProvider(widget.studentId),
      (_, next) {
        if (next is AsyncData) {
          setState(() => _lastRefreshedAt = DateTime.now());
        }
      },
    );

    final allLogs = logsAsync.valueOrNull ?? [];
    final now = DateTime.now();

    // For rolling-window views apply a client-side cutoff; the today view
    // already returns today-only data from the provider.
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: _daysBack - 1));

    final filtered = allLogs.where((l) {
      final inRange = isTodayView || !l.accessTime.isBefore(cutoff);
      final matchQ = _searchQuery.isEmpty ||
          l.gateName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          DateFormat('HH:mm').format(l.accessTime).contains(_searchQuery);
      final matchT = _filterType == 'All Status' ||
          (_filterType == 'Entry' && l.type == AccessType.IN) ||
          (_filterType == 'Exit' && l.type == AccessType.OUT);
      return inRange && matchQ && matchT;
    }).toList();

    final sections = _buildLogSections(filtered, now, s, daysBack: _daysBack);

    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      appBar: MfuAppBar(
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 20),
            onPressed: () => isTodayView
                ? ref.invalidate(todayLogsProvider(widget.studentId))
                : ref.invalidate(accessLogsProvider(widget.studentId)),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(color: MfuTheme.border, width: 0.5))),
        child: BottomNavigationBar(
          currentIndex: 1,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.grid_view_rounded),
                label: s.dashboard),
            BottomNavigationBarItem(
                icon: const Icon(Icons.history_rounded), label: s.history),
            BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                label: s.setting),
          ],
        ),
      ),
      body: Column(
        children: [
          // White header — title + search + filters
          Container(
            color: MfuTheme.bgCard,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        student?.name ?? s.history,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: MfuTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ● LIVE badge — indicates background auto-polling is active
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.green.shade300, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_lastRefreshedAt != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm').format(_lastRefreshedAt!),
                        style: const TextStyle(
                            fontSize: 11, color: MfuTheme.textHint),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: s.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: MfuTheme.textHint, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  // Tappable period selector — Today / Last 3 Days / Last 7 Days
                  _FilterChip(
                    label: _periodLabel(s),
                    isActive: true,
                    hasArrow: true,
                    onTap: () => _showPeriodSheet(context, s),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _filterType,
                    isActive: false,
                    hasArrow: true,
                    onTap: () => _showTypeSheet(context, s),
                  ),
                ]),
              ],
            ),
          ),

          // Log list
          Expanded(
            child: logsAsync.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: MfuTheme.primary))
                : logsAsync.hasError
                    ? Center(
                        child: Text(s.failedToLoad,
                            style:
                                const TextStyle(color: MfuTheme.textSub)))
                    : RefreshIndicator(
                        color: MfuTheme.primary,
                        onRefresh: () async => isTodayView
                            ? ref.invalidate(
                                todayLogsProvider(widget.studentId))
                            : ref.invalidate(
                                accessLogsProvider(widget.studentId)),
                        child: _LogList(
                          sections: sections,
                          noDataLabel: isTodayView
                              ? s.noActivityToday
                              : s.noData,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showTypeSheet(BuildContext ctx, AppStrings s) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ('All Status', s.allStatus),
          ('Entry', s.entry),
          ('Exit', s.exit),
        ]
            .map((pair) => ListTile(
                  title: Text(pair.$2),
                  trailing: _filterType == pair.$1
                      ? const Icon(Icons.check_rounded,
                          color: MfuTheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _filterType = pair.$1);
                    Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }
}

// [daysBack] controls how many calendar days are included (1 = today only).
List<MapEntry<String, List<AccessLog>>> _buildLogSections(
  List<AccessLog> logs,
  DateTime now,
  AppStrings s, {
  int daysBack = 7,
}) {
  final sections = <MapEntry<String, List<AccessLog>>>[];
  for (var i = 0; i < daysBack; i++) {
    final day =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final label = i == 0
        ? s.today
        : i == 1
            ? s.yesterday
            : DateFormat('EEE, d MMM').format(day);
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

// ── Filter chip ────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool hasArrow;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.hasArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? MfuTheme.primary : MfuTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? MfuTheme.primary : MfuTheme.border,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : MfuTheme.textSub)),
            if (hasArrow) ...[
              const SizedBox(width: 2),
              Icon(Icons.expand_more_rounded,
                  size: 14,
                  color: isActive
                      ? Colors.white
                      : MfuTheme.textSub),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Log list (7-day grouped view) ─────────────────────────────────────────────

class _LogList extends StatelessWidget {
  final List<MapEntry<String, List<AccessLog>>> sections;
  final String noDataLabel;

  const _LogList({required this.sections, required this.noDataLabel});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: MfuTheme.bgChip),
              child: const Icon(Icons.search_off_rounded,
                  color: MfuTheme.textHint, size: 26),
            ),
            const SizedBox(height: 12),
            Text(noDataLabel,
                style: const TextStyle(
                    fontSize: 13, color: MfuTheme.textSub)),
          ],
        ),
      );
    }

    return ListView(
      children: [
        for (final section in sections) ...[
          _DayHeader(label: section.key),
          ...section.value.map((l) => _HistoryTile(log: l)),
        ],
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
        child: Row(children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  color: MfuTheme.textHint,
                  fontWeight: FontWeight.w500,
                  letterSpacing: .5)),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ]),
      );
}

class _HistoryTile extends StatelessWidget {
  final AccessLog log;
  const _HistoryTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final isIn     = log.type == AccessType.IN;
    final timeStr  = DateFormat('HH:mm').format(log.accessTime);

    return Container(
      color: MfuTheme.bgCard,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor:
              isIn ? MfuTheme.statusInBg : MfuTheme.statusOutBg,
          child: Icon(
            isIn ? Icons.login_rounded : Icons.logout_rounded,
            size: 16,
            color: isIn ? MfuTheme.statusIn : MfuTheme.statusOut,
          ),
        ),
        title: Text(
          '$timeStr ${isIn ? "Entry" : "Exit"}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isIn ? MfuTheme.textPrimary : MfuTheme.primary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.gateName,
                style: const TextStyle(
                    fontSize: 10, color: MfuTheme.textSub)),
            if (isIn)
              const Text('Face Scan ✓',
                  style: TextStyle(
                      fontSize: 10, color: MfuTheme.statusIn)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: MfuTheme.bgChip,
              child: const Icon(Icons.person_outline_rounded,
                  size: 13, color: MfuTheme.textSub),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: MfuTheme.textHint),
          ],
        ),
      ),
    );
  }
}
