import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/buttons/buttons.dart';

class ProfileEditHeader extends StatelessWidget {
  const ProfileEditHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 0),
      child: Row(
        children: [
          AppBackButton(
            size: 39.w,
            iconSize: 19.sp,
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.loc.editProfile,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          SizedBox(width: 39.w),
        ],
      ),
    );
  }
}
