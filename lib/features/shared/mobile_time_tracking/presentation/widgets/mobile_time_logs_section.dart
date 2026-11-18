import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../../core/localization/pending_refetch_controller.dart';
import '../../../../../core/widgets/states/app_empty_widget.dart';
import '../../../../../core/widgets/states/app_error_widget.dart';
import '../providers/mobile_time_tracking_provider.dart';
import 'mobile_time_log_card.dart';

class MobileTimeLogsSection extends ConsumerWidget {
  const MobileTimeLogsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);
    final logsAsync = ref.watch(mobileTimeLogsProvider);
    final notifier = ref.read(mobileTimeLogsProvider.notifier);
    final selectedPeriod = notifier.period;

    final periods = <(String, String)>[
      ('TODAY', context.loc.periodToday),
      ('WEEK', context.loc.periodThisWeek),
      ('MONTH', context.loc.periodThisMonth),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          children: periods.map((p) {
            final (code, label) = p;
            return ChoiceChip(
              label: Text(label),
              selected: selectedPeriod == code,
              onSelected: (_) => notifier.setPeriod(code),
            );
          }).toList(),
        ),
        SizedBox(height: 12.h),
        PendingPollEffect(
          hasPending: anyLocalizationPending(
            (logsAsync.asData?.value ?? const []).map((l) => l.localization),
          ),
          onPoll: notifier.refresh,
          child: logsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => AppErrorWidget(
              error: err,
              onRetry: notifier.refresh,
            ),
            data: (logs) {
              if (logs.isEmpty) {
                return AppEmptyWidget(
                  icon: Icons.access_time_outlined,
                  title: context.loc.noTimeLogs,
                  onRetry: notifier.refresh,
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (_, index) => MobileTimeLogCard(log: logs[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
