import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/dorm_bloc.dart';
import '../../../locale/bloc/locale_bloc.dart';
import '../../../../core/l10n/strings.dart';
import '../../../../core/theme/mfu_theme.dart';
import '../../../../shared/widgets/mfu_custom_app_bar.dart';
import '../../../../shared/widgets/log_list.dart';
import '../components/history_filter_bar.dart';

/// History page — displays paginated access logs with period + type filters.
/// Auto-poll is managed by DormBloc (30-second Timer.periodic).
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  void _showPeriodSheet(
      BuildContext ctx, AppStrings s, int currentDays) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(children: [
                Text(s.history,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
            ),
            const Divider(height: 1),
            ...[
              (1, s.today),
              (3, s.last3Days),
              (7, s.last7Days),
            ].map((pair) => ListTile(
                  leading: Icon(
                    pair.$1 == 1
                        ? Icons.today_rounded
                        : Icons.date_range_rounded,
                    color: currentDays == pair.$1
                        ? const Color(0xFFD61A22)
                        : Colors.black54,
                    size: 22,
                  ),
                  title: Text(pair.$2,
                      style: TextStyle(
                          fontWeight: currentDays == pair.$1
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: currentDays == pair.$1
                              ? const Color(0xFFD61A22)
                              : Colors.black87)),
                  trailing: currentDays == pair.$1
                      ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFFD61A22), size: 20)
                      : null,
                  onTap: () {
                    ctx
                        .read<DormBloc>()
                        .add(DormSetFilterDays(pair.$1));
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTypeSheet(
      BuildContext ctx, AppStrings s, String currentType) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (DormState.filterTypeAll, s.allStatus),
          (DormState.filterTypeEntry, s.entry),
          (DormState.filterTypeExit, s.exit),
        ]
            .map((pair) => ListTile(
                  title: Text(pair.$2),
                  trailing: currentType == pair.$1
                      ? const Icon(Icons.check_rounded,
                          color: MfuTheme.primary)
                      : null,
                  onTap: () {
                    ctx
                        .read<DormBloc>()
                        .add(DormSetFilterType(pair.$1));
                    Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    final locale = context.watch<LocaleBloc>().state.locale;

    return BlocBuilder<DormBloc, DormState>(
      builder: (context, state) {
        final studentId = state.activeStudent?.id ?? '';
        final isTodayView = state.filterDays == 1;
        final now = DateTime.now();

        final sourceLogs =
            isTodayView ? state.logsToday : state.logs;

        final cutoff = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: state.filterDays - 1));

        final filtered = sourceLogs.where((l) {
          final inRange =
              isTodayView || !l.accessTime.isBefore(cutoff);
          final matchT = state.filterType == DormState.filterTypeAll ||
              (state.filterType == DormState.filterTypeEntry && l.isEntry) ||
              (state.filterType == DormState.filterTypeExit && l.isExit);
          return inRange && matchT;
        }).toList();

        final sections = buildDaySections(
          filtered,
          now,
          s,
          locale: locale.languageCode,
          daysBack: state.filterDays,
        );

        String periodLabel() {
          if (state.filterDays == 1) return s.today;
          if (state.filterDays == 3) return s.last3Days;
          return s.last7Days;
        }

        String typeLabel() {
          switch (state.filterType) {
            case DormState.filterTypeEntry:
              return s.entry;
            case DormState.filterTypeExit:
              return s.exit;
            default:
              return s.allStatus;
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFDFBF7),
          appBar: MfuCustomAppBar(
            actions: [
              if (studentId.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.black54, size: 24),
                  onPressed: () => context
                      .read<DormBloc>()
                      .add(const DormRefreshHistory()),
                ),
            ],
          ),
          body: Column(
            children: [
              HistoryFilterBar(
                periodLabel: periodLabel(),
                filterType: typeLabel(),
                lastUpdated: state.lastUpdated,
                onPeriodTap: () =>
                    _showPeriodSheet(context, s, state.filterDays),
                onTypeTap: () =>
                    _showTypeSheet(context, s, state.filterType),
              ),
              Expanded(
                child: studentId.isEmpty
                    ? Center(
                        child: Text(s.noStudentLinked,
                            style:
                                const TextStyle(color: Colors.grey)))
                    : state.status == DormStatus.loading &&
                            sourceLogs.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: MfuTheme.primary))
                        : RefreshIndicator(
                            color: MfuTheme.primary,
                            onRefresh: () async => context
                                .read<DormBloc>()
                                .add(const DormRefreshHistory()),
                            child: LogList(
                              sections: sections,
                              noDataLabel: isTodayView
                                  ? s.noActivityToday
                                  : s.noData,
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
