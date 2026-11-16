import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/backend_enums.dart';
import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../../shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';
import '../../helper/employee_enums.dart';
import '../../helper/employee_models.dart';
import '../../presentation/providers/employee_timer_provider.dart';

class EmployeeTimerControlCard extends ConsumerStatefulWidget {
  const EmployeeTimerControlCard({super.key});

  @override
  ConsumerState<EmployeeTimerControlCard> createState() =>
      _EmployeeTimerControlCardState();
}

class _EmployeeTimerControlCardState
    extends ConsumerState<EmployeeTimerControlCard> {
  String? _selectedPhaseId;
  BackendActivityType _selectedActivity = BackendActivityType.erection;
  bool _busy = false;

  EmployeeActivityType _toEmployeeActivity(BackendActivityType type) {
    return type == BackendActivityType.dismantling
        ? EmployeeActivityType.dismantling
        : EmployeeActivityType.erection;
  }

  Future<void> _startTimer() async {
    final phaseId = _selectedPhaseId;
    if (phaseId == null || phaseId.isEmpty) {
      AppSnackBar.showInfo(context, context.loc.selectAssignedProject);
      return;
    }

    setState(() => _busy = true);
    try {
      final result = await ref
          .read(mobileTimeLogsProvider.notifier)
          .startTimer(phaseId: phaseId, activityType: _selectedActivity);

      final proj = result.project;
      ref
          .read(employeeTimerProvider.notifier)
          .startTimer(
            project: EmployeeProjectModel(
              id: proj?.id ?? phaseId,
              name: proj?.name ?? phaseId,
              address: proj?.address ?? '',
              activity: _toEmployeeActivity(_selectedActivity),
              startTime: '00:00',
              endTime: '--:--',
              startTimeOfDay: TimeOfDay.now(),
              endTimeOfDay: TimeOfDay.now(),
              siteManager: '',
            ),
            activity: _toEmployeeActivity(_selectedActivity),
          );

      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        context.loc.timerStartedFor(
          MobilePhaseLocalizer.phaseType(
            context,
            _selectedActivity.serializedName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final lang = ref.read(appLanguageProvider).code;
      final resolved = AppErrorResolver.resolve(e, languageCode: lang);
      AppSnackBar.showError(context, resolved.displayMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stopTimer() async {
    setState(() => _busy = true);
    try {
      await ref.read(mobileTimeLogsProvider.notifier).stopActiveTimer();
      ref.read(employeeTimerProvider.notifier).finishTimer();
    } catch (e) {
      if (!mounted) return;
      final lang = ref.read(appLanguageProvider).code;
      final resolved = AppErrorResolver.resolve(e, languageCode: lang);
      AppSnackBar.showError(context, resolved.displayMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = ref.watch(
      employeeTimerProvider.select((s) => s.isTimerRunning),
    );
    final projects =
        ref.watch(mobileProjectsProvider).asData?.value ?? const [];
    final phaseItems = <DropdownMenuItem<String>>[
      for (final p in projects)
        for (final ph in p.phases)
          DropdownMenuItem(
            value: ph.id,
            child: Text(
              '${p.name} • ${MobilePhaseLocalizer.phaseType(context, ph.type)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
    ];

    if (_selectedPhaseId == null && phaseItems.isNotEmpty) {
      _selectedPhaseId = phaseItems.first.value;
    }

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.loc.timerLabel,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (isRunning)
                  GestureDetector(
                    onTap: () =>
                        context.push(RouteConstants.employeeActiveTimerPage),
                    child: _LiveElapsedText(),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            if (!isRunning) ...[
              DropdownButtonFormField<String>(
                initialValue: phaseItems.any((i) => i.value == _selectedPhaseId)
                    ? _selectedPhaseId
                    : null,
                isExpanded: true,
                items: phaseItems,
                onChanged: (v) => setState(() => _selectedPhaseId = v),
                decoration: InputDecoration(
                  labelText: context.loc.phase,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.h),
              DropdownButtonFormField<BackendActivityType>(
                initialValue: _selectedActivity,
                items: BackendActivityType.values
                    .map(
                      (a) => DropdownMenuItem(
                        value: a,
                        child: Text(
                          MobilePhaseLocalizer.phaseType(
                            context,
                            a.serializedName,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedActivity = v);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 12.h),
            ],
            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: _busy
                    ? null
                    : (isRunning ? _stopTimer : _startTimer),
                text: _busy
                    ? '...'
                    : (isRunning
                          ? context.loc.stopTimer
                          : context.loc.startNewTimer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveElapsedText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatted = ref.watch(
      employeeTimerProvider.select((s) => s.formattedElapsed),
    );
    return Text(
      formatted,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
