import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  // Pages are kept alive in IndexedStack — state is preserved when switching tabs
  late final List<Widget> _pages = [
    const _DashboardPage(),
    const _HistoryPage(),
    const _SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
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
            colors: [Color(0xFFD61A22), Color(0xFFA31219)],
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
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: [
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.home_rounded),
                ),
                label: s.dashboard,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.access_time_rounded),
                ),
                label: s.history,
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.settings_outlined),
                ),
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
// Custom AppBar แบบมี Logo ตามดีไซน์ (ใช้สำหรับ Dashboard และ History)
// ═══════════════════════════════════════════════════════════════════════════════

class _MfuCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const _MfuCustomAppBar({this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10, // เผื่อพื้นที่ SafeArea ด้านบน
        bottom: 15,
        left: 20,
        right: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24), // ขอบมนด้านล่างตามรูป
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
            errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MFU Dormitory',
                  style: TextStyle(
                    color: Color(0xFFC00000), // สีแดงเข้ม MFU
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Dormitory Management System',
                  style: TextStyle(
                    color: Colors.grey.shade500, // สีเทา
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
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
  /// Tracks when either log provider last delivered fresh data so we can
  /// display a human-readable "Last updated HH:mm" footer.
  DateTime? _lastRefreshedAt;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);

    // Listen to both log providers so _lastRefreshedAt updates whenever
    // background polling delivers new data (no rebuild side-effects here —
    // the setState only touches the timestamp field).
    final students = studentsAsync.valueOrNull ?? [];
    if (students.isNotEmpty) {
      ref.listen(todayLogsProvider(students.first.id), (_, next) {
        if (next is AsyncData) {
          setState(() => _lastRefreshedAt = DateTime.now());
        }
      });
      ref.listen(accessLogsProvider(students.first.id), (_, next) {
        if (next is AsyncData) {
          setState(() => _lastRefreshedAt = DateTime.now());
        }
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
  int _daysBack = 1; // default: Today only — user can tap chip to widen range
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
                        ? const Color(0xFFD61A22)
                        : Colors.black54,
                    size: 22,
                  ),
                  title: Text(pair.$2,
                      style: TextStyle(
                          fontWeight: _daysBack == pair.$1
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _daysBack == pair.$1
                              ? const Color(0xFFD61A22)
                              : Colors.black87)),
                  trailing: _daysBack == pair.$1
                      ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFFD61A22), size: 20)
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

    // When _daysBack == 1 (default "Today"), use the dedicated todayLogsProvider.
    // For wider ranges (3 / 7 days), fall back to the 7-day rolling provider.
    final bool isTodayView = _daysBack == 1;

    // Track when background polling delivers fresh data.
    if (studentId.isNotEmpty) {
      ref.listen(isTodayView ? todayLogsProvider(studentId) : accessLogsProvider(studentId),
          (_, next) {
        if (next is AsyncData) {
          setState(() => _lastRefreshedAt = DateTime.now());
        }
      });
    }

    final AsyncValue<List<AccessLog>>? logsAsync = studentId.isEmpty
        ? null
        : isTodayView
            ? ref.watch(todayLogsProvider(studentId))
            : ref.watch(accessLogsProvider(studentId));

    final allLogs = logsAsync?.valueOrNull ?? [];
    final now = DateTime.now();

    // For the rolling-window view, apply a client-side cutoff so that data
    // older than _daysBack days is never shown (defence-in-depth).
    // For the today view the provider already guarantees today-only data.
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

    final locale = ref.watch(localeProvider);
    final sections = _buildDaySections(filtered, now, s,
        locale: locale.languageCode, daysBack: _daysBack);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: _MfuCustomAppBar(
        actions: [
          if (studentId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.black54, size: 24),
              onPressed: () {
                // Invalidate whichever provider is currently active.
                if (isTodayView) {
                  ref.invalidate(todayLogsProvider(studentId));
                } else {
                  ref.invalidate(accessLogsProvider(studentId));
                }
              },
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
                // Title row — LIVE badge + last-updated time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      s.history,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade300, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
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
                    const Spacer(),
                    if (_lastRefreshedAt != null)
                      Text(
                        DateFormat('HH:mm').format(_lastRefreshedAt!),
                        style: const TextStyle(fontSize: 11, color: Colors.black38),
                      ),
                  ],
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
                    decoration: InputDecoration(
                      hintText: s.searchHint,
                      hintStyle:
                          const TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.black38, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Tappable period selector — Today / Last 3 Days / Last 7 Days
                    _FilterChip(
                      label: _periodLabel(s),
                      isActive: true,
                      hasArrow: true,
                      onTap: () => _showPeriodSheet(context, s),
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: _filterType,
                      isActive: false,
                      hasArrow: true,
                      onTap: () => _showTypeSheet(context, s),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Log list ──────────────────────────────────────────
          Expanded(
            child: logsAsync == null
                ? Center(
                    child: Text(s.noStudentLinked,
                        style: const TextStyle(color: Colors.grey)))
                : logsAsync.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: MfuTheme.primary))
                    : logsAsync.hasError
                        ? Center(
                            child: Text(s.failedToLoad,
                                style: const TextStyle(color: Colors.grey)))
                        : RefreshIndicator(
                            color: MfuTheme.primary,
                            onRefresh: () async => isTodayView
                                ? ref.invalidate(todayLogsProvider(studentId))
                                : ref.invalidate(accessLogsProvider(studentId)),
                            child: _LogList(
                              sections: sections,
                              // Show specific "no activity today" message for the
                              // default today view; generic "no data" otherwise.
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

// Builds a list of (label, logs) pairs, newest first.
// [daysBack] controls how many calendar days are included (1 = today only).
// [locale] must be passed explicitly ('en' or 'th') so DateFormat never falls
// back to Intl.defaultLocale = 'th' regardless of the user's language setting.
List<MapEntry<String, List<AccessLog>>> _buildDaySections(
  List<AccessLog> logs,
  DateTime now,
  AppStrings s, {
  required String locale,
  int daysBack = 7,
}) {
  final sections = <MapEntry<String, List<AccessLog>>>[];
  for (var i = 0; i < daysBack; i++) {
    final day = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: i));
    final label = i == 0
        ? s.today
        : i == 1
            ? s.yesterday
            : DateFormat('EEE, d MMM', locale).format(day); // explicit locale
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
// Page 3 — Setting  (Account & Security menu — logout is a button, NOT a tab)
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
            // ── Top Bar ───────────────────────────────────────────
            Text(
              s.setting,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            // ── Account & Security section ────────────────────────
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
                  // Language tile — replaces Change Password
                  _SettingTile(
                    icon: Icons.language_rounded,
                    label: s.language,
                    subtitle: isThai ? 'ภาษาไทย' : 'English',
                    onTap: () => _showLangSheet(context, ref, s, isThai),
                  ),
                  const Divider(
                      height: 1,
                      indent: 50,
                      endIndent: 20,
                      color: Colors.black12),
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

  void _showLangSheet(
      BuildContext context, WidgetRef ref, AppStrings s, bool isThai) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(s.language,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Text('🇺🇸',
                  style: TextStyle(fontSize: 24)),
              title: const Text('English',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: !isThai
                  ? const Icon(Icons.check_circle_rounded,
                      color: Color(0xFFD61A22))
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).state =
                    const Locale('en');
                Navigator.pop(sheetCtx);
              },
            ),
            ListTile(
              leading: const Text('🇹🇭',
                  style: TextStyle(fontSize: 24)),
              title: const Text('ภาษาไทย',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: isThai
                  ? const Icon(Icons.check_circle_rounded,
                      color: Color(0xFFD61A22))
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).state =
                    const Locale('th');
                Navigator.pop(sheetCtx);
              },
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(s.logoutTitle,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text(s.logoutConfirm,
            style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel,
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(apiRepositoryProvider).logout();
              ref.invalidate(authStateProvider);
              ref.invalidate(studentsProvider);
              ref.invalidate(accessLogsProvider);
              ref.invalidate(selectedStudentProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD61A22),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(s.logout),
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
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: labelColor ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(fontSize: 12, color: Colors.black45))
          : null,
      trailing: showChevron
          ? const Icon(Icons.chevron_right_rounded,
              size: 20, color: Colors.black38)
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
  final DateTime? lastRefreshedAt;
  const _DashboardBody({
    required this.students,
    required this.ref,
    this.lastRefreshedAt,
  });

  @override
  Widget build(BuildContext context) {
    final student = students.first;
    final s = ref.watch(stringsProvider);

    // accessLogsProvider → /logs?days=7 — ordered desc by accessTime.
    // Recent Activity shows logs.first: the most-recent log across all days.
    final allLogsAsync = ref.watch(accessLogsProvider(student.id));
    final allLogs      = allLogsAsync.valueOrNull ?? [];
    final latestLog    = allLogs.isNotEmpty ? allLogs.first : null;

    // todayLogsProvider → /logs/today.  Merge with today-filtered allLogs so
    // that near-midnight entries (e.g. 00:10) are never missed.
    final todayAsync = ref.watch(todayLogsProvider(student.id));
    final todayLogs  = todayAsync.valueOrNull ?? [];
    final now = DateTime.now();
    final todayFromAll = allLogs.where((l) =>
        l.accessTime.year == now.year &&
        l.accessTime.month == now.month &&
        l.accessTime.day == now.day).toList();
    final seenIds = <String>{};
    final mergedToday = [...todayLogs, ...todayFromAll]
        .where((l) => seenIds.add(l.id))
        .toList()
      ..sort((a, b) => b.accessTime.compareTo(a.accessTime));
    final latestToday = mergedToday.isNotEmpty ? mergedToday.first : null;
    final todayCount  = mergedToday.length;

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
                  Text(
                    s.currentStatus,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Icon(Icons.more_horiz_rounded, color: Colors.black38, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              if (latestToday != null) ...[
                Row(
                  children: [
                    Text(
                      s.statusLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    Text(
                      latestToday.isLate ? s.lateStatus : s.onTime,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: latestToday.isLate ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(height: 30, width: 1, color: Colors.black12),
                    const SizedBox(width: 12),
                    Text(
                      latestToday.type == AccessType.IN
                          ? '${s.entry} : ${latestToday.gateName}'
                          : '${s.exit} : ${latestToday.gateName}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${s.updateLabel} ${DateFormat('HH:mm').format(latestToday.accessTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ] else
                Text(
                  s.noActivityToday,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
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
                Text(
                  s.today,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '$todayCount ${s.entry}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Recent Activity header — LIVE badge + last-updated time ────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              s.recentActivity,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            // ● LIVE pill — shows auto-polling is active
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade300, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
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
            const Spacer(),
            // Last-updated timestamp (shown after first poll completes)
            if (lastRefreshedAt != null)
              Text(
                '${s.updateLabel} ${DateFormat('HH:mm').format(lastRefreshedAt!)}',
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
          ],
        ),
        // Single tile — the most-recent access log the API has for this student,
        // regardless of date. API returns records sorted desc by accessTime so
        // allLogs.first is always the latest event.
        const SizedBox(height: 12),

        if (latestLog == null)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                s.noData,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          )
        else
          _ActivityTile(
            log: latestLog,
            onTap: () => context.push('/home/logs/${student.id}'),
          ),
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

class _ActivityTile extends ConsumerWidget {
  final AccessLog log;
  final VoidCallback onTap;
  const _ActivityTile({required this.log, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final isIn = log.type == AccessType.IN;
    final timeStr = DateFormat('HH:mm').format(log.accessTime);

    final isLateEntry = log.isLate; // authoritative value from backend
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
                    '$timeStr ${isIn ? s.entry : s.exit}${isLateEntry ? " (${s.lateStatus})" : ""}',
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

}

// ── History log list (7-day grouped view) ─────────────────────────────────────

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
            Text(
              noDataLabel,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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

class _HistoryTile extends ConsumerWidget {
  final AccessLog log;
  const _HistoryTile({required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final isIn = log.type == AccessType.IN;
    final timeStr = DateFormat('HH.mm').format(log.accessTime);

    final isLate = log.isLate; // authoritative value from backend

    final bottomBorderColor = isIn ? Colors.green : const Color(0xFFD61A22);

    // ── Fix: Flutter forbids mixing non-uniform Border with borderRadius
    // in the same BoxDecoration — it throws a paint error and renders a
    // blank white card.  Solution: outer Container owns borderRadius +
    // shadow; ClipRRect enforces the rounded shape; inner Container holds
    // the non-uniform border without any borderRadius (valid Flutter). ──
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // rounded corners live here
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // clip child to same radius
        child: Container(
          decoration: BoxDecoration(
            // Non-uniform Border is valid here because there is NO borderRadius
            border: Border(
              bottom: BorderSide(color: bottomBorderColor, width: 3),
              top: const BorderSide(color: Colors.black12, width: 0.5),
              left: const BorderSide(color: Colors.black12, width: 0.5),
              right: const BorderSide(color: Colors.black12, width: 0.5),
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              '$timeStr ${isIn ? s.entry : s.exit}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // prevent unbounded expansion
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.gateName,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  if (isIn) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Face Scan ✓',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLate
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          // uniform border → borderRadius is safe here
                          color: isLate
                              ? Colors.orange.shade300
                              : Colors.green.shade300,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        isLate ? s.lateStatus : s.onTime,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isLate
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
              child: Icon(Icons.person_rounded, size: 24, color: Colors.white),
            ),
          ),
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
            Icon(Icons.person_search_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(s.noStudentLinked,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
            const SizedBox(height: 8),
            Text(s.noStudentLinkedSub,
                style: const TextStyle(
                    color: Colors.black38, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => ref.invalidate(studentsProvider),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(s.retry),
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD61A22)),
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