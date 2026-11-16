import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';

class ProjectPhaseDurationField extends StatelessWidget {
  final int durationDays;
  final ValueChanged<int> onDurationChanged;

  const ProjectPhaseDurationField({
    super.key,
    required this.durationDays,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.loc.duration,
          style: TextStyle(fontSize: 15.5.sp, color: const Color(0xFF6B7280)),
        ),
        Container(
          height: 36.h,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E2E2)),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconButton(
                icon: Icons.remove,
                onPressed: () {
                  if (durationDays > 1) {
                    onDurationChanged(durationDays - 1);
                  }
                },
                size: 32.w,
                iconColor: const Color(0xFF555555),
                iconSize: 16.sp,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  context.loc.durationDays('$durationDays'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppIconButton(
                icon: Icons.add,
                onPressed: () => onDurationChanged(durationDays + 1),
                size: 32.w,
                iconColor: const Color(0xFF555555),
                iconSize: 16.sp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
