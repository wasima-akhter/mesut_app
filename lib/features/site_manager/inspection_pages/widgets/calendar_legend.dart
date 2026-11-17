import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _legendItem(context, AppColors.success, context.loc.erectionPhase),
            SizedBox(width: 14.w),
            _legendItem(
              context,
              AppColors.warning,
              context.loc.dismantlingPhase,
            ),
            SizedBox(width: 14.w),
            _legendItem(
              context,
              AppColors.info,
              context.loc.halfDay,
            ),
            SizedBox(width: 14.w),
            _legendItem(
              context,
              AppColors.primary,
              context.loc.inspections,
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
