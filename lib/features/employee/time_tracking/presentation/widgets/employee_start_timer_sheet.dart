import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import 'package:construction_app/core/widgets/snack/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';
import '../../domain/entities/employee_time_tracking_entities.dart';
import '../providers/employee_time_tracking_provider.dart';
import '../providers/employee_timer_projects_provider.dart';
import '../providers/employee_timer_provider.dart';
import 'employee_project_phase_picker.dart';

Future<void> showEmployeeStartTimerSheet({required BuildContext context}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .55),
    builder: (_) => const EmployeeStartTimerSheet(),
  );
}

class EmployeeStartTimerSheet extends ConsumerStatefulWidget {
  const EmployeeStartTimerSheet({super.key});

  @override
  ConsumerState<EmployeeStartTimerSheet> createState() =>
      _EmployeeStartTimerSheetState();
}

class _EmployeeStartTimerSheetState
    extends ConsumerState<EmployeeStartTimerSheet> {
  EmployeeProjectGroup? _selectedProject;
  EmployeeAssignedProjectEntity? _selectedPhase;
  bool _isSubmitting = false;

  Future<void> _startTimer() async {
    if (_selectedProject == null || _selectedPhase == null) {
      AppSnackBar.showError(context, context.loc.selectProject);
      return;
    }

    setState(() => _isSubmitting = true);
    final targetPhaseId = _selectedPhase!.phaseId.isNotEmpty
        ? _selectedPhase!.phaseId
        : _selectedProject!.id;
    final activityType = _selectedPhase!.phaseType.toUpperCase();

    final success = await ref
        .read(employeeTimeTrackingProvider.notifier)
        .startTimer(projectId: targetPhaseId, activityType: activityType);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      final act = activityType == 'DISMANTLING'
          ? EmployeeActivityType.dismantling
          : EmployeeActivityType.erection;
      final activeTimer =
          ref.read(employeeTimeTrackingProvider).summary.activeTimer;
      ref
          .read(employeeTimerProvider.notifier)
          .startTimer(
            project: EmployeeProjectModel(
              id: _selectedProject!.id,
              phaseId: _selectedPhase!.phaseId,
              name: _selectedProject!.name,
              activity: act,
            ),
            activity: act,
            activeTimeLogId: activeTimer?.id,
            isAlreadyDispatched: true,
          );
      Navigator.of(context).pop();
      AppSnackBar.showInfo(context, context.loc.timerRunning);
    } else {
      AppSnackBar.showError(context, context.loc.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .88,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              Text(
                context.loc.startNewTimer,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                context.loc.timerNotice,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 18.h),
              EmployeeProjectPhasePicker(
                selectedProject: _selectedProject,
                selectedPhase: _selectedPhase,
                onProjectChanged: (p) => setState(() => _selectedProject = p),
                onPhaseChanged: (ph) => setState(() => _selectedPhase = ph),
              ),
              SizedBox(height: 22.h),
              AppButton(
                text: context.loc.startNewTimer,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _startTimer,
              ),
              SizedBox(height: 8.h),
              AppTextButton(
                text: context.loc.cancel,
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                foregroundColor: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
