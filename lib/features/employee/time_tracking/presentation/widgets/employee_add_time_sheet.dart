import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/buttons/buttons.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../../domain/entities/employee_time_tracking_entities.dart';
import '../../presentation/providers/employee_time_tracking_provider.dart';
import '../../presentation/providers/employee_timer_projects_provider.dart';
import 'employee_project_phase_picker.dart';

Future<void> showEmployeeAddTimeSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .55),
    builder: (_) => const EmployeeAddTimeSheet(),
  );
}

class EmployeeAddTimeSheet extends ConsumerStatefulWidget {
  const EmployeeAddTimeSheet({super.key});

  @override
  ConsumerState<EmployeeAddTimeSheet> createState() =>
      _EmployeeAddTimeSheetState();
}

class _EmployeeAddTimeSheetState extends ConsumerState<EmployeeAddTimeSheet> {
  DateTime _selectedDate = DateTime.now();
  EmployeeProjectGroup? _selectedProject;
  EmployeeAssignedProjectEntity? _selectedPhase;
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 30);
  Duration _breakTime = const Duration(minutes: 45);
  bool _isSubmitting = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _selectBreakTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 45),
    );
    if (picked != null) {
      setState(() => _breakTime = Duration(hours: picked.hour, minutes: picked.minute));
    }
  }

  Widget _actionField({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: const Color(0xFFD8D8D8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
              ),
            ),
            Icon(icon, size: 20.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_selectedProject == null || _selectedPhase == null) {
      AppSnackBar.showError(context, context.loc.selectProject);
      return;
    }

    setState(() => _isSubmitting = true);

    final startDt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final success = await ref
        .read(employeeTimeTrackingProvider.notifier)
        .addManualTime(
          projectId: _selectedProject!.id,
          activityType: _selectedPhase!.phaseType.toUpperCase(),
          startTime: startDt,
          endTime: endDt,
          breakMinutes: _breakTime.inMinutes,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
      AppSnackBar.showSuccess(context, context.loc.entrySaved);
    } else {
      AppSnackBar.showError(context, context.loc.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .90,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
          child: Column(
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
                context.loc.addTimeEntry,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 18.h),
              _fieldLabel(context.loc.date),
              SizedBox(height: 6.h),
              _actionField(
                text: _selectedDate.formatLocalized(style: 'numeric'),
                icon: Icons.calendar_month_outlined,
                onTap: _selectDate,
              ),
              SizedBox(height: 16.h),
              EmployeeProjectPhasePicker(
                selectedProject: _selectedProject,
                selectedPhase: _selectedPhase,
                onProjectChanged: (p) => setState(() => _selectedProject = p),
                onPhaseChanged: (ph) => setState(() => _selectedPhase = ph),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(context.loc.startTime),
                        SizedBox(height: 6.h),
                        _actionField(
                          text: _startTime.formatLocalized(),
                          icon: Icons.access_time_rounded,
                          onTap: _selectStartTime,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(context.loc.endTime),
                        SizedBox(height: 6.h),
                        _actionField(
                          text: _endTime.formatLocalized(),
                          icon: Icons.access_time_rounded,
                          onTap: _selectEndTime,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _fieldLabel(context.loc.breakTime),
              SizedBox(height: 6.h),
              _actionField(
                text: _breakTime.formatCompactLocalized(),
                icon: Icons.coffee_outlined,
                onTap: _selectBreakTime,
              ),
              SizedBox(height: 22.h),
              AppButton(
                text: context.loc.saveEntry,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _saveEntry,
              ),
              SizedBox(height: 8.h),
              AppTextButton(
                text: context.loc.cancel,
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                foregroundColor: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
