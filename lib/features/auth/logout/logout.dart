import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/app_localization.dart';

class LogoutConfirmation {
  LogoutConfirmation._();

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onLogout,
  }) async {
    final loc = AppLocalization.current;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            loc.logoutTitle,
            style: TextStyle(
              fontSize: 21.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            loc.logoutConfirmation,
            style: TextStyle(fontSize: 17.sp, color: AppColors.textSecondary),
          ),
          actions: [
            AppTextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              text: loc.cancel,
              foregroundColor: AppColors.textSecondary,
              textStyle: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            AppTextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onLogout();
              },
              text: loc.logout,
              foregroundColor: AppColors.primary,
              textStyle: TextStyle(
                fontSize: 17.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
    );
  }
}
