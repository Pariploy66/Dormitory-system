import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/api_repository.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../theme/mfu_theme.dart';
import '../widgets/mfu_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      // ── AppBar ──────────────────────────────────────────────────
      appBar: MfuAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 20),
            onPressed: () => ref.invalidate(studentsProvider),
          ),
        ],
      ),
      // ── Bottom Nav ──────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: MfuTheme.border, width: 0.5))),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (i) {
            if (i == 2) _confirmLogout(context, ref);
          },
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

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('ออกจากระบบ',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
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

// ── Dashboard body ─────────────────────────────────────────────────────────────

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
        // Profile card
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
                  Text('Dorm F1 room 229',
                      style: const TextStyle(
                          fontSize: 11, color: MfuTheme.textSub)),
                ],
              ),
            ),
            const Icon(Icons.more_horiz_rounded,
                color: MfuTheme.textHint),
          ]),
        ),

        // Current status card
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
                      width: 8, height: 8,
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
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),

        // Recent Activity header
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 6),
          child: Text('Recent Activity',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: MfuTheme.textSub)),
        ),

        // Activity tiles
        if (logs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text('ยังไม่มีกิจกรรม',
                  style: TextStyle(
                      fontSize: 12, color: MfuTheme.textSub)),
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
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$timeStr ${isIn ? "Entry" : "Exit"}'
                  '${log.type == AccessType.IN && _isLate(log.accessTime) ? " (late)" : ""}',
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

// ── Empty / Error ──────────────────────────────────────────────────────────────

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
              Text(message, textAlign: TextAlign.center,
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
