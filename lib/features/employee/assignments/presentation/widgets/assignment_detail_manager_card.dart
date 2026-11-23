import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/services/launcher_service.dart';
import '../../../../../core/widgets/images/app_network_image.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../shared/helper/employee_models.dart';
import '../../domain/entities/employee_project_details_entity.dart';

class AssignmentDetailManagerCard extends StatelessWidget {
  final EmployeeProjectManagerEntity? manager;
  final EmployeeAssignmentModel? fallback;

  const AssignmentDetailManagerCard({
    super.key,
    this.manager,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final name = manager?.fullName.isNotEmpty == true
        ? manager!.fullName
        : (fallback?.siteManager ?? 'Site Manager');
    final phone = manager?.phone;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neutral200,
            ),
            clipBehavior: Clip.antiAlias,
            child: AppNetworkImage(
              imageUrl: manager?.avatarUrl,
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
              fallback: const Icon(
                Icons.person,
                color: AppColors.neutral500,
                size: 27,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  context.loc.manager,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (phone != null && phone.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final success = await AppLauncherService.makePhoneCall(phone);
                if (!success && context.mounted) {
                  AppSnackBar.showInfo(context, context.loc.callingContact);
                }
              },
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.infoLight,
                ),
                child: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.info,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
