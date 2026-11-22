import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/constants/route_constants.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../domain/entities/employee_project_details_entity.dart';

class AssignmentDetailPhotosCard extends StatelessWidget {
  final String projectId;
  final String projectTitle;
  final int photoCount;
  final List<EmployeeProjectPhotoEntity> photos;

  const AssignmentDetailPhotosCard({
    super.key,
    required this.projectId,
    required this.projectTitle,
    required this.photoCount,
    this.photos = const [],
  });

  void _openPhotos(BuildContext context) {
    context.push(
      RouteConstants.employeeAssignmentPhotos,
      extra: {
        'projectId': projectId,
        'title': projectTitle,
      },
    );
  }

  Widget _thumbnail(EmployeeProjectPhotoEntity photo) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        photo.url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _placeholder(IconData icon) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Center(
        child: Icon(icon, color: AppColors.textTertiary, size: 28.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPhotos = photos.take(3).toList();
    final count = photoCount > 0 ? photoCount : photos.length;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.loc.smPhotos} ($count)',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AppTextButton(
                onPressed: () => _openPhotos(context),
                text: '${context.loc.viewAll} →',
                foregroundColor: AppColors.textSecondary,
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) SizedBox(width: 8.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openPhotos(context),
                    child: i < displayPhotos.length
                        ? _thumbnail(displayPhotos[i])
                        : _placeholder(
                            i == 0
                                ? Icons.business
                                : (i == 1
                                    ? Icons.construction
                                    : Icons.apartment),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
