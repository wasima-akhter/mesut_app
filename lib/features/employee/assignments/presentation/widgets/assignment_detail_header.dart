import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';

class AssignmentDetailHeader extends StatelessWidget {
  final VoidCallback? onBack;

  const AssignmentDetailHeader({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppBackButton(onPressed: onBack),
        SizedBox(width: 14.w),
        Text(
          context.loc.assignmentDetail,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
