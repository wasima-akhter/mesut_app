import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/images/app_avatar.dart';
import '../../domain/entities/project_task_entity.dart';
import '../providers/project_task_employees_provider.dart';

class ProjectTaskEmployeeDropdown extends ConsumerWidget {
  const ProjectTaskEmployeeDropdown({
    super.key,
    required this.projectId,
    required this.selectedEmployeeId,
    required this.onChanged,
  });

  final String projectId;
  final String? selectedEmployeeId;
  final ValueChanged<String?> onChanged;

  Widget _boxWrapper({required Widget child}) => Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD8D8D8)),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: child,
      );

  Widget _buildAvatar(ProjectTaskEmployeeEntity emp) {
    return AppAvatar(
      imageUrl: emp.avatarUrl,
      name: '${emp.firstName} ${emp.lastName}',
      size: 24.r,
      backgroundColor: const Color(0xFFEAEAEA),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEmployees = ref.watch(projectTaskEmployeesProvider(projectId));

    return asyncEmployees.when(
      loading: () => _boxWrapper(
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
              style: TextStyle(fontSize: 15.sp, color: const Color(0xFF888888)),
            ),
          ],
        ),
      ),
      error: (_, _) => _boxWrapper(
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.loc.somethingWentWrong,
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () => ref.invalidate(projectTaskEmployeesProvider(projectId)),
            ),
          ],
        ),
      ),
      data: (employees) {
        final isValid = employees.any((e) => e.id == selectedEmployeeId);
        final currentValue = isValid ? selectedEmployeeId : null;

        return _boxWrapper(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              hint: Text(
                context.loc.selectEmployee,
                style: TextStyle(fontSize: 16.sp, color: const Color(0xFF999999)),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, size: 20.sp),
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF444444)),
              items: employees.map((emp) {
                return DropdownMenuItem<String>(
                  value: emp.id,
                  child: Row(
                    children: [
                      _buildAvatar(emp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          emp.fullName.isNotEmpty ? emp.fullName : emp.id,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (emp.role != null && emp.role!.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            emp.role!,
                            style: TextStyle(fontSize: 10.sp, color: const Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}
