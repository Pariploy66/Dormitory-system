import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../locale/bloc/locale_bloc.dart';

/// Empty state shown when no student is linked to the parent account.
class EmptyView extends StatelessWidget {
  final VoidCallback onRetry;
  const EmptyView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
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
              onPressed: onRetry,
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
