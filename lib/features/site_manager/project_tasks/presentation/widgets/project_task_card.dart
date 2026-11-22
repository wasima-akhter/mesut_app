import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/utils/app_date_time_formatter.dart';
import '../../../../../core/widgets/images/app_network_image.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../../../core/widgets/translation/translation_status_badge.dart';
import '../../../projects/enums.dart';
import '../../domain/entities/project_task_entity.dart';
import '../providers/project_tasks_provider.dart';

class ProjectTaskCard extends ConsumerWidget {
  final ProjectTaskEntity task;

  const ProjectTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCheckbox(context, ref),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  SizedBox(height: 8.h),
                  _buildMetadataRow(context),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            _buildDeleteButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        try {
          await ref.read(projectTasksProvider.notifier).toggleTask(task.id);
        } catch (e) {
          if (context.mounted) {
            AppSnackBar.showError(context, e.toString());
          }
        }
      },
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: task.isCompleted ? const Color(0xFFE00025) : Colors.white,
          border: Border.all(
            color: task.isCompleted
                ? const Color(0xFFE00025)
                : const Color(0xFF9E9E9E),
          ),
          borderRadius: BorderRadius.circular(3.r),
        ),
        child: task.isCompleted
            ? Icon(Icons.check, color: Colors.white, size: 14.sp)
            : null,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      task.displayTitle,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16.sp,
        height: 1.25,
        fontWeight: FontWeight.w500,
        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        decorationColor: Colors.grey.shade600,
        decorationThickness: 0.5,
        color: task.isCompleted
            ? const Color(0xFF999999)
            : const Color(0xFF222222),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatar(),
                  SizedBox(width: 5.w),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 90.w),
                    child: Text(
                      task.employee?.fullName ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ),
                ],
              ),
              _buildPriorityTag(),
              if (task.localization != null)
                TranslationStatusBadge.fromMeta(task.localization),
            ],
          ),
        ),
        if (task.dueDate != null) ...[
          SizedBox(width: 6.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14.sp,
                color: const Color(0xFF888888),
              ),
              SizedBox(width: 4.w),
              Text(
                context.loc.dueOn(_formatDueDate(task.dueDate!)),
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: const Color(0xFF777777),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: AppNetworkImage(
        imageUrl: task.employee?.avatarUrl,
        width: 21.w,
        height: 21.w,
        fit: BoxFit.cover,
        fallback: _fallbackAvatar(),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 21.w,
      height: 21.w,
      color: const Color(0xFFE8E8E8),
      child: Icon(Icons.person, size: 14.sp, color: const Color(0xFF888888)),
    );
  }

  Widget _buildPriorityTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: task.priority.backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        task.priority.label,
        style: TextStyle(
          fontSize: 12.5.sp,
          color: task.priority.color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        try {
          await ref.read(projectTasksProvider.notifier).deleteTask(task.id);
          if (context.mounted) {
            AppSnackBar.showSuccess(context, context.loc.taskDeleted);
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackBar.showError(context, e.toString());
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Icon(
          Icons.delete_outline,
          color: const Color(0xFFE00025),
          size: 19.sp,
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final month = AppDateTimeFormatter.monthName(date.month, short: true);
    return '$month ${date.day}';
  }
}
