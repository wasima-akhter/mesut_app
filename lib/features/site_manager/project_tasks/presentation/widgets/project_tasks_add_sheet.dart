import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../project_details/presentation/providers/project_details_provider.dart';
import '../../domain/entities/project_task_entity.dart';
import '../../../projects/enums.dart';
import '../providers/project_tasks_provider.dart';

Future<void> showAddProjectTaskSheet(
  BuildContext context,
  WidgetRef ref,
  String projectId,
) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProjectTasksAddSheet(projectId: projectId),
    );

class ProjectTasksAddSheet extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectTasksAddSheet({super.key, required this.projectId});

  @override
  ConsumerState<ProjectTasksAddSheet> createState() =>
      _ProjectTasksAddSheetState();
}

class _ProjectTasksAddSheetState extends ConsumerState<ProjectTasksAddSheet> {
  final _descriptionController = TextEditingController();
  String? _selectedEmployeeId;
  ProjectPriority _priority = ProjectPriority.high;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 3));
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<ProjectTaskEmployeeEntity> _getAvailableEmployees() {
    final details = ref.read(projectDetailsProvider).details;
    final tasksState = ref.read(projectTasksProvider);
    final map = <String, ProjectTaskEmployeeEntity>{};

    if (details != null) {
      for (final m in details.crewBreakdown) {
        if (m.user.id.isNotEmpty) {
          map[m.user.id] = ProjectTaskEmployeeEntity(
            id: m.user.id,
            firstName: m.user.firstName,
            lastName: m.user.lastName,
          );
        }
      }
    }
    for (final t in [...tasksState.openTasks, ...tasksState.completedTasks]) {
      if (t.employee != null && t.employee!.id.isNotEmpty) {
        map.putIfAbsent(t.employee!.id, () => t.employee!);
      }
    }
    return map.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final employees = _getAvailableEmployees();

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
              child: ListView(
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                children: [
                  _fieldLabel(context.loc.taskDescription),
                  SizedBox(height: 6.h),
                  _descriptionField(),
                  SizedBox(height: 14.h),
                  _fieldLabel(context.loc.responsibleEmployee),
                  SizedBox(height: 6.h),
                  _employeeDropdown(employees),
                  SizedBox(height: 14.h),
                  _fieldLabel(context.loc.priority),
                  SizedBox(height: 6.h),
                  _priorityDropdown(),
                  SizedBox(height: 14.h),
                  _fieldLabel(context.loc.dueDate),
                  SizedBox(height: 6.h),
                  _dueDatePicker(),
                  SizedBox(height: 20.h),
                  AppButton(
                    text: context.loc.createNewTask,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _createTask,
                    borderRadius: 6.r,
                  ),
                  SizedBox(height: 7.h),
                  AppTextButton(
                    text: context.loc.cancel,
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    foregroundColor: const Color(0xFF555555),
                    textStyle: TextStyle(fontSize: 16.sp, color: const Color(0xFF555555)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF333333),
        ),
      );

  Widget _descriptionField() => TextField(
        controller: _descriptionController,
        maxLines: 3,
        style: TextStyle(fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: 'e.g. Anchor scaffold ties into reinforced concrete at 4th floor',
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

  Widget _boxWrapper({required Widget child}) => Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD8D8D8)),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: child,
      );

  Widget _employeeDropdown(List<ProjectTaskEmployeeEntity> employees) =>
      _boxWrapper(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedEmployeeId,
            hint: Text(
              context.loc.selectEmployee,
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF999999)),
            ),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, size: 20.sp),
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF444444)),
            items: employees
                .map((emp) => DropdownMenuItem(
                      value: emp.id,
                      child: Text(emp.fullName.isNotEmpty ? emp.fullName : emp.id),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedEmployeeId = val),
          ),
        ),
      );

  Widget _priorityDropdown() => _boxWrapper(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ProjectPriority>(
            value: _priority,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, size: 20.sp),
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF444444)),
            items: ProjectPriority.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _priority = val);
            },
          ),
        ),
      );

  Widget _dueDatePicker() => GestureDetector(
        onTap: _selectDate,
        child: _boxWrapper(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(_dueDate),
                  style: TextStyle(fontSize: 16.sp, color: const Color(0xFF555555)),
                ),
              ),
              Icon(Icons.calendar_today_outlined, size: 17.sp, color: const Color(0xFF777777)),
            ],
          ),
        ),
      );

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _createTask() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseEnterTaskDescription);
      return;
    }
    if (_selectedEmployeeId == null || _selectedEmployeeId!.isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseSelectEmployee);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(projectTasksProvider.notifier).createTask(
            projectId: widget.projectId,
            description: description,
            employeeId: _selectedEmployeeId!,
            priority: _priority,
            dueDate: _dueDate,
          );
      if (mounted) {
        Navigator.pop(context, true);
        AppSnackBar.showSuccess(context, context.loc.newTask);
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
}
