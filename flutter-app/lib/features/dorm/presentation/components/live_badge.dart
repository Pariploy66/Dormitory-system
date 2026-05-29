import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../locale/bloc/locale_bloc.dart';

/// Green "LIVE" indicator — shows that auto-polling is active.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    return Container(
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
                color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(s.liveLabel,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
