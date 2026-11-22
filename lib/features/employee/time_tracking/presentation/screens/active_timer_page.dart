import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/extensions/date_time_extensions.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/localization/pending_refetch_controller.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import 'package:construction_app/core/widgets/snack/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/employee_timer_projects_provider.dart';
import '../providers/employee_timer_provider.dart';
import '../widgets/active_timer_assignment_card.dart';
import '../widgets/active_timer_elapsed_view.dart';
import '../widgets/active_timer_header.dart';
import '../widgets/cancel_timer_dialog.dart';
import '../widgets/finish_work_dialog.dart';

class ActiveTimerPage extends ConsumerStatefulWidget {
  const ActiveTimerPage({super.key});

  @override
  ConsumerState<ActiveTimerPage> createState() => _ActiveTimerPageState();
}

class _ActiveTimerPageState extends ConsumerState<ActiveTimerPage> {
  bool _manuallyStopped = false;

  Future<bool> _confirmAndCancel(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CancelTimerDialog(),
    );
    if (shouldCancel == true) {
      _manuallyStopped = true;
      await ref.read(employeeTimerProvider.notifier).cancelTimer();
      return true;
    }
    return false;
  }

  void _finishWork(BuildContext context) {
    final timerState = ref.read(employeeTimerProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return FinishWorkDialog(
          projectName: timerState.currentProject.fullName,
          totalTime: timerState.formattedElapsed,
          onSave: () async {
            _manuallyStopped = true;
            Navigator.of(context).pop();
            final success = await ref
                .read(employeeTimerProvider.notifier)
                .finishTimer();
            if (context.mounted) {
              Navigator.of(context).pop();
              if (success) {
                AppSnackBar.showSuccess(context, context.loc.entrySaved);
              } else {
                AppSnackBar.showError(context, context.loc.somethingWentWrong);
              }
            }
          },
        );
      },
    );
  }

  Future<void> _handleLeaveScreen() async {
    final timerState = ref.read(employeeTimerProvider);
    if (!timerState.isTimerRunning) {
      Navigator.of(context).pop();
      return;
    }
    if (timerState.canCancel) {
      final cancel = await _confirmAndCancel(context);
      if (cancel && mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    _manuallyStopped = true;
    await ref.read(employeeTimerProvider.notifier).finishTimer();
    if (mounted) {
      Navigator.of(context).pop();
      AppSnackBar.showInfo(context, context.loc.workFinished);
    }
  }

  @override
  void dispose() {
    if (!_manuallyStopped) {
      final timerState = ref.read(employeeTimerProvider);
      if (timerState.isTimerRunning &&
          !timerState.canCancel &&
          timerState.graceSecondsRemaining == 0) {
        ref.read(employeeTimerProvider.notifier).finishTimer();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(employeeTimerProvider);
    final isOnBreak = timerState.isOnBreak;
    final isRunning = timerState.isTimerRunning;
    final canCancel = timerState.canCancel;

    return PopScope(
      canPop: !isRunning,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (canCancel) {
          final shouldCancel = await _confirmAndCancel(context);
          if (shouldCancel && context.mounted) {
            Navigator.of(context).pop();
          }
        } else if (isRunning && !canCancel && timerState.graceSecondsRemaining == 0) {
          _manuallyStopped = true;
          await ref.read(employeeTimerProvider.notifier).finishTimer();
          if (context.mounted) {
            Navigator.of(context).pop();
            AppSnackBar.showInfo(context, context.loc.workFinished);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: PendingPollEffect(
            hasPending:
                timerState.currentProject.localization?.isPending == true,
            onPoll: () =>
                ref.read(employeeTimerProjectsProvider.notifier).loadInitial(),
            child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
                sliver: SliverToBoxAdapter(
                  child: ActiveTimerHeader(
                    isOnBreak: isOnBreak,
                    isRunning: isRunning,
                    canCancel: canCancel,
                    onBack: _handleLeaveScreen,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: ActiveTimerAssignmentCard(state: timerState),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: _buildTimerCard(context, timerState),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 25.h)),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard(
    BuildContext context,
    EmployeeTimerState state,
  ) {
    final isOnBreak = state.isOnBreak;
    final startedAtText = state.sessionStartedAt != null
        ? TimeOfDay.fromDateTime(state.sessionStartedAt!.toLocal()).formatLocalized()
        : state.currentProject.formattedStartTime;
    final breakText = (state.breakDuration > Duration.zero
            ? state.breakDuration
            : const Duration(minutes: 0))
        .formatCompactLocalized();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: isOnBreak ? const Color(0xFFFFF7E8) : AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(
          color: isOnBreak ? const Color(0xFFF9D89A) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          ActiveTimerElapsedView(isOnBreak: isOnBreak),
          SizedBox(height: 14.h),
          Text(
            '${context.loc.today} · ${context.loc.startedAt(startedAtText)}',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
          ),
          SizedBox(height: 5.h),
          Text(
            '${context.loc.breakTime}: $breakText',
            style: TextStyle(
              fontSize: 16.sp,
              color: isOnBreak ? AppColors.warningDark : AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: () =>
                      ref.read(employeeTimerProvider.notifier).toggleBreak(),
                  leadingIcon: isOnBreak ? Icons.play_arrow : Icons.pause,
                  text: isOnBreak
                      ? context.loc.resumeWork
                      : context.loc.pauseBreak,
                  foregroundColor: isOnBreak
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  borderColor: isOnBreak
                      ? AppColors.primary
                      : AppColors.borderDark,
                  borderRadius: 8.r,
                  textStyle: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppButton(
                  onPressed: () => _finishWork(context),
                  text: context.loc.finishWork,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (state.canCancel)
            AppTextButton(
              onPressed: () async {
                final cancel = await _confirmAndCancel(context);
                if (cancel && context.mounted) {
                  Navigator.of(context).pop();
                  AppSnackBar.showInfo(context, context.loc.timerCancelled);
                }
              },
              leadingIcon: Icons.cancel_outlined,
              text:
                  '${context.loc.cancelTimer} (${state.graceSecondsRemaining}s)',
              foregroundColor: AppColors.error,
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 15.sp,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    context.loc.get(
                      'employee.timerActiveServer',
                      'Timer active on server • Finish work to stop',
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
