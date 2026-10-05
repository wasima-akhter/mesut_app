import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              'Changes here automatically update Calendar and Daily Planning.',
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
      title: 'Erection Schedule',
      children: [
        _dateRow(
          label: 'Start date',
          date: _erectionStart,
          onTap: _selectErectionStartDate,
        ),

        SizedBox(height: 8.h),

        _durationRow(
          label: 'Duration',
          value: _erectionDuration,
          onMinus: () => _changeErectionDuration(-0.5),
          onPlus: () => _changeErectionDuration(0.5),
        ),

        SizedBox(height: 8.h),

        _dateValueRow(label: 'End date', value: _formatDate(_erectionEnd)),
      ],
    );
  }

  // ============================================================
  // DISMANTLING
  // ============================================================

  Widget _buildDismantlingSchedule() {
    return _scheduleCard(
      title: 'Dismantling Schedule',
      children: [
        _dateRow(
          label: 'Planned date',
          date: _dismantlingDate,
          onTap: _selectDismantlingDate,
        ),

        SizedBox(height: 8.h),

        _durationRow(
          label: 'Duration',
          value: _dismantlingDuration,
          onMinus: () => _changeDismantlingDuration(-0.5),
          onPlus: () => _changeDismantlingDuration(0.5),
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
            'Safety Inspection',
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
              'Next Safety Inspection: Sept 18 – Sept 20 (2.5 days)',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFFF79009),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          SizedBox(
            width: double.infinity,
            height: 43.h,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _safetyInspectionCompleted = !_safetyInspectionCompleted;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _safetyInspectionCompleted
                    ? const Color(0xFF12B76A)
                    : Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                _safetyInspectionCompleted
                    ? '✓ Inspection Completed'
                    : 'Mark as Complete',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC8102E),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE49AA6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: _saving
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Save Changes',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
              ),
      ),
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
                    '${_formatDuration(value)} days',
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
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32.w,
        height: 34.h,
        child: Icon(icon, size: 16.sp, color: const Color(0xFF555555)),
      ),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Schedule changes saved',
          style: TextStyle(fontSize: 17.sp),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDuration(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}
