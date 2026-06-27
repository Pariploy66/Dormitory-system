import 'package:flutter/material.dart';
import '../../domain/student_model.dart';

/// Profile card showing student name, code, and dorm location.
class StudentInfoCard extends StatelessWidget {
  final StudentModel student;
  const StudentInfoCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return _Card(
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
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFA31219))),
                const SizedBox(height: 4),
                Text(student.studentCode,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                if (student.locationLabel.isNotEmpty)
                  Text(student.locationLabel,
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
