import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';

class DatesTab extends StatefulWidget {
  const DatesTab({super.key});

  @override
  State<DatesTab> createState() => _DatesTabState();
}

class _DatesTabState extends State<DatesTab> {
  DateTime _erectionStart = DateTime(2026, 9, 18);
  double _erectionDuration = 2.5;

  DateTime _dismantlingDate = DateTime(2026, 9, 18);
  double _dismantlingDuration = 2.5;

  bool _safetyInspectionCompleted = false;
  bool _saving = false;

  DateTime get _erectionEnd {
    return _erectionStart.add(
      Duration(hours: (_erectionDuration * 24).round()),
    );
  }

  DateTime get _dismantlingEnd {
    return _dismantlingDate.add(
      Duration(hours: (_dismantlingDuration * 24).round()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 30.h),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _buildInfoBanner(),

                SizedBox(height: 10.h),

                _buildErectionSchedule(),

                SizedBox(height: 10.h),

                _buildDismantlingSchedule(),

                SizedBox(height: 10.h),

                _buildSafetyInspection(),

                SizedBox(height: 12.h),

                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FF),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: const Color(0xFF1799D6), size: 18.sp),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              context.loc.changesNotice,
              style: TextStyle(
                fontSize: 16.5.sp,
                color: const Color(0xFF1799D6),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERECTION
  // ============================================================

  Widget _buildErectionSchedule() {
    return _scheduleCard(
      title: context.loc.erectionSchedule,
      children: [
        _dateRow(
          label: context.loc.startDate,
          date: _erectionStart,
          onTap: _selectErectionStartDate,
        ),

        SizedBox(height: 8.h),

        _durationRow(
          label: context.loc.duration,
          value: _erectionDuration,
          onMinus: () => _changeErectionDuration(-0.5),
          onPlus: () => _changeErectionDuration(0.5),
        ),

        SizedBox(height: 8.h),

        _dateValueRow(
          label: context.loc.endDate,
          value: _formatDate(_erectionEnd),
        ),
      ],
    );
  }

  // ============================================================
  // DISMANTLING
  // ============================================================

  Widget _buildDismantlingSchedule() {
    return _scheduleCard(
      title: context.loc.dismantlingSchedule,
      children: [
        _dateRow(
          label: context.loc.plannedDateLabel,
          date: _dismantlingDate,
          onTap: _selectDismantlingDate,
        ),

        SizedBox(height: 8.h),

        _durationRow(
          label: context.loc.duration,
          value: _dismantlingDuration,
          onMinus: () => _changeDismantlingDuration(-0.5),
          onPlus: () => _changeDismantlingDuration(0.5),
        ),

        SizedBox(height: 8.h),

        _dateValueRow(
          label: context.loc.endDate,
          value: _formatDate(_dismantlingEnd),
        ),
      ],
    );
  }

  // ============================================================
  // SAFETY
  // ============================================================

  Widget _buildSafetyInspection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.safetyInspection,
            style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w800),
          ),

          SizedBox(height: 10.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DC),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text(
              context.loc.nextSafetyInspection('Sept 18 – Sept 20 (2.5 days)'),
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFFF79009),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          AppButton(
            text: _safetyInspectionCompleted
                ? context.loc.inspectionCompleted
                : context.loc.markAsComplete,
            onPressed: () {
              setState(() {
                _safetyInspectionCompleted = !_safetyInspectionCompleted;
              });
            },
            variant: _safetyInspectionCompleted
                ? AppButtonVariant.success
                : AppButtonVariant.dark,
            borderRadius: 6.r,
            verticalPadding: 10.h,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Widget _buildSaveButton() {
    return AppButton(
      text: context.loc.saveChanges,
      onPressed: _saveChanges,
      isLoading: _saving,
      borderRadius: 6.r,
    );
  }

  // ============================================================
  // REUSABLE DATE UI
  // ============================================================

  Widget _dateRow({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF888888)),
          ),
        ),

        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16.sp,
                color: const Color(0xFF555555),
              ),
              SizedBox(width: 6.w),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF444444),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateValueRow({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF888888)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.5.sp,
            color: const Color(0xFF666666),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _durationRow({
    required String label,
    required double value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF888888)),
          ),
        ),

        Container(
          height: 34.h,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E2E2)),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              _smallIconButton(icon: Icons.remove, onTap: onMinus),

              SizedBox(
                // width: 58.w,
                child: Center(
                  child: Text(
                    context.loc.durationDays(_formatDuration(value)),
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              _smallIconButton(icon: Icons.add, onTap: onPlus),
            ],
          ),
        ),
      ],
    );
  }

  Widget _smallIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AppIconButton(
      icon: icon,
      onPressed: onTap,
      size: 32.w,
      iconColor: const Color(0xFF555555),
      iconSize: 16.sp,
    );
  }

  Widget _scheduleCard({
    required String title,
    required List<Widget> children,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.5.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: child,
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _selectErectionStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _erectionStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date == null) return;

    setState(() {
      _erectionStart = date;
    });
  }

  Future<void> _selectDismantlingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dismantlingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date == null) return;

    setState(() {
      _dismantlingDate = date;
    });
  }

  void _changeErectionDuration(double amount) {
    setState(() {
      _erectionDuration = (_erectionDuration + amount).clamp(0.5, 30.0);
    });
  }

  void _changeDismantlingDuration(double amount) {
    setState(() {
      _dismantlingDuration = (_dismantlingDuration + amount).clamp(0.5, 30.0);
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      _saving = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _saving = false;
    });

    AppSnackBar.showSuccess(
      context,
      context.loc.scheduleChangesSaved,
    );
  }

  String _formatDate(DateTime date) {
    return date.formatLocalized();
  }

  String _formatDuration(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}
