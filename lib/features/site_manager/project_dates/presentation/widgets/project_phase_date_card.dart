import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../domain/entities/project_phase_dates_entity.dart';
import 'project_phase_duration_field.dart';

class ProjectPhaseDateCard extends StatefulWidget {
  final ProjectPhaseDateItemEntity phase;
  final bool isSaving;
  final Future<void> Function({
    required DateTime startDate,
    required DateTime endDate,
    required int durationDays,
    bool? safetyInspectionComplete,
  }) onSave;

  const ProjectPhaseDateCard({
    super.key,
    required this.phase,
    required this.isSaving,
    required this.onSave,
  });

  @override
  State<ProjectPhaseDateCard> createState() => _ProjectPhaseDateCardState();
}

class _ProjectPhaseDateCardState extends State<ProjectPhaseDateCard> {
  late DateTime _startDate;
  late DateTime _endDate;
  late int _durationDays;
  late bool _safetyInspectionComplete;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _resetFromWidget();
  }

  @override
  void didUpdateWidget(covariant ProjectPhaseDateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) _resetFromWidget();
  }

  void _resetFromWidget() {
    _startDate = widget.phase.startDate ?? DateTime.now();
    _durationDays =
        widget.phase.durationDays > 0 ? widget.phase.durationDays : 1;
    _endDate =
        widget.phase.endDate ?? _startDate.add(Duration(days: _durationDays));
    _safetyInspectionComplete = widget.phase.safetyInspectionComplete;
    _hasChanges = false;
  }

  void _recalculateEndDate() {
    _endDate = _startDate.add(Duration(days: _durationDays));
    _hasChanges = true;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      _recalculateEndDate();
    });
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isAfter(_startDate) ? _endDate : _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      final diff = _endDate.difference(_startDate).inDays;
      _durationDays = diff > 0 ? diff : 1;
      _hasChanges = true;
    });
  }

  void _changeDuration(int next) {
    setState(() {
      _durationDays = next;
      _recalculateEndDate();
    });
  }

  Future<void> _handleSave() async {
    await widget.onSave(
      startDate: _startDate,
      endDate: _endDate,
      durationDays: _durationDays,
      safetyInspectionComplete: _safetyInspectionComplete,
    );
    if (mounted) setState(() => _hasChanges = false);
  }

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: widget.phase.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.phase.iconData,
                  size: 18.sp,
                  color: widget.phase.color,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.phase.displayTitle,
                  style: TextStyle(
                    fontSize: 17.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  MobilePhaseLocalizer.status(context, widget.phase.status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _dateField(context.loc.startDate, _startDate, _selectStartDate),
          SizedBox(height: 10.h),
          ProjectPhaseDurationField(
            durationDays: _durationDays,
            onDurationChanged: _changeDuration,
          ),
          SizedBox(height: 10.h),
          _dateField(context.loc.endDate, _endDate, _selectEndDate),
          if (widget.phase.type.toUpperCase().contains('ERECTION')) ...[
            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            SizedBox(height: 12.h),
            _safetyField(),
          ],
          if (_hasChanges) ...[
            SizedBox(height: 14.h),
            AppButton(
              text: context.loc.saveChanges,
              onPressed: _handleSave,
              isLoading: widget.isSaving,
              borderRadius: 6.r,
              verticalPadding: 8.h,
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateField(String label, DateTime date, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15.5.sp, color: const Color(0xFF6B7280)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 17.sp,
                color: const Color(0xFF555555),
              ),
              SizedBox(width: 6.w),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _safetyField() {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.loc.safetyInspection,
            style: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _safetyInspectionComplete = !_safetyInspectionComplete;
              _hasChanges = true;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _safetyInspectionComplete
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: _safetyInspectionComplete
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            child: Text(
              _safetyInspectionComplete
                  ? context.loc.inspectionCompleted
                  : context.loc.markAsComplete,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: _safetyInspectionComplete
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF616161),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
