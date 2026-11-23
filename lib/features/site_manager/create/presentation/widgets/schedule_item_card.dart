import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/extensions/date_time_extensions.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../domain/entities/create_project_entity.dart';
import 'create_project_form_helpers.dart';

class ScheduleItemCard extends StatelessWidget {
  final int index;
  final CreateScheduleItem item;
  final ValueChanged<CreateScheduleItem> onChanged;
  final VoidCallback? onRemove;

  const ScheduleItemCard({
    super.key,
    required this.index,
    required this.item,
    required this.onChanged,
    this.onRemove,
  });

  static const List<String> availableTypes = [
    'erection',
    'dismantling',
    'standing',
    'maintenance',
  ];

  String _typeLabel(BuildContext context, String type) {
    return switch (type.toLowerCase()) {
      'erection' => context.loc.erectionPhase,
      'dismantling' => context.loc.dismantlingPhase,
      'standing' => context.loc.standingScaffold,
      'maintenance' => context.loc.maintenance,
      _ => MobilePhaseLocalizer.phaseType(context, type),
    };
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? item.startDate : item.endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      if (isStart) {
        var end = item.endDate;
        if (picked.isAfter(end)) {
          end = picked.add(Duration(days: item.durationDays.round()));
        }
        final days = end.difference(picked).inDays.toDouble();
        onChanged(item.copyWith(
          startDate: picked,
          endDate: end,
          durationDays: days > 0 ? days : 1,
        ));
      } else {
        var start = item.startDate;
        if (picked.isBefore(start)) {
          start = picked;
        }
        final days = picked.difference(start).inDays.toDouble();
        onChanged(item.copyWith(
          startDate: start,
          endDate: picked,
          durationDays: days > 0 ? days : 1,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = MobilePhaseLocalizer.phaseColor(item.type);

    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _typeLabel(context, item.type),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                ),
              ),
              const Spacer(),
              if (onRemove != null)
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          const FormFieldLabelSmall(label: 'Phase Type'),
          SizedBox(height: 6.h),
          Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: const Color(0xFFDCDCDC)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: availableTypes.contains(item.type.toLowerCase())
                    ? item.type.toLowerCase()
                    : availableTypes.first,
                isExpanded: true,
                items: availableTypes.map((t) {
                  return DropdownMenuItem<String>(
                    value: t,
                    child: Text(
                      _typeLabel(context, t),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    onChanged(item.copyWith(type: val));
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormFieldLabelSmall(label: context.loc.startDate),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: () => _pickDate(context, true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDCDCDC)),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 14, color: Color(0xFF666666)),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                item.startDate.formatLocalized(),
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormFieldLabelSmall(label: context.loc.endDate),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: () => _pickDate(context, false),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDCDCDC)),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 14, color: Color(0xFF666666)),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                item.endDate.formatLocalized(),
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.loc.duration,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (item.durationDays > 1) {
                    final d = item.durationDays - 1;
                    onChanged(item.copyWith(
                      durationDays: d,
                      endDate: item.startDate.add(Duration(days: d.round())),
                    ));
                  }
                },
                child: Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD0D0D0)),
                  ),
                  child: const Icon(Icons.remove, size: 14),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '${item.durationDays.round()} d',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () {
                  final d = item.durationDays + 1;
                  onChanged(item.copyWith(
                    durationDays: d,
                    endDate: item.startDate.add(Duration(days: d.round())),
                  ));
                },
                child: Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD0D0D0)),
                  ),
                  child: const Icon(Icons.add, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
