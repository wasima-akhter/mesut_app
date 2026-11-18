/// =============================================================
/// TASKS
/// =============================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/images/app_network_image.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import 'presentation/providers/site_manager_project_details_provider.dart';
import 'enums.dart';
import 'models.dart';
import 'overview_modules.dart';

class TasksTab extends ConsumerWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(projectDetailsProvider);
    final tasks = detailsState.filteredTasks;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 20.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildTaskTabs(context, ref, detailsState),
              SizedBox(height: 10.h),

              if (tasks.isEmpty)
                _buildEmptyTaskState(
                  context,
                  detailsState.selectedTaskTab == TaskStatusTab.open,
                )
              else
                ...tasks.asMap().entries.map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _buildTaskCard(
                          context,
                          ref,
                          entry.value,
                          entry.key,
                        ),
                      ),
                    ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTabs(
    BuildContext context,
    WidgetRef ref,
    ProjectDetailsState detailsState,
  ) {
    final openCount =
        detailsState.tasks.where((task) => !task.completed).length;
    final completedCount =
        detailsState.tasks.where((task) => task.completed).length;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildTaskStatusTab(
                ref: ref,
                tab: TaskStatusTab.open,
                label: context.loc.openTasks(openCount),
                selected: detailsState.selectedTaskTab == TaskStatusTab.open,
              ),
              SizedBox(width: 8.w),
              _buildTaskStatusTab(
                ref: ref,
                tab: TaskStatusTab.completed,
                label: context.loc.completedTasks(completedCount),
                selected:
                    detailsState.selectedTaskTab == TaskStatusTab.completed,
              ),
            ],
          ),
          SizedBox(width: 10.w),
          AppButton.small(
            text: context.loc.addNew,
            leadingIcon: Icons.add,
            onPressed: () => showAddTaskBottomSheet(context, ref),
            borderRadius: 6.r,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusTab({
    required WidgetRef ref,
    required TaskStatusTab tab,
    required String label,
    required bool selected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(projectDetailsProvider.notifier).selectTaskTab(tab);
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

  Widget _buildEmptyTaskState(BuildContext context, bool isOpen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        children: [
          Icon(
            isOpen ? Icons.task_alt_outlined : Icons.check_circle_outline,
            size: 38.sp,
            color: const Color(0xFFBDBDBD),
          ),
          SizedBox(height: 10.h),
          Text(
            isOpen ? context.loc.noOpenTasks : context.loc.noCompletedTasks,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF555555),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            isOpen
                ? context.loc.allTasksCompleted
                : context.loc.completedTasksAppearHere,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.sp, color: const Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref,
    ProjectTask task,
    int index,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              ref.read(projectDetailsProvider.notifier).toggleTask(index);
            },
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: task.completed ? const Color(0xFFE00025) : Colors.white,
                border: Border.all(
                  color: task.completed
                      ? const Color(0xFFE00025)
                      : const Color(0xFF9E9E9E),
                ),
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: task.completed
                  ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                  : null,
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: Colors.grey.shade600,
                    decorationThickness: 0.5,
                    color: task.completed
                        ? const Color(0xFF999999)
                        : const Color(0xFF222222),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    ClipOval(
                      child: AppNetworkImage(
                        imageUrl: 'https://i.pravatar.cc/100?img=12',
                        width: 21.w,
                        height: 21.w,
                        fit: BoxFit.cover,
                        fallback: Container(
                          width: 21.w,
                          height: 21.w,
                          color: const Color(0xFFE8E8E8),
                          child: Icon(Icons.person, size: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: Text(
                        task.employee,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          color: const Color(0xFF777777),
                        ),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    _priorityTag(task.priority),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: const Color(0xFF888888),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      context.loc.dueOn('Sep 20'),
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          GestureDetector(
            onTap: () {
              showMessage(context.loc.taskDeleted);
            },
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(
                Icons.delete_outline,
                color: const Color(0xFFE00025),
                size: 19.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityTag(ProjectPriority priority) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 12.5.sp,
          color: priority.color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> showAddTaskBottomSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final task = await showModalBottomSheet<ProjectTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddTaskBottomSheet(),
    );

    if (task != null) {
      ref.read(projectDetailsProvider.notifier).addTask(task);
    }
  }
}

/// ===============================================================
/// ADD TASK BOTTOM SHEET
/// ===============================================================

class _AddTaskBottomSheet extends StatefulWidget {
  const _AddTaskBottomSheet();

  @override
  State<_AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<_AddTaskBottomSheet> {
  final TextEditingController _descriptionController = TextEditingController();

  String? _employee;
  ProjectPriority _priority = ProjectPriority.high;
  DateTime _dueDate = DateTime(2026, 9, 19);

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .90,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 9.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD5D5D5),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 8.h),
              child: Text(
                context.loc.newTask,
                style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _fieldLabel(context.loc.taskDescription),
                        SizedBox(height: 6.h),
                        _descriptionField(),
                        SizedBox(height: 14.h),
                        _fieldLabel(context.loc.responsibleEmployee),
                        SizedBox(height: 6.h),
                        _dropdown(
                          value: _employee,
                          hint: context.loc.selectEmployee,
                          items: const [
                            'Tim Muler',
                            'Andreas Weber',
                            'John Smith',
                          ],
                          onChanged: (value) {
                            setState(() {
                              _employee = value;
                            });
                          },
                        ),
                        SizedBox(height: 14.h),
                        _fieldLabel(context.loc.priority),
                        SizedBox(height: 6.h),
                        _dropdown(
                          value: _priority.label,
                          items: ProjectPriority.values
                              .map((e) => e.label)
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _priority = ProjectPriority.values.firstWhere(
                                (e) => e.label == value,
                              );
                            });
                          },
                        ),
                        SizedBox(height: 14.h),
                        _fieldLabel(context.loc.dueDate),
                        SizedBox(height: 6.h),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            height: 48.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFD8D8D8),
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatDate(_dueDate),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF555555),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 17.sp,
                                  color: const Color(0xFF777777),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        AppButton(
                          text: context.loc.createNewTask,
                          onPressed: _createTask,
                          borderRadius: 6.r,
                        ),
                        SizedBox(height: 7.h),
                        AppTextButton(
                          text: context.loc.cancel,
                          onPressed: () => Navigator.pop(context),
                          foregroundColor: const Color(0xFF555555),
                          textStyle: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF333333),
      ),
    );
  }

  Widget _descriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 3,
      style: TextStyle(fontSize: 16.sp),
      decoration: InputDecoration(
        hintText:
            'e.g. Anchor scaffold ties into reinforced concrete at 4th floor',
        hintStyle: TextStyle(fontSize: 16.sp, color: const Color(0xFF999999)),
        contentPadding: EdgeInsets.all(12.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
      ),
    );
  }

  Widget _dropdown({
    String? value,
    String? hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8D8D8)),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint == null
              ? null
              : Text(
                  hint,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 20.sp),
          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF444444)),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _createTask() {
    if (_descriptionController.text.trim().isEmpty) {
      _showError(context.loc.pleaseEnterTaskDescription);
      return;
    }

    if (_employee == null) {
      _showError(context.loc.pleaseSelectEmployee);
      return;
    }

    Navigator.pop(
      context,
      ProjectTask(
        description: _descriptionController.text.trim(),
        employee: _employee!,
        priority: _priority,
        dueDate: _dueDate,
      ),
    );
  }

  void _showError(String message) {
    AppSnackBar.showError(context, message);
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
