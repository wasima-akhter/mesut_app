// employee_time_dialogs.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import 'employee_enums.dart';

class EmployeeProjectModel {
  final String id;
  final String name;

  const EmployeeProjectModel({required this.id, required this.name});

  String get displayName => '$id · $name';
}

// ============================================================
// DEFAULT PROJECTS
// ============================================================

const List<EmployeeProjectModel> employeeProjects = [
  EmployeeProjectModel(id: 'PRJ-0842', name: 'Goltstein.Complex'),
  EmployeeProjectModel(id: 'PRJ-0845', name: 'Riverside Tower'),
  EmployeeProjectModel(id: 'PRJ-0850', name: 'Central Plaza'),
];

// ============================================================
// 1. START NEW TIMER
// ============================================================

Future<void> showStartNewTimerSheet({
  required BuildContext context,
  EmployeeProjectModel? selectedProject,
  EmployeeActivityType? selectedActivity,
  required VoidCallback onStart,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .55),
    builder: (_) {
      return _StartNewTimerSheet(
        initialProject: selectedProject,
        initialActivity: selectedActivity,
        onStart: onStart,
      );
    },
  );
}

class _StartNewTimerSheet extends StatefulWidget {
  final EmployeeProjectModel? initialProject;
  final EmployeeActivityType? initialActivity;
  final VoidCallback onStart;

  const _StartNewTimerSheet({
    required this.initialProject,
    required this.initialActivity,
    required this.onStart,
  });

  @override
  State<_StartNewTimerSheet> createState() => _StartNewTimerSheetState();
}

class _StartNewTimerSheetState extends State<_StartNewTimerSheet> {
  late EmployeeProjectModel? selectedProject;
  late EmployeeActivityType? selectedActivity;

  @override
  void initState() {
    super.initState();

    selectedProject = widget.initialProject ?? employeeProjects.first;

    selectedActivity = widget.initialActivity ?? EmployeeActivityType.erection;
  }

  void _startTimer() {
    if (selectedProject == null || selectedActivity == null) {
      return;
    }

    Navigator.of(context).pop();
    widget.onStart();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _SheetHandle()),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.loc.startNewTimer,
                    style: TextStyle(
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    context.loc.timerNotice,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: 22.h),

                  _FieldLabel(context.loc.assignedProject),

                  SizedBox(height: 8.h),

                  _EmployeeDropdown<EmployeeProjectModel>(
                    value: selectedProject,
                    items: employeeProjects,
                    itemLabel: (item) => item.displayName,
                    hint: context.loc.selectProject,
                    onChanged: (value) {
                      setState(() {
                        selectedProject = value;
                      });
                    },
                  ),

                  SizedBox(height: 18.h),

                  _FieldLabel(context.loc.activityType),

                  SizedBox(height: 8.h),

                  _EmployeeDropdown<EmployeeActivityType>(
                    value: selectedActivity,
                    items: EmployeeActivityType.values,
                    itemLabel: (item) => item.label,
                    hint: context.loc.selectActivity,
                    onChanged: (value) {
                      setState(() {
                        selectedActivity = value;
                      });
                    },
                  ),

                  SizedBox(height: 18.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(13.w),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 21.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 9.w),
                        Expanded(
                          child: Text(
                            context.loc.timerNotice,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),

                  _PrimarySheetButton(
                    text: context.loc.startNewTimer,
                    icon: Icons.play_arrow_rounded,
                    onTap: _startTimer,
                  ),

                  SizedBox(height: 10.h),

                  _CancelButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 2. ADD TIME ENTRY
// ============================================================

Future<void> showAddTimeEntrySheet({
  required BuildContext context,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .55),
    builder: (_) {
      return _AddTimeEntrySheet(onSaved: onSaved);
    },
  );
}

class _AddTimeEntrySheet extends StatefulWidget {
  final VoidCallback onSaved;

  const _AddTimeEntrySheet({required this.onSaved});

  @override
  State<_AddTimeEntrySheet> createState() => _AddTimeEntrySheetState();
}

class _AddTimeEntrySheetState extends State<_AddTimeEntrySheet> {
  DateTime selectedDate = DateTime(2026, 10, 12);

  EmployeeProjectModel? selectedProject = employeeProjects.first;

  EmployeeActivityType? selectedActivity = EmployeeActivityType.erection;

  TimeOfDay startTime = const TimeOfDay(hour: 7, minute: 30);

  TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 30);

  Duration breakTime = const Duration(minutes: 45);

