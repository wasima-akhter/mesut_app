import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/services/launcher_service.dart';
import 'package:construction_app/core/widgets/snack/app_snackbar.dart';

class EmployeeContactCard extends StatelessWidget {
  const EmployeeContactCard({
    super.key,
    required this.phone,
    required this.email,
    required this.language,
  });

  final String phone;
  final String email;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(13.w, 13.h, 13.w, 3.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.contactInformation,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          _contactRow(
            context,
            Icons.phone_outlined,
            phone.isNotEmpty ? phone : '-',
          ),
          _contactRow(
            context,
            Icons.mail_outline_rounded,
            email.isNotEmpty ? email : '-',
          ),
          _contactRow(
            context,
            Icons.language_rounded,
            language.toUpperCase() == 'EN'
                ? '${context.loc.english} (EN)'
                : '${context.loc.german} (DE)',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _contactRow(
    BuildContext context,
    IconData icon,
    String text, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            if (text.isEmpty || text == '-') return;
            if (icon == Icons.phone_outlined) {
              final success = await AppLauncherService.makePhoneCall(text);
              if (!success && context.mounted) {
                AppSnackBar.showInfo(context, text);
              }
            } else if (icon == Icons.mail_outline_rounded) {
              final success = await AppLauncherService.sendEmail(email: text);
              if (!success && context.mounted) {
                AppSnackBar.showInfo(context, text);
              }
            } else {
              AppSnackBar.showInfo(context, text);
            }
          },
          borderRadius: BorderRadius.circular(7.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textSecondary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
