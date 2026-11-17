import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/services/launcher_service.dart';

class SiteManagerContactCard extends StatelessWidget {
  const SiteManagerContactCard({
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
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.contactInformation,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 10.h),
          _contactRow(
            context,
            icon: Icons.phone_outlined,
            text: phone.isNotEmpty ? phone : '-',
            onTap: phone.isNotEmpty
                ? () => AppLauncherService.makePhoneCall(phone)
                : null,
          ),
          _contactRow(
            context,
            icon: Icons.email_outlined,
            text: email.isNotEmpty ? email : '-',
            onTap: email.isNotEmpty
                ? () => AppLauncherService.sendEmail(email: email)
                : null,
          ),
          _contactRow(
            context,
            icon: Icons.language_rounded,
            text: language.toUpperCase() == 'EN'
                ? '${context.loc.english} (EN)'
                : '${context.loc.german} (DE)',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _contactRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            children: [
              Icon(icon, size: 18.sp, color: AppColors.textSecondary),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: onTap != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.sp,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
