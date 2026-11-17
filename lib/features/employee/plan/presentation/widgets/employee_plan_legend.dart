import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';

class EmployeePlanLegend extends StatelessWidget {
  const EmployeePlanLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _legendItem(AppColors.success, context.loc.scaffoldErection),
          SizedBox(width: 16.w),
          _legendItem(AppColors.warning, context.loc.scaffoldDismantling),
          SizedBox(width: 16.w),
          _legendItem(AppColors.info, context.loc.otherActivity),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
