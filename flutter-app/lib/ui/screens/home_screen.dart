import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/api_repository.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../theme/mfu_theme.dart';
import '../widgets/mfu_app_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// HomeScreen — Shell with working IndexedStack bottom navigation
// ═══════════════════════════════════════════════════════════════════════════════

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  // Pages are kept alive in IndexedStack — state is preserved when switching tabs
  late final List<Widget> _pages = [
    const _DashboardPage(),
    const _HistoryPage(),
    const _SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      // ── IndexedStack preserves each page's scroll/state ──────
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // ── Bottom Navigation Bar ────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: MfuTheme.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: MfuTheme.primary,
          unselectedItemColor: MfuTheme.textHint,
          backgroundColor: MfuTheme.bgCard,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Page 1 — Dashboard
// ═══════════════════════════════════════════════════════════════════════════════

class _DashboardPage extends ConsumerWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      appBar: MfuAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 20),
            onPressed: () => ref.invalidate(studentsProvider),
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: MfuTheme.primary)),
        error: (e, _) => _ErrorView(
          message: 'ไม่สามารถโหลดข้อมูลได้',
          onRetry: () => ref.invalidate(studentsProvider),
        ),
        data: (students) => students.isEmpty
            ? const _EmptyView()
            : RefreshIndicator(
                color: MfuTheme.primary,
                onRefresh: () async => ref.invalidate(studentsProvider),
                child: _DashboardBody(students: students, ref: ref),
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Page 2 — History  (full log list, same logic as LogsScreen but tab-embedded)
// ═══════════════════════════════════════════════════════════════════════════════

class _HistoryPage extends ConsumerStatefulWidget {
  const _HistoryPage();

  @override
  ConsumerState<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<_HistoryPage> {
  String _searchQuery = '';
  String _filterType = 'All Status';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(studentsProvider).valueOrNull ?? [];
    final student = students.isNotEmpty ? students.first : null;
    final studentId = student?.id ?? '';

    final logsAsync =
        studentId.isNotEmpty ? ref.watch(accessLogsProvider(studentId)) : null;

    final allLogs = logsAsync?.valueOrNull ?? [];
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final filtered = allLogs.where((l) {
      final matchQ = _searchQuery.isEmpty ||
          l.gateName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          DateFormat('HH:mm').format(l.accessTime).contains(_searchQuery);
      final matchT = _filterType == 'All Status' ||
          (_filterType == 'Entry' && l.type == AccessType.IN) ||
          (_filterType == 'Exit' && l.type == AccessType.OUT);
      return matchQ && matchT;
    }).toList();

    final todayLogs = filtered
        .where((l) =>
            l.accessTime.day == now.day &&
            l.accessTime.month == now.month)
        .toList();

    final yesterdayLogs = filtered
        .where((l) =>
            l.accessTime.day == yesterday.day &&
            l.accessTime.month == yesterday.month)
        .toList();

    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      appBar: MfuAppBar(
        actions: [
          if (studentId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 20),
              onPressed: () =>
                  ref.invalidate(accessLogsProvider(studentId)),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── White header: title + search + filters ────────────
          Container(
            color: MfuTheme.bgCard,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'History',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: MfuTheme.textPrimary),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search by gate / time',
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

          // ── Log list ──────────────────────────────────────────
          Expanded(
            child: logsAsync == null
                ? const Center(
                    child: Text('ไม่พบข้อมูลนักศึกษา',
                        style: TextStyle(color: MfuTheme.textSub)))
                : logsAsync.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: MfuTheme.primary))
                    : logsAsync.hasError
                        ? const Center(
                            child: Text('Failed to load data',
                                style:
                                    TextStyle(color: MfuTheme.textSub)))
                        : RefreshIndicator(
                            color: MfuTheme.primary,
                            onRefresh: () async =>
                                ref.invalidate(accessLogsProvider(studentId)),
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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
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

// ═══════════════════════════════════════════════════════════════════════════════
// Page 3 — Setting  (Account & Security menu — logout is a button, NOT a tab)
// ═══════════════════════════════════════════════════════════════════════════════

class _SettingPage extends ConsumerWidget {
  const _SettingPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      appBar: MfuAppBar(),
      body: ListView(
        children: [
          // ── Title ─────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Setting',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: MfuTheme.textPrimary),
            ),
          ),

          // ── Section header ────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: Text(
              'Account & Security',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: MfuTheme.textSub,
                  letterSpacing: .4),
            ),
          ),

          // ── Change Password ───────────────────────────────────
          _SettingTile(
            icon: Icons.lock_outline_rounded,
            label: 'Change Password',
            onTap: () => context.push('/home/change-password'),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 8),

          // ── Logout — standalone action, NOT a nav tap ─────────
          _SettingTile(
            icon: Icons.logout_rounded,
            label: 'Logout',
            labelColor: MfuTheme.primary,
            iconColor: MfuTheme.primary,
            showChevron: false,
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('ออกจากระบบ',
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('ต้องการออกจากระบบใช่หรือไม่?',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก',
                style: TextStyle(color: MfuTheme.textSub)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(apiRepositoryProvider).logout();
              ref.invalidate(authStateProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MfuTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }
}

// ── Setting tile helper ────────────────────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final Color? iconColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MfuTheme.bgCard,
      child: ListTile(
        leading: Icon(icon,
            size: 20, color: iconColor ?? MfuTheme.textSub),
        title: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: labelColor ?? MfuTheme.textPrimary)),
        trailing: showChevron
            ? const Icon(Icons.chevron_right_rounded,
                size: 18, color: MfuTheme.textHint)
            : null,
        onTap: onTap,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Dashboard body (unchanged logic, extracted from old HomeScreen)
// ═══════════════════════════════════════════════════════════════════════════════

class _DashboardBody extends StatelessWidget {
  final List<Student> students;
  final WidgetRef ref;
  const _DashboardBody({required this.students, required this.ref});

  @override
  Widget build(BuildContext context) {
    final student = students.first;
    final logsAsync = ref.watch(accessLogsProvider(student.id));
    final logs = logsAsync.valueOrNull ?? [];
    final now = DateTime.now();
    final todayCount = logs
        .where((l) =>
            l.accessTime.day == now.day &&
            l.accessTime.month == now.month)
        .length;
    final latest = logs.isNotEmpty ? logs.first : null;

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        // ── Profile card ────────────────────────────────────────
        _buildCard(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: MfuTheme.bgChip,
              child: const Icon(Icons.person_outline_rounded,
                  color: MfuTheme.textSub, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MfuTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(student.studentCode,
                      style: const TextStyle(
                          fontSize: 11, color: MfuTheme.textSub)),
                  const Text('Dorm F1 room 229',
                      style: TextStyle(
                          fontSize: 11, color: MfuTheme.textSub)),
                ],
              ),
            ),
            const Icon(Icons.more_horiz_rounded,
                color: MfuTheme.textHint),
          ]),
        ),

        // ── Current status card ─────────────────────────────────
        _buildCard(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Current status',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MfuTheme.textPrimary)),
                const Spacer(),
                const Icon(Icons.more_horiz_rounded,
                    color: MfuTheme.textHint, size: 18),
              ]),
              const SizedBox(height: 10),
              if (latest != null) ...[
                Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: MfuTheme.green)),
                  const SizedBox(width: 6),
                  const Text('Status : on time',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MfuTheme.green)),
                  const Spacer(),
                  Text(
                      latest.type == AccessType.IN
                          ? 'Entry - ${latest.gateName}'
                          : 'Exit - ${latest.gateName}',
                      style: const TextStyle(
                          fontSize: 10, color: MfuTheme.textSub)),
                ]),
                const SizedBox(height: 3),
                Text(
                    'update: ${DateFormat('HH:mm').format(latest.accessTime)} m',
                    style: const TextStyle(
                        fontSize: 10, color: MfuTheme.textHint)),
              ] else
                const Text('ยังไม่มีข้อมูลวันนี้',
                    style: TextStyle(
                        fontSize: 12, color: MfuTheme.textSub)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () =>
                      context.push('/home/logs/${student.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MfuTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Today     $todayCount entry',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),

        // ── Recent Activity ─────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 6),
          child: Text('Recent Activity',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: MfuTheme.textSub)),
        ),

        if (logs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text('ยังไม่มีกิจกรรม',
                  style:
                      TextStyle(fontSize: 12, color: MfuTheme.textSub)),
            ),
          )
        else
          ...logs.take(5).map((log) => _ActivityTile(
                log: log,
                onTap: () =>
                    context.push('/home/logs/${student.id}'),
              )),
      ],
    );
  }

  Widget _buildCard(
      {required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MfuTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MfuTheme.border, width: 0.5),
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared widgets (Activity tile, Log list, Filter chip, Empty/Error)
// ═══════════════════════════════════════════════════════════════════════════════

class _ActivityTile extends StatelessWidget {
  final AccessLog log;
  final VoidCallback onTap;
  const _ActivityTile({required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIn = log.type == AccessType.IN;
    final timeStr = DateFormat('HH:mm').format(log.accessTime);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: MfuTheme.bgCard,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$timeStr ${isIn ? "Entry" : "Exit"}'
                  '${isIn && _isLate(log.accessTime) ? " (late)" : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isLate(log.accessTime) && isIn
                        ? MfuTheme.primary
                        : MfuTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(log.gateName,
                    style: const TextStyle(
                        fontSize: 10, color: MfuTheme.textSub)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: MfuTheme.textHint, size: 18),
        ]),
      ),
    );
  }

  bool _isLate(DateTime t) => t.hour >= 22;
}

// ── History log list ───────────────────────────────────────────────────────────

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
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: MfuTheme.bgChip),
              child: const Icon(Icons.search_off_rounded,
                  color: MfuTheme.textHint, size: 26),
            ),
            const SizedBox(height: 12),
            const Text('No data for today',
                style:
                    TextStyle(fontSize: 13, color: MfuTheme.textSub)),
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
    final isIn = log.type == AccessType.IN;
    final timeStr = DateFormat('HH:mm').format(log.accessTime);

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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                  color:
                      isActive ? Colors.white : MfuTheme.textSub),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Empty / Error helpers
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('ยังไม่มีนักศึกษาที่เชื่อมกับบัญชีนี้',
                style: TextStyle(color: MfuTheme.textSub)),
            const SizedBox(height: 6),
            const Text('กรุณาติดต่อเจ้าหน้าที่หอพัก',
                style: TextStyle(
                    color: MfuTheme.textHint, fontSize: 12)),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 52, color: MfuTheme.primary),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: MfuTheme.textSub)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                    backgroundColor: MfuTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
      );
}
