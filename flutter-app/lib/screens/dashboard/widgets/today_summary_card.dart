import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/locale/bloc/locale_bloc.dart';

/// Red gradient bar showing today's total IN / OUT counts.
class TodaySummaryCard extends StatelessWidget {
  final int inCount;
  final int outCount;
  const TodaySummaryCard(
      {super.key, required this.inCount, required this.outCount});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD61A22), Color(0xFFA31219)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD61A22).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(s.today,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const Spacer(),
          Row(children: [
            const Icon(Icons.login_rounded, size: 16, color: Colors.white70),
            const SizedBox(width: 4),
            Text('$inCount ${s.entry}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ]),
          const SizedBox(width: 16),
          Row(children: [
            const Icon(Icons.logout_rounded, size: 16, color: Colors.white70),
            const SizedBox(width: 4),
            Text('$outCount ${s.exit}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ]),
        ],
      ),
    );
  }
}
