import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import '../../domain/entities/employee_time_tracking_entities.dart';
import '../providers/employee_timer_projects_provider.dart';

class EmployeeProjectPhasePicker extends ConsumerWidget {
  const EmployeeProjectPhasePicker({
    super.key,
    required this.selectedProject,
    required this.selectedPhase,
    required this.onProjectChanged,
    required this.onPhaseChanged,
  });

  final EmployeeProjectGroup? selectedProject;
  final EmployeeAssignedProjectEntity? selectedPhase;
  final ValueChanged<EmployeeProjectGroup> onProjectChanged;
  final ValueChanged<EmployeeAssignedProjectEntity> onPhaseChanged;

  String _formatPhaseLabel(BuildContext context, String phaseType) {
    final upper = phaseType.toUpperCase();
    if (upper == 'ERECTION') return context.loc.scaffoldErection;
    if (upper == 'DISMANTLING') return context.loc.scaffoldDismantling;
    return phaseType;
  }

  Widget _boxWrapper({required Widget child}) => Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD8D8D8)),
          borderRadius: BorderRadius.circular(6.r),
          color: AppColors.white,
        ),
        child: child,
      );

  Widget _buildProjectDropdown(
    BuildContext context,
    WidgetRef ref,
    EmployeeTimerProjectsState state,
  ) {
    if (state.isLoading && state.projectAssignments.isEmpty) {
      return _boxWrapper(
        child: Row(
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10.w),
            Text(
              context.loc.loading,
              style: TextStyle(fontSize: 15.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null && state.projectAssignments.isEmpty) {
      return _boxWrapper(
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.loc.somethingWentWrong,
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  ref.read(employeeTimerProjectsProvider.notifier).loadInitial(),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(context.loc.retry),
            ),
          ],
        ),
      );
    }

    final projects = state.uniqueProjects;
    if (projects.isEmpty) {
      return _boxWrapper(
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.loc.noProjectsFound,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () =>
                  ref.read(employeeTimerProjectsProvider.notifier).loadInitial(),
            ),
          ],
        ),
      );
    }

    final isSelectedValid = projects.any((p) => p.id == selectedProject?.id);
    final currentValue = isSelectedValid ? selectedProject?.id : null;

    return _boxWrapper(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          hint: Text(
            context.loc.selectProject,
            style: TextStyle(fontSize: 15.sp, color: AppColors.textTertiary),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 20.sp),
          items: [
            ...projects.map(
              (p) => DropdownMenuItem(
                value: p.id,
                child: Text(
                  p.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
                ),
              ),
            ),
            if (state.hasMore)
              DropdownMenuItem(
                value: '__load_more__',
                child: Center(
                  child: state.isLoadingMore
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Load more...',
                          style: TextStyle(fontSize: 13.sp, color: AppColors.primary),
                        ),
                ),
              ),
          ],
          onChanged: (val) {
            if (val == '__load_more__') {
              ref.read(employeeTimerProjectsProvider.notifier).loadMore();
              return;
            }
            if (val == null) return;
            final matched = projects.firstWhere((p) => p.id == val);
            onProjectChanged(matched);
            if (matched.phases.isNotEmpty) {
              onPhaseChanged(matched.phases.first);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPhaseDropdown(BuildContext context) {
    final phases = selectedProject?.phases ?? const [];

    if (selectedProject == null || phases.isEmpty) {
      return _boxWrapper(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.loc.selectProject,
            style: TextStyle(fontSize: 15.sp, color: AppColors.textTertiary),
          ),
        ),
      );
    }

    final isPhaseValid = phases.any((p) => p.phaseId == selectedPhase?.phaseId);
    final currentPhaseId = isPhaseValid ? selectedPhase?.phaseId : phases.first.phaseId;

    return _boxWrapper(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentPhaseId,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 20.sp),
          items: phases
              .map(
                (ph) => DropdownMenuItem(
                  value: ph.phaseId,
                  child: Text(
                    _formatPhaseLabel(context, ph.phaseType),
                    style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val == null) return;
            final selected = phases.firstWhere((ph) => ph.phaseId == val);
            onPhaseChanged(selected);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(employeeTimerProjectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.assignedProject,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        _buildProjectDropdown(context, ref, state),
        SizedBox(height: 16.h),
        Text(
          context.loc.activityType,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        _buildPhaseDropdown(context),
      ],
    );
  }
}
