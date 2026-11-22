import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/translation/translation_status_badge.dart';
import '../../domain/entities/employee_project_details_entity.dart';

class AssignmentDetailTasksCard extends StatelessWidget {
  final List<EmployeeProjectTaskEntity> tasks;
  final ValueChanged<String> onToggleTask;

  const AssignmentDetailTasksCard({
    super.key,
    required this.tasks,
    required this.onToggleTask,
  });

  Widget _taskRow(BuildContext context, EmployeeProjectTaskEntity task) {
    return GestureDetector(
      onTap: () => onToggleTask(task.id),
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: task.isCompleted ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.primary
                      : AppColors.neutral300,
                  width: 1.5,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: task.isCompleted
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.dueDate != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Due: ${task.dueDate!.toLocal().toString().split(' ').first}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (task.localization != null) ...[
              SizedBox(width: 6.w),
              TranslationStatusBadge.fromMeta(task.localization),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.loc.smTasks} (0)',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'No tasks assigned for this project.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.loc.smTasks} (${tasks.length})',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          for (int i = 0; i < tasks.length; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            _taskRow(context, tasks[i]),
          ],
        ],
      ),
    );
  }
}
