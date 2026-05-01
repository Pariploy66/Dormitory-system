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
      // ── Bottom Navigation Bar (UI Redesign: Gradient & Icons) ─
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD61A22), Color(0xFFA31219)], // MFU Red gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            backgroundColor: Colors.transparent, // Transparent to show gradient
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.home_rounded), // Matched UI reference
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.access_time_rounded), // Matched UI reference
                ),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.settings_outlined), // Matched UI reference
                ),
                label: 'Setting',
              ),
            ],
          ),
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
      backgroundColor: const Color(0xFFFDFBF7), // Soft background from reference
      appBar: MfuAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            onPressed: () => ref.invalidate(studentsProvider),
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: MfuTheme.primary)),
        error: (e, _) => _ErrorView(
          message: 'Failed to load data\n${e.toString()}',
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

    final logsAsync = studentId.isNotEmpty ? ref.watch(accessLogsProvider(studentId)) : null;

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
        .where((l) => l.accessTime.day == now.day && l.accessTime.month == now.month)
        .toList();

    final yesterdayLogs = filtered
        .where((l) => l.accessTime.day == yesterday.day && l.accessTime.month == yesterday.month)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: MfuAppBar(
        actions: [
          if (studentId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              onPressed: () => ref.invalidate(accessLogsProvider(studentId)),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── White header: title + search + filters ────────────
          Container(
            color: const Color(0xFFFDFBF7),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search by gate /time',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.black38, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _FilterChip(
                      label: 'Today',
                      isActive: true, // Based on UI, today is typically active initially
                      onTap: () {}, // Modify logic if needed, left unchanged per rules
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: _filterType,
                      isActive: false,
                      hasArrow: true,
                      onTap: () => _showTypeSheet(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Log list ──────────────────────────────────────────
          Expanded(
            child: logsAsync == null
                ? const Center(child: Text('No student data found', style: TextStyle(color: Colors.grey)))
                : logsAsync.isLoading
                    ? const Center(child: CircularProgressIndicator(color: MfuTheme.primary))
                    : logsAsync.hasError
                        ? const Center(child: Text('Failed to load data', style: TextStyle(color: Colors.grey)))
                        : RefreshIndicator(
                            color: MfuTheme.primary,
                            onRefresh: () async => ref.invalidate(accessLogsProvider(studentId)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['All Status', 'Entry', 'Exit']
            .map((o) => ListTile(
                  title: Text(o),
                  trailing: _filterType == o
                      ? const Icon(Icons.check_rounded, color: MfuTheme.primary)
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
      backgroundColor: const Color(0xFFFDFBF7),
      // Optionally keeping or removing AppBar based on preference, but we'll stick to a clean top
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), 
        child: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // ── Top Bar (Setting Title + Settings Icon) ─────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Setting',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.black87),
                  onPressed: () {},
                )
              ],
            ),
            
            // ── MFU Logo (Added per requirements) ───────────────────
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/mfu_logo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ── Section header ────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Account & Security',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),

            // ── Settings Cards ────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _SettingTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () => context.push('/home/change-password'),
                  ),
                  const Divider(height: 1, indent: 50, endIndent: 20, color: Colors.black12),
                  _SettingTile(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    labelColor: const Color(0xFFD61A22), // Matching red color
                    iconColor: const Color(0xFFD61A22),
                    showChevron: false,
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(apiRepositoryProvider).logout();
              ref.invalidate(authStateProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD61A22),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.black54).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.black87),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: labelColor ?? Colors.black87,
        ),
      ),
      trailing: showChevron
          ? const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black38)
          : null,
      onTap: onTap,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Dashboard body (unchanged logic, UI redesigned to match images)
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
        .where((l) => l.accessTime.day == now.day && l.accessTime.month == now.month)
        .length;
    final latest = logs.isNotEmpty ? logs.first : null;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Profile card (UI redesigned) ────────────────────────────────────────
        _buildCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.black87,
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFA31219), // Dark red Name color
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.studentCode,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const Text(
                      'Dorm F1 room 229',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Current status card (UI redesigned) ─────────────────────────────────
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Icon(Icons.more_horiz_rounded, color: Colors.black38, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              if (latest != null) ...[
                Row(
                  children: [
                    const Text(
                      'Status : ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    const Text(
                      'on time',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Container(height: 30, width: 1, color: Colors.black12), // Divider
                    const SizedBox(width: 12),
                    Text(
                      latest.type == AccessType.IN
                          ? 'Entry : ${latest.gateName}'
                          : 'Exit : ${latest.gateName}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'update : ${DateFormat('HH.mm').format(latest.accessTime)} m',
                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ] else
                const Text(
                  'No data for today',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Red Action Button ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD61A22), Color(0xFFA31219)], // Matches Image Red gradient
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD61A22).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: () => context.push('/home/logs/${student.id}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '$todayCount entry',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Recent Activity ─────────────────────────────────────
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        if (logs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No recent activity',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          )
        else
          ...logs.take(5).map((log) => _ActivityTile(
                log: log,
                onTap: () => context.push('/home/logs/${student.id}'),
              )),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
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
    
    // Logic for borders matching image: Green for Entry, Red for Exit, Orange/Yellow for Late Entry
    final isLateEntry = _isLate(log.accessTime) && isIn;
    final borderColor = isLateEntry ? Colors.orange : (isIn ? Colors.green : Colors.red);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5), // Colored outline box
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$timeStr ${isIn ? "Entry" : "Exit"}${isLateEntry ? " (Late)" : ""}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.gateName,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 24),
          ],
        ),
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
            // Placeholder visual graphic to match "No data for today"
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5), // Light pinkish red
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.search_rounded, color: Colors.orangeAccent, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'No data for today',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (todayLogs.isNotEmpty) ...[
          const _DayHeader(label: 'Today'),
          ...todayLogs.map((l) => _HistoryTile(log: l)),
        ],
        if (yesterdayLogs.isNotEmpty) ...[
          const _DayHeader(label: 'Yesterday'),
          ...yesterdayLogs.map((l) => _HistoryTile(log: l)),
        ],
        if (todayLogs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('No data for today', style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
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
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Divider(color: Colors.black12)),
          ],
        ),
      );
}

class _HistoryTile extends StatelessWidget {
  final AccessLog log;
  const _HistoryTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final isIn = log.type == AccessType.IN;
    final timeStr = DateFormat('HH.mm').format(log.accessTime);
    
    // Bottom border color based on status
    final bottomBorderColor = isIn ? Colors.green : const Color(0xFFD61A22);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // subtle shadow and explicit colored bottom border matching image design
        border: Border(
          bottom: BorderSide(color: bottomBorderColor, width: 3),
          top: const BorderSide(color: Colors.black12, width: 0.5),
          left: const BorderSide(color: Colors.black12, width: 0.5),
          right: const BorderSide(color: Colors.black12, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          '$timeStr ${isIn ? "Entry" : "Exit"}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.gateName,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              if (isIn)
                const Text(
                  'Face Scan ✓',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
                ),
            ],
          ),
        ),
        trailing: const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.black87,
          child: Icon(Icons.person_rounded, size: 24, color: Colors.white),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Match red gradient active state or clean outline state
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFD61A22), Color(0xFFA31219)],
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.black12,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFD61A22).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
            if (hasArrow) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isActive ? Colors.white : Colors.black87,
              ),
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
            Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No student data found', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            const Text('Please contact staff for support', style: TextStyle(color: Colors.black38, fontSize: 12)),
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
              const Icon(Icons.error_outline_rounded, size: 52, color: Color(0xFFD61A22)),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFD61A22)),
              )
            ],
          ),
        ),
      );
}