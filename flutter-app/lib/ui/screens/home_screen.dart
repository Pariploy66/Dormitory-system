import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/l10n.dart';
import '../../data/api_repository.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../theme/mfu_theme.dart';

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

  late final List<Widget> _pages = [
    const _DashboardPage(),
    const _HistoryPage(),
    const _SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    // Allow Dashboard (or any widget) to switch tabs programmatically
    ref.listen(selectedTabProvider, (_, idx) {
      if (_currentIndex != idx) setState(() => _currentIndex = idx);
    });
    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD61A22), Color(0xFFA31219)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: [
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_rounded)),
                label: s.dashboard,
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.access_time_rounded)),
                label: s.history,
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.settings_outlined)),
                label: s.setting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Custom AppBar
// ═══════════════════════════════════════════════════════════════════════════════

class _MfuCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const _MfuCustomAppBar({this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 15,
        left: 20,
        right: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/mfu_logo.png',
            height: 50,
            width: 44,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MFU Dormitory',
                  style: TextStyle(color: Color(0xFFC00000), fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                ),
                Text(
                  'Dormitory Management System',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(85);
}

// ═══════════════════════════════════════════════════════════════════════════════
// Page 1 — Dashboard
// ═══════════════════════════════════════════════════════════════════════════════

class _DashboardPage extends ConsumerStatefulWidget {
  const _DashboardPage();

  @override
  ConsumerState<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<_DashboardPage> {
  /// Updated every time either log provider delivers fresh data via
  /// background polling — drives the "Updated HH:mm" indicator.
  DateTime? _lastRefreshedAt;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final students = studentsAsync.valueOrNull ?? [];

    // Listen to both providers so _lastRefreshedAt is updated on every
    // silent background poll, without causing an unnecessary full rebuild.
    if (students.isNotEmpty) {
      ref.listen(todayLogsProvider(students.first.id), (_, next) {
        if (next is AsyncData) setState(() => _lastRefreshedAt = DateTime.now());
      });
      ref.listen(accessLogsProvider(students.first.id), (_, next) {
        if (next is AsyncData) setState(() => _lastRefreshedAt = DateTime.now());
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: _MfuCustomAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54, size: 24),
            onPressed: () {
              ref.invalidate(studentsProvider);
              if (students.isNotEmpty) {
                ref.invalidate(todayLogsProvider(students.first.id));
                ref.invalidate(accessLogsProvider(students.first.id));
              }
            },
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
                onRefresh: () async {
                  ref.invalidate(todayLogsProvider(students.first.id));
                  ref.invalidate(accessLogsProvider(students.first.id));
                },
                child: _DashboardBody(
                  students: students,
                  ref: ref,
                  lastRefreshedAt: _lastRefreshedAt,
                ),
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Page 2 — History
// ═══════════════════════════════════════════════════════════════════════════════

class _HistoryPage extends ConsumerStatefulWidget {
  const _HistoryPage();

  @override
  ConsumerState<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<_HistoryPage> {
  String _searchQuery = '';
  String _filterType = 'All Status';
  int _daysBack = 7; // default: Last 7 Days
  final _searchCtrl = TextEditingController();
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(children: [
                Text(s.history, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
            ),
            const Divider(height: 1),
            ...[
              (1, s.today),
              (3, s.last3Days),
              (7, s.last7Days),
            ].map((pair) => ListTile(
                  leading: Icon(
                    pair.$1 == 1 ? Icons.today_rounded : Icons.date_range_rounded,
                    color: _daysBack == pair.$1 ? const Color(0xFFD61A22) : Colors.black54,
                    size: 22,
                  ),
                  title: Text(pair.$2,
                      style: TextStyle(
                        fontWeight: _daysBack == pair.$1 ? FontWeight.w700 : FontWeight.w500,
                        color: _daysBack == pair.$1 ? const Color(0xFFD61A22) : Colors.black87,
                      )),
                  trailing: _daysBack == pair.$1
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFFD61A22), size: 20)
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

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final students = ref.watch(studentsProvider).valueOrNull ?? [];
    final student = students.isNotEmpty ? students.first : null;
    final studentId = student?.id ?? '';

    final bool isTodayView = _daysBack == 1;

    // Always watch both providers so today's data is guaranteed to appear
    // even when accessLogsProvider is slow or has a timezone edge case.
    final AsyncValue<List<AccessLog>>? allLogsAsync = studentId.isEmpty
        ? null
        : ref.watch(accessLogsProvider(studentId));
    final AsyncValue<List<AccessLog>>? todayAsync = studentId.isEmpty
        ? null
        : ref.watch(todayLogsProvider(studentId));

    // Update LIVE timestamp whenever either provider delivers fresh data.
    if (studentId.isNotEmpty) {
      ref.listen(accessLogsProvider(studentId), (_, next) {
        if (next is AsyncData) setState(() => _lastRefreshedAt = DateTime.now());
      });
      ref.listen(todayLogsProvider(studentId), (_, next) {
        if (next is AsyncData) setState(() => _lastRefreshedAt = DateTime.now());
      });
    }

    // Merge: today's logs are always injected so History never misses them.
    final List<AccessLog> allLogs;
    if (isTodayView) {
      allLogs = todayAsync?.valueOrNull ?? [];
    } else {
      final todayLogs = todayAsync?.valueOrNull ?? [];
      final histLogs = allLogsAsync?.valueOrNull ?? [];
      final seen = <String>{};
      allLogs = [...todayLogs, ...histLogs]
          .where((l) => seen.add(l.id))
          .toList()
        ..sort((a, b) => b.accessTime.compareTo(a.accessTime));
    }

    // Primary async for loading / error states
    final primaryAsync = isTodayView ? todayAsync : allLogsAsync;

    final now = DateTime.now();

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

    final locale = ref.watch(localeProvider).languageCode;
    final sections = _buildDaySections(filtered, now, s,
        daysBack: _daysBack, locale: locale);

    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      // ── Same white top bar as Dashboard ──────────────────────────
      appBar: _MfuCustomAppBar(
        actions: [
          if (studentId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.black54, size: 24),
              onPressed: () {
                ref.invalidate(todayLogsProvider(studentId));
                ref.invalidate(accessLogsProvider(studentId));
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search + filter chips (no white card, plain background) ─
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: s.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Colors.black38, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                size: 16, color: Colors.black38),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                // Filter chips + LIVE badge
                Row(
                  children: [
                    _FilterChip(
                      label: _periodLabel(s),
                      isActive: true,
                      hasArrow: true,
                      onTap: () => _showPeriodSheet(context, s),
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: _filterType == 'All Status'
                          ? s.allStatus
                          : _filterType == 'Entry'
                              ? s.entry
                              : s.exit,
                      isActive: _filterType != 'All Status',
                      hasArrow: true,
                      onTap: () => _showTypeSheet(context, s),
                    ),
                    const Spacer(),
                    _LiveBadge(),
                    if (_lastRefreshedAt != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(_lastRefreshedAt!),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black38),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── Log list ──────────────────────────────────────────────
          Expanded(
            child: primaryAsync == null
                ? Center(
                    child: Text(s.noStudentLinked,
                        style: const TextStyle(color: Colors.black45)))
                : primaryAsync.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: MfuTheme.primary))
                    : primaryAsync.hasError
                        ? Center(
                            child: Text(s.failedToLoad,
                                style: const TextStyle(
                                    color: Colors.black45)))
                        : RefreshIndicator(
                            color: MfuTheme.primary,
                            onRefresh: () async {
                              ref.invalidate(todayLogsProvider(studentId));
                              ref.invalidate(accessLogsProvider(studentId));
                            },
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                      ? const Icon(Icons.check_rounded, color: MfuTheme.primary)
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

// ═══════════════════════════════════════════════════════════════════════════════
// Day-section builder
// ═══════════════════════════════════════════════════════════════════════════════

// Thai short day/month abbreviations
const _thDays   = {1:'จ.',2:'อ.',3:'พ.',4:'พฤ.',5:'ศ.',6:'ส.',7:'อา.'};
const _thMonths = {1:'ม.ค.',2:'ก.พ.',3:'มี.ค.',4:'เม.ย.',5:'พ.ค.',
                   6:'มิ.ย.',7:'ก.ค.',8:'ส.ค.',9:'ก.ย.',10:'ต.ค.',
                   11:'พ.ย.',12:'ธ.ค.'};

String _dayLabel(DateTime day, int i, AppStrings s, String locale) {
  if (i == 0) return s.today;
  if (i == 1) return s.yesterday;
  if (locale == 'th') {
    return '${_thDays[day.weekday]}, ${day.day} ${_thMonths[day.month]}';
  }
  return DateFormat('EEE, d MMM', 'en').format(day);
}

List<MapEntry<String, List<AccessLog>>> _buildDaySections(
  List<AccessLog> logs,
  DateTime now,
  AppStrings s, {
  int daysBack = 7,
  String locale = 'en',
}) {
  final sections = <MapEntry<String, List<AccessLog>>>[];
  for (var i = 0; i < daysBack; i++) {
    final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final label = _dayLabel(day, i, s, locale);
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

// ═══════════════════════════════════════════════════════════════════════════════
// Page 3 — Setting
// ═══════════════════════════════════════════════════════════════════════════════

class _SettingPage extends ConsumerWidget {
  const _SettingPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final locale = ref.watch(localeProvider);
    final isThai = locale.languageCode == 'th';

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            Text(s.setting,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87)),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Account & Security',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _SettingTile(
                    icon: Icons.language_rounded,
                    label: s.language,
                    subtitle: isThai ? 'ภาษาไทย' : 'English',
                    onTap: () => _showLangSheet(context, ref, s, isThai),
                  ),
                  const Divider(height: 1, indent: 50, endIndent: 20, color: Colors.black12),
                  _SettingTile(
                    icon: Icons.logout_rounded,
                    label: s.logout,
                    labelColor: const Color(0xFFD61A22),
                    iconColor: const Color(0xFFD61A22),
                    showChevron: false,
                    onTap: () => _confirmLogout(context, ref, s),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLangSheet(BuildContext context, WidgetRef ref, AppStrings s, bool isThai) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(s.language, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: !isThai ? const Icon(Icons.check_circle_rounded, color: Color(0xFFD61A22)) : null,
              onTap: () { ref.read(localeProvider.notifier).state = const Locale('en'); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: const Text('🇹🇭', style: TextStyle(fontSize: 24)),
              title: const Text('ภาษาไทย', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: isThai ? const Icon(Icons.check_circle_rounded, color: Color(0xFFD61A22)) : null,
              onTap: () { ref.read(localeProvider.notifier).state = const Locale('th'); Navigator.pop(ctx); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, AppStrings s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(s.logoutTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text(s.logoutConfirm, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(apiRepositoryProvider).logout();
              ref.invalidate(authStateProvider);
              ref.invalidate(studentsProvider);
              ref.invalidate(selectedStudentProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD61A22),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(s.logout),
          ),
        ],
      ),
    );
  }
}

// ── Setting tile ──────────────────────────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final Color? iconColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.labelColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.black54).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.black87),
      ),
      title: Text(label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: labelColor ?? Colors.black87)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.black45))
          : null,
      trailing: showChevron ? const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black38) : null,
      onTap: onTap,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Dashboard body
// ═══════════════════════════════════════════════════════════════════════════════

class _DashboardBody extends StatelessWidget {
  final List<Student> students;
  final WidgetRef ref;
  final DateTime? lastRefreshedAt;

  const _DashboardBody({
    required this.students,
    required this.ref,
    this.lastRefreshedAt,
  });

  @override
  Widget build(BuildContext context) {
    final student = students.first;
    final s       = ref.watch(stringsProvider);
    final locale  = ref.watch(localeProvider).languageCode;

    // ── todayLogsProvider → today count & current status ──────────────────────
    // Uses /logs?days=2 + client filter → only today's records.
    final todayAsync = ref.watch(todayLogsProvider(student.id));
    final todayLogs = todayAsync.valueOrNull ?? [];
    final latestToday = todayLogs.isNotEmpty ? todayLogs.first : null;
    final todayCount = todayLogs.length;

    // ── accessLogsProvider → SINGLE most-recent record (Recent Activity) ──────
    // Returns up to 7 days sorted newest-first; we display only [0].
    final allLogsAsync = ref.watch(accessLogsProvider(student.id));
    final allLogs = allLogsAsync.valueOrNull ?? [];
    final latestLog = allLogs.isNotEmpty ? allLogs.first : null;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Profile card ───────────────────────────────────────────────────────
        _buildCard(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.black87,
                child: Icon(Icons.person_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFA31219))),
                    const SizedBox(height: 4),
                    Text(student.studentCode,
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const Text('Dorm F1 room 229',
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Current status card (uses today's logs only) ───────────────────────
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.currentStatus,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                  const Icon(Icons.more_horiz_rounded, color: Colors.black38, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              if (latestToday != null) ...[
                Row(
                  children: [
                    Text('${s.statusLabel} ',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                    // late = entry after 22:00
                    Text(
                      _isLateEntry(latestToday) ? s.lateStatus : s.onTime,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _isLateEntry(latestToday) ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(height: 30, width: 1, color: Colors.black12),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        latestToday.type == AccessType.IN
                            ? '${s.entry} : ${latestToday.gateName}'
                            : '${s.exit} : ${latestToday.gateName}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${s.updateLabel} ${DateFormat('HH:mm').format(latestToday.accessTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ] else
                Text(s.noActivityToday,
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Today entry count button ───────────────────────────────────────────
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFD61A22), Color(0xFFA31219)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: const Color(0xFFD61A22).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: ElevatedButton(
            onPressed: () =>
                ref.read(selectedTabProvider.notifier).state = 1,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.today, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('$todayCount ${s.entryLabel}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Recent Activity header — LIVE badge + last-updated time ────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(s.recentActivity,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
            const SizedBox(width: 8),
            _LiveBadge(),
            const Spacer(),
            if (lastRefreshedAt != null)
              Text('${s.updatedAt} ${DateFormat('HH:mm').format(lastRefreshedAt!)}',
                  style: const TextStyle(fontSize: 11, color: Colors.black38)),
          ],
        ),
        // ── ONE tile — absolute latest log from API (any day) ──────────────────
        const SizedBox(height: 12),
        if (latestLog == null)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Text(s.noRecentActivity, style: const TextStyle(fontSize: 14, color: Colors.black54))),
          )
        else
          _ActivityTile(
            log: latestLog,
            locale: locale,
            onTap: () =>
                ref.read(selectedTabProvider.notifier).state = 1,
          ),
      ],
    );
  }

  bool _isLateEntry(AccessLog log) => log.type == AccessType.IN && log.accessTime.hour >= 22;

  Widget _buildCard({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: child,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════════════════════════════════

/// Green ● LIVE badge — indicates background polling is active.
class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            const Text('LIVE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green, letterSpacing: 0.5)),
          ],
        ),
      );
}

class _ActivityTile extends StatelessWidget {
  final AccessLog log;
  final VoidCallback onTap;
  final String locale;

  const _ActivityTile({
    required this.log,
    required this.onTap,
    this.locale = 'en',
  });

  /// วันที่แบบ localize: วันนี้/Today, เมื่อวาน/Yesterday, หรือ วัน/เดือน
  String _dateLabel(DateTime t) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff  = today.difference(DateTime(t.year, t.month, t.day)).inDays;

    if (locale == 'th') {
      if (diff == 0) return 'วันนี้';
      if (diff == 1) return 'เมื่อวาน';
      return '${_thDays[t.weekday]}, ${t.day} ${_thMonths[t.month]}';
    } else {
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      return DateFormat('EEE, d MMM', 'en').format(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIn        = log.type == AccessType.IN;
    final timeStr     = DateFormat('HH:mm').format(log.accessTime);
    final isLateEntry = log.accessTime.hour >= 22 && isIn;
    final borderColor =
        isLateEntry ? Colors.orange : (isIn ? Colors.green : Colors.red);
    final typeLabel   = isIn
        ? (locale == 'th' ? 'เข้า' : 'Entry')
        : (locale == 'th' ? 'ออก' : 'Exit');
    final lateLabel   =
        isLateEntry ? (locale == 'th' ? ' (สาย)' : ' (Late)') : '';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
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
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // ── Type icon ──────────────────────────────────────────
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  isIn ? Colors.green.shade50 : Colors.red.shade50,
              child: Icon(
                isIn ? Icons.login_rounded : Icons.logout_rounded,
                size: 20,
                color: isIn ? Colors.green : const Color(0xFFD61A22),
              ),
            ),
            const SizedBox(width: 12),
            // ── Text info ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time + type
                  Text(
                    '$timeStr  $typeLabel$lateLabel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isIn ? Colors.black87 : const Color(0xFFD61A22),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Gate name
                  Text(
                    log.gateName,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 3),
                  // ── Date label (localized) ──────────────────────
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 10, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        _dateLabel(log.accessTime),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black38),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── History log list ──────────────────────────────────────────────────────────

class _LogList extends StatelessWidget {
  final List<MapEntry<String, List<AccessLog>>> sections;
  final String noDataLabel;
  const _LogList({required this.sections, required this.noDataLabel});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.expand();

    return ListView(
      children: [
        for (final section in sections) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: _DayHeader(
                label: section.key, count: section.value.length),
          ),
          ...section.value.expand((l) => [
                _HistoryTile(log: l),
                const Divider(height: 1, indent: 16, endIndent: 16),
              ]),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  final int count;
  const _DayHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            const Expanded(child: Divider(color: Colors.black12)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                    fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class _HistoryTile extends ConsumerWidget {
  final AccessLog log;
  const _HistoryTile({required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s       = ref.watch(stringsProvider);
    final isIn    = log.type == AccessType.IN;
    final timeStr = DateFormat('HH:mm').format(log.accessTime);

    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isIn
              ? Colors.green.shade50
              : Colors.red.shade50,
          child: Icon(
            isIn ? Icons.login_rounded : Icons.logout_rounded,
            size: 18,
            color: isIn ? Colors.green : const Color(0xFFD61A22),
          ),
        ),
        title: Text(
          '$timeStr  ${isIn ? s.entry : s.exit}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isIn ? Colors.black87 : const Color(0xFFD61A22),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.gateName,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54)),
            if (isIn)
              const Text('Face Scan ✓',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green)),
          ],
        ),
        trailing: const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFFF0F0F0),
          child: Icon(Icons.person_outline_rounded,
              size: 15, color: Colors.black45),
        ),
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

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
          gradient: isActive ? const LinearGradient(colors: [Color(0xFFD61A22), Color(0xFFA31219)]) : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.transparent : Colors.black12, width: 1),
          boxShadow: isActive
              ? [BoxShadow(color: const Color(0xFFD61A22).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.black87)),
            if (hasArrow) ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: isActive ? Colors.white : Colors.black87),
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

class _EmptyView extends ConsumerWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(s.noStudentLinked,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(s.noStudentLinkedSub,
                style: const TextStyle(color: Colors.black38, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => ref.invalidate(studentsProvider),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(s.retry),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFD61A22)),
            ),
          ],
        ),
      ),
    );
  }
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
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFD61A22)),
              ),
            ],
          ),
        ),
      );
}
