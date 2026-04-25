import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  // ── Logic unchanged ───────────────────────────────────────────
  String _searchQuery = '';
  String _filterType  = 'All Status';
  final _searchCtrl   = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── UI — MFU style ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(accessLogsProvider(widget.studentId));
    final students  = ref.watch(studentsProvider).valueOrNull ?? [];
    final student   = students.where((s) => s.id == widget.studentId).firstOrNull;

    final allLogs = logsAsync.valueOrNull ?? [];
    final filtered = allLogs.where((l) {
      final matchQ = _searchQuery.isEmpty ||
          l.gateName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          DateFormat('HH:mm').format(l.accessTime).contains(_searchQuery);
      final matchT = _filterType == 'All Status' ||
          (_filterType == 'Entry' && l.type == AccessType.IN) ||
          (_filterType == 'Exit'  && l.type == AccessType.OUT);
      return matchQ && matchT;
    }).toList();

    final now       = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final todayLogs = filtered.where((l) =>
        l.accessTime.day   == now.day &&
        l.accessTime.month == now.month).toList();

    final yesterdayLogs = filtered.where((l) =>
        l.accessTime.day   == yesterday.day &&
        l.accessTime.month == yesterday.month).toList();

    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      appBar: MfuAppBar(
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 20),
            onPressed: () =>
                ref.invalidate(accessLogsProvider(widget.studentId)),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: MfuTheme.border, width: 0.5))),
        child: BottomNavigationBar(
          currentIndex: 1,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded), label: 'Setting'),
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
                Text(student?.name ?? 'History',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: MfuTheme.textPrimary)),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search by gate /time',
                    prefixIcon: Icon(Icons.search_rounded,
                        color: MfuTheme.textHint, size: 18),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  _FilterChip(
                    label: 'Today',
                    isActive: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _filterType,
                    isActive: false,
                    hasArrow: true,
                    onTap: () => _showTypeSheet(context),
                  ),
                ]),
              ],
            ),
          ),

          // Log list
          Expanded(
            child: logsAsync.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: MfuTheme.primary))
                : logsAsync.hasError
                    ? Center(
                        child: Text('ไม่สามารถโหลดข้อมูลได้',
                            style: const TextStyle(
                                color: MfuTheme.textSub)))
                    : RefreshIndicator(
                        color: MfuTheme.primary,
                        onRefresh: () async => ref
                            .invalidate(accessLogsProvider(widget.studentId)),
                        child: _LogList(
                          todayLogs: todayLogs,
                          yesterdayLogs: yesterdayLogs,
                          allLogs: filtered,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showTypeSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['All Status', 'Entry', 'Exit']
            .map((o) => ListTile(
                  title: Text(o),
                  trailing: _filterType == o
                      ? const Icon(Icons.check_rounded,
                          color: MfuTheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _filterType = o);
                    Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }
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

// ── Log list ───────────────────────────────────────────────────────────────────

class _LogList extends StatelessWidget {
  final List<AccessLog> todayLogs;
  final List<AccessLog> yesterdayLogs;
  final List<AccessLog> allLogs;

  const _LogList({
    required this.todayLogs,
    required this.yesterdayLogs,
    required this.allLogs,
  });

  @override
  Widget build(BuildContext context) {
    if (allLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: MfuTheme.bgChip),
              child: const Icon(Icons.search_off_rounded,
                  color: MfuTheme.textHint, size: 26),
            ),
            const SizedBox(height: 12),
            const Text('No data for today',
                style: TextStyle(
                    fontSize: 13, color: MfuTheme.textSub)),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (todayLogs.isNotEmpty) ...[
          _DayHeader(label: 'Today'),
          ...todayLogs.map((l) => _HistoryTile(log: l)),
        ],
        if (yesterdayLogs.isNotEmpty) ...[
          _DayHeader(label: 'Yesterday'),
          ...yesterdayLogs.map((l) => _HistoryTile(log: l)),
        ],
        if (todayLogs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(children: [
                Icon(Icons.search_off_rounded,
                    size: 36, color: MfuTheme.textHint),
                SizedBox(height: 8),
                Text('No data for today',
                    style: TextStyle(
                        fontSize: 12, color: MfuTheme.textSub)),
              ]),
            ),
          ),
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
