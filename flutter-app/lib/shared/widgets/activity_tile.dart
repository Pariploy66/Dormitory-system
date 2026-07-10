import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/dorm/domain/access_log_model.dart';
import '../../features/locale/bloc/locale_bloc.dart';

/// Single check-in tile used on the Dashboard.
/// Shows the scan photo, date+time (Thai BE), and gate.
/// Tapping navigates to History tab via [onTap] callback.
class ActivityTile extends StatelessWidget {
  final AccessLogModel log;
  final VoidCallback onTap;

  const ActivityTile({super.key, required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    final isTh = context.watch<LocaleBloc>().state.locale.languageCode == 'th';
    final borderColor = log.isLate ? Colors.orange : Colors.green;
    final photo = log.scanImageUrl ?? log.imageUrl;

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
            _ScanThumb(photoUrl: photo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${log.displayDateTime} ${s.entry}'
                    '${log.isLate ? " (${s.lateStatus})" : ""}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(log.displayGate(isTh),
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

/// Circular thumbnail of the gate scan photo, with a graceful fallback.
class _ScanThumb extends StatelessWidget {
  final String? photoUrl;
  const _ScanThumb({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    if (photoUrl == null || photoUrl!.isEmpty) {
      return const CircleAvatar(
        radius: size / 2,
        backgroundColor: Color(0xFFF0F0F0),
        child: Icon(Icons.person_rounded, color: Colors.black38, size: 24),
      );
    }
    return ClipOval(
      child: Image.network(
        photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const CircleAvatar(
          radius: size / 2,
          backgroundColor: Color(0xFFF0F0F0),
          child: Icon(Icons.person_rounded, color: Colors.black38, size: 24),
        ),
      ),
    );
  }
}