  Future<void> _selectDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: startTime,
    );

    if (result != null) {
      setState(() {
        startTime = result;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final result = await showTimePicker(context: context, initialTime: endTime);

    if (result != null) {
      setState(() {
        endTime = result;
      });
    }
  }

  Future<void> _selectBreakTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 45),
    );

    if (result != null) {
      setState(() {
        breakTime = Duration(hours: result.hour, minutes: result.minute);
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.period == DayPeriod.am ? 'am' : 'pm';

    return '$hour:$minute $period';
  }

  String _formatBreak() {
    if (breakTime.inHours > 0) {
      return '${breakTime.inHours}h ${breakTime.inMinutes.remainder(60)}m';
    }

    return '${breakTime.inMinutes}m';
  }

  void _saveEntry() {
    if (selectedProject == null || selectedActivity == null) {
      return;
    }

    Navigator.of(context).pop();
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _SheetHandle()),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 25.h),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.loc.addTimeEntry,
                    style: TextStyle(
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 22.h),

                  _FieldLabel(context.loc.date),

                  SizedBox(height: 8.h),

                  _ActionField(
                    text: _formatDate(selectedDate),
                    icon: Icons.calendar_month_outlined,
                    onTap: _selectDate,
                  ),

                  SizedBox(height: 18.h),

                  _FieldLabel(context.loc.assignedProject),

                  SizedBox(height: 8.h),

                  _EmployeeDropdown<EmployeeProjectModel>(
                    value: selectedProject,
                    items: employeeProjects,
                    itemLabel: (item) => item.displayName,
                    hint: context.loc.selectProject,
                    onChanged: (value) {
                      setState(() {
                        selectedProject = value;
                      });
                    },
                  ),

                  SizedBox(height: 18.h),

                  _FieldLabel(context.loc.activityType),

                  SizedBox(height: 8.h),

                  _EmployeeDropdown<EmployeeActivityType>(
                    value: selectedActivity,
                    items: EmployeeActivityType.values,
                    itemLabel: (item) => item.label,
                    hint: context.loc.selectActivity,
                    onChanged: (value) {
                      setState(() {
                        selectedActivity = value;
                      });
                    },
                  ),

                  SizedBox(height: 18.h),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel(context.loc.startTime),

                            SizedBox(height: 8.h),

                            _ActionField(
                              text: _formatTime(startTime),
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
                            _FieldLabel(context.loc.endTime),

                            SizedBox(height: 8.h),

                            _ActionField(
                              text: _formatTime(endTime),
                              icon: Icons.access_time_rounded,
                              onTap: _selectEndTime,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  _FieldLabel(context.loc.breakTime),

                  SizedBox(height: 8.h),

                  _ActionField(
                    text: _formatBreak(),
                    icon: Icons.free_breakfast_outlined,
                    onTap: _selectBreakTime,
                  ),

                  SizedBox(height: 15.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(13.w),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      context.loc.autoDeductNotice,
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  SizedBox(height: 22.h),

                  _PrimarySheetButton(
                    text: context.loc.saveEntry,
                    onTap: _saveEntry,
                  ),

                  SizedBox(height: 10.h),

                  _CancelButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 3. FINISH WORK
// ============================================================

Future<void> showFinishWorkSheet({
  required BuildContext context,
  required String projectName,
  required String totalLogged,
  required VoidCallback onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .55),
    builder: (_) {
      return _FinishWorkSheet(
        projectName: projectName,
        totalLogged: totalLogged,
        onSave: onSave,
      );
    },
  );
}

class _FinishWorkSheet extends StatefulWidget {
  final String projectName;
  final String totalLogged;
  final VoidCallback onSave;

  const _FinishWorkSheet({
    required this.projectName,
    required this.totalLogged,
    required this.onSave,
  });

  @override
  State<_FinishWorkSheet> createState() => _FinishWorkSheetState();
}

class _FinishWorkSheetState extends State<_FinishWorkSheet> {
  bool saving = false;

  Future<void> _save() async {
    setState(() {
      saving = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.of(context).pop();

    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _SheetHandle()),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 58.w,
                    height: 58.w,
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 31.sp,
                      color: AppColors.info,
                    ),
                  ),

                  SizedBox(height: 17.h),

                  Text(
                    context.loc.finishWork,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    context.loc.finishWork,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    widget.projectName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 13.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          context.loc.totalHoursLogged,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          widget.totalLogged,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: .55,
                        ),
                        minimumSize: Size.fromHeight(50.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                      ),
                      child: saving
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.loc.saveEntry,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  _CancelButton(
                    onTap: saving ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED SHEET CONTAINER
// ============================================================

class _SheetContainer extends StatelessWidget {
  final Widget child;

  const _SheetContainer({required this.child});

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
      child: child,
    );
  }
}

// ============================================================
// HANDLE
// ============================================================

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42.w,
        height: 5.h,
        margin: EdgeInsets.only(top: 8.h),
        decoration: BoxDecoration(
          color: AppColors.neutral300,
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}

// ============================================================
// FIELD LABEL
// ============================================================

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ============================================================
// DROPDOWN
// ============================================================

class _EmployeeDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String hint;
  final ValueChanged<T?> onChanged;

  const _EmployeeDropdown({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 23.sp,
        color: AppColors.textSecondary,
      ),
      style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 16.sp, color: AppColors.textDisabled),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.r),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.r),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.3),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel(item),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

// ============================================================
// ACTION FIELD
// ============================================================

class _ActionField extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionField({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(7.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(icon, size: 21.sp, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRIMARY BUTTON
// ============================================================

class _PrimarySheetButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const _PrimarySheetButton({
    required this.text,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: Size.fromHeight(50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 21.sp),
              SizedBox(width: 7.w),
            ],
            Text(
              text,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CANCEL BUTTON
// ============================================================

class _CancelButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          minimumSize: Size.fromHeight(48.h),
          foregroundColor: AppColors.textSecondary,
        ),
        child: Text(
          context.loc.cancel,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
