import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../locale/bloc/locale_bloc.dart';
import '../../../../shared/widgets/filter_chip_widget.dart';

/// Header section of HistoryPage: title + period filter chip.
class HistoryFilterBar extends StatelessWidget {
  final String periodLabel;
  final VoidCallback onPeriodTap;

  const HistoryFilterBar({
    super.key,
    required this.periodLabel,
    required this.onPeriodTap,
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
          Text(s.history,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            children: [
              FilterChipWidget(
                label: periodLabel,
                isActive: true,
                hasArrow: true,
                onTap: onPeriodTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
