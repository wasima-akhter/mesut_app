import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../employee/timer/widgets/employee_timer_control_card.dart';
import '../../shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';
import '../../shared/mobile_time_tracking/presentation/widgets/mobile_crew_time_panel.dart';
import '../../shared/mobile_time_tracking/presentation/widgets/mobile_manual_time_dialog.dart';
import '../../shared/mobile_time_tracking/presentation/widgets/mobile_time_logs_section.dart';

class SiteManagerTimeTrackingPage extends ConsumerStatefulWidget {
  const SiteManagerTimeTrackingPage({super.key});

  @override
  ConsumerState<SiteManagerTimeTrackingPage> createState() =>
      _SiteManagerTimeTrackingPageState();
}

class _SiteManagerTimeTrackingPageState
    extends ConsumerState<SiteManagerTimeTrackingPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (_tabIndex == 0) {
              await ref.read(mobileTimeLogsProvider.notifier).refresh();
            } else {
              await ref.read(mobileCrewTimeProvider.notifier).refresh();
            }
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.loc.timeTracking,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const MobileManualTimeDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.loc.manualLabel),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text(context.loc.myTime),
                    icon: const Icon(Icons.person_outline),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(context.loc.siteCrewTime),
                    icon: const Icon(Icons.groups_outlined),
                  ),
                ],
                selected: {_tabIndex},
                onSelectionChanged: (s) => setState(() => _tabIndex = s.first),
              ),
              SizedBox(height: 16.h),
              if (_tabIndex == 0) ...[
                const EmployeeTimerControlCard(),
                SizedBox(height: 18.h),
                const MobileTimeLogsSection(),
              ] else
                const MobileCrewTimePanel(),
            ],
          ),
        ),
      ),
    );
  }
}
