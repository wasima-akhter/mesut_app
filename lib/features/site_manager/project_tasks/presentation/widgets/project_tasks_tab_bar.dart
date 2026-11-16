import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../projects/enums.dart';
import '../providers/project_tasks_provider.dart';
import 'project_tasks_add_sheet.dart';

class ProjectTasksTabBar extends ConsumerWidget {
  final String projectId;

  const ProjectTasksTabBar({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectTasksProvider);
    final openCount = state.openCount;
    final completedCount = state.completedCount;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildTabButton(
                ref: ref,
                tab: TaskStatusTab.open,
                label: context.loc.openTasks(openCount),
                selected: state.selectedTab == TaskStatusTab.open,
              ),
              SizedBox(width: 8.w),
              _buildTabButton(
                ref: ref,
                tab: TaskStatusTab.completed,
                label: context.loc.completedTasks(completedCount),
                selected: state.selectedTab == TaskStatusTab.completed,
              ),
            ],
          ),
          SizedBox(width: 10.w),
          AppButton.small(
            text: context.loc.addNew,
            leadingIcon: Icons.add,
            onPressed: () => showAddProjectTaskSheet(context, ref, projectId),
            borderRadius: 6.r,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required WidgetRef ref,
    required TaskStatusTab tab,
    required String label,
    required bool selected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(projectTasksProvider.notifier).selectTaskTab(tab);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: selected ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: selected ? Colors.white : const Color(0xFF666666),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
