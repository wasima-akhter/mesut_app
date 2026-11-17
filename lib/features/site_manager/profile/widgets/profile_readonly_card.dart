import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';

class ProfileReadonlyCard extends StatelessWidget {
  const ProfileReadonlyCard({
    super.key,
    required this.email,
    required this.role,
  });

  final String email;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 15.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                context.loc.contactInformation,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _infoRow(
            icon: Icons.email_outlined,
            label: context.loc.email,
            value: email.isNotEmpty ? email : '-',
          ),
          SizedBox(height: 8.h),
          _infoRow(
            icon: Icons.badge_outlined,
            label: context.loc.role,
            value: _formatRole(context, role),
          ),
        ],
      ),
    );
  }

  String _formatRole(BuildContext context, String role) {
    switch (role.toUpperCase()) {
      case 'EMPLOYEE':
        return context.loc.roleEmployee;
      case 'SITE_MANAGER':
        return context.loc.roleSiteManager;
      default:
        return role.isNotEmpty ? role : '-';
    }
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
