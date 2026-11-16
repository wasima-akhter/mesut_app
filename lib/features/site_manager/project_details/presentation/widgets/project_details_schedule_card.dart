import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../domain/entities/project_details_entity.dart';

class ProjectDetailsScheduleCard extends StatelessWidget {
  final List<ProjectScheduleData> scheduleData;
  final List<ProjectPhaseItem> phases;

  const ProjectDetailsScheduleCard({
    super.key,
    required this.scheduleData,
    required this.phases,
  });

  @override
  Widget build(BuildContext context) {
    if (scheduleData.isEmpty && phases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.scheduleAndDuration,
            style: TextStyle(fontSize: 18.5.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),
          if (scheduleData.isNotEmpty) ...[
            ...scheduleData.map((item) {
              final color = MobilePhaseLocalizer.phaseColor(item.type);
              final dateRange = MobilePhaseLocalizer.formatDateRange(
                item.startDate,
                item.endDate,
              );
              final duration = item.durationDays > 0
                  ? context.loc.durationDays('${item.durationDays}')
                  : '';

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _ScheduleRow(
                  color: color,
                  title: MobilePhaseLocalizer.phaseType(context, item.type),
                  date: dateRange,
                  duration: duration,
                ),
              );
            }),
          ] else ...[
            ...phases.map((phase) {
              final color = MobilePhaseLocalizer.phaseColor(phase.type);
              final dateRange = MobilePhaseLocalizer.formatDateRange(
                phase.startDate,
                phase.endDate,
              );
              final duration = phase.durationDays > 0
                  ? context.loc.durationDays('${phase.durationDays}')
                  : '';

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _ScheduleRow(
                  color: color,
                  title: MobilePhaseLocalizer.phaseType(context, phase.type),
                  date: dateRange,
                  duration: duration,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final Color color;
  final String title;
  final String date;
  final String duration;

  const _ScheduleRow({
    required this.color,
    required this.title,
    required this.date,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final subText = duration.isNotEmpty ? '$date • $duration' : date;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          margin: EdgeInsets.only(top: 5.h),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.5.sp,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subText,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
