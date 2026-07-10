import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/student_model.dart';
import '../../../locale/bloc/locale_bloc.dart';

/// Profile card showing student photo, name, code, and dorm location.
class StudentInfoCard extends StatelessWidget {
  final StudentModel student;

  /// Profile photo (รูปภาพ) from Access Control; falls back to a person icon.
  final String? photoUrl;

  const StudentInfoCard({super.key, required this.student, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final isTh =
        context.watch<LocaleBloc>().state.locale.languageCode == 'th';
    return _Card(
      child: Row(
        children: [
          _Avatar(photoUrl: photoUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.displayName(isTh),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFA31219))),
                const SizedBox(height: 4),
                Text(student.studentCode,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                if (student.locationLabel(isTh).isNotEmpty)
                  Text(student.locationLabel(isTh),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  const _Avatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    const fallback = CircleAvatar(
      radius: 28,
      backgroundColor: Colors.black87,
      child: Icon(Icons.person_rounded, color: Colors.white, size: 36),
    );
    if (photoUrl == null || photoUrl!.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        photoUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: child,
      );
}
