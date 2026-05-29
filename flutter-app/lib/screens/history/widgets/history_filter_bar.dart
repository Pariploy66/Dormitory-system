import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../features/locale/bloc/locale_bloc.dart';
import '../../../shared/widgets/live_badge.dart';
import '../../../shared/widgets/filter_chip_widget.dart';

/// Header section of HistoryScreen: title, LiveBadge, period/type filter chips.
class HistoryFilterBar extends StatelessWidget {
  final String periodLabel;
  final String filterType;
  final DateTime? lastUpdated;
  final VoidCallback onPeriodTap;
  final VoidCallback onTypeTap;

  const HistoryFilterBar({
    super.key,
    required this.periodLabel,
    required this.filterType,
    required this.lastUpdated,
    required this.onPeriodTap,
    required this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;

    return Container(
      color: const Color(0xFFFDFBF7),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(s.history,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87)),
              const SizedBox(width: 10),
              const LiveBadge(),
              const Spacer(),
              if (lastUpdated != null)
                Text(
                  DateFormat('HH:mm').format(lastUpdated!),
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilterChipWidget(
                label: periodLabel,
                isActive: true,
                hasArrow: true,
                onTap: onPeriodTap,
              ),
              const SizedBox(width: 10),
              FilterChipWidget(
                label: filterType,
                isActive: false,
                hasArrow: true,
                onTap: onTypeTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
