import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dorm_bloc.dart';
import '../../locale/bloc/locale_bloc.dart';
import '../../../core/theme/mfu_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ChildSelectionScreen — shown to a parent with 2+ children before the dashboard.
// Tapping a child loads that child's data; the dashboard offers "switch child"
// (Settings) to come back here.
// ═══════════════════════════════════════════════════════════════════════════════

class ChildSelectionScreen extends StatelessWidget {
  const ChildSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    final isTh = context.watch<LocaleBloc>().state.locale.languageCode == 'th';
    final students = context.watch<DormBloc>().state.students;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            Image.asset('assets/images/mfu_logo.png', height: 90),
            const SizedBox(height: 14),
            Text(
              s.selectChild,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: MfuTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.selectChildSub,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final st = students[i];
                  return _ChildCard(
                    name: st.displayName(isTh),
                    code: st.studentCode,
                    location: st.locationLabel(isTh),
                    onTap: () =>
                        context.read<DormBloc>().add(DormSelectStudent(st.id)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final String name;
  final String code;
  final String location;
  final VoidCallback onTap;

  const _ChildCard({
    required this.name,
    required this.code,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: MfuTheme.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: MfuTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(code,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                    if (location.isNotEmpty)
                      Text(location,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
