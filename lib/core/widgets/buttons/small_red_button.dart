import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_button.dart';

/// Small red/danger button used in inspection, calendar, and survey badges.
///
/// Wraps [AppButton.small] with the danger variant, compact padding, and
/// no fixed heights, allowing text to dynamically scale.
class SmallRedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const SmallRedButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.small(
      text: text,
      onPressed: onTap,
      variant: AppButtonVariant.danger,
      borderRadius: 6.r,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      textStyle: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }
}
