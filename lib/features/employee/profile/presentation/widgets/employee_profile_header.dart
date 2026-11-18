import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/app_icon_button.dart';
import 'package:construction_app/core/widgets/images/app_network_image.dart';
import '../../../../shared/mobile_dashboard/domain/entities/mobile_profile_entity.dart';

class EmployeeProfileHeader extends StatelessWidget {
  const EmployeeProfileHeader({super.key, required this.profile});

  final MobileProfileEntity? profile;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?.avatarUrl;
    final fullName = (profile?.fullName.isNotEmpty == true)
        ? profile!.fullName
        : '-';
    final role = profile?.role ?? '';
    final roleTitle = role.toUpperCase() == 'EMPLOYEE'
        ? context.loc.roleEmployee
        : (role.toUpperCase() == 'SITE_MANAGER'
              ? context.loc.roleSiteManager
              : (role.isNotEmpty ? role : context.loc.roleEmployee));

    return Column(
      children: [
        _buildTopBar(context),
        SizedBox(height: 18.h),
        Stack(
          children: [
            Container(
              width: 92.w,
              height: 92.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neutral200,
              ),
              child: ClipOval(
                child: AppNetworkImage(
                  imageUrl: avatarUrl,
                  width: 92.w,
                  height: 92.w,
                  fit: BoxFit.cover,
                  fallback: const Icon(
                    Icons.person,
                    size: 45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 1,
              child: GestureDetector(
                onTap: () => context.push(RouteConstants.employeeProfileEdit),
                child: Container(
                  width: 31.w,
                  height: 31.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          fullName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          roleTitle,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Text(
            context.loc.projectFilterActive,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 50.w),
        Expanded(
          child: Center(
            child: Text(
              context.loc.profile,
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        AppIconButton.circle(
          icon: Icons.edit_outlined,
          onPressed: () => context.push(RouteConstants.employeeProfileEdit),
          size: 46.w,
          border: Border.all(color: AppColors.border),
          backgroundColor: AppColors.white,
          iconColor: AppColors.textPrimary,
          iconSize: 22,
        ),
      ],
    );
  }
}
