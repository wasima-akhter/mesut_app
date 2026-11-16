import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';

class ProjectPhotosToolbar extends StatelessWidget {
  final int photoCount;
  final int planCount;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onUploadPressed;

  const ProjectPhotosToolbar({
    super.key,
    required this.photoCount,
    required this.planCount,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onUploadPressed,
  });

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF222222) : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: selected ? const Color(0xFF222222) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: selected ? Colors.white : const Color(0xFF555555),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildFilterChip(
          label: '${context.loc.photos} ($photoCount)',
          selected: activeFilter == 'all' || activeFilter == 'photos',
          onTap: () =>
              onFilterChanged(activeFilter == 'photos' ? 'all' : 'photos'),
        ),
        SizedBox(width: 8.w),
        _buildFilterChip(
          label: '${context.loc.pdfPlans} ($planCount)',
          selected: activeFilter == 'plans',
          onTap: () => onFilterChanged(activeFilter == 'plans' ? 'all' : 'plans'),
        ),
        const Spacer(),
        AppButton.small(
          variant: AppButtonVariant.danger,
          onPressed: onUploadPressed,
          leadingIcon: Icons.upload_outlined,
          text: context.loc.uploadFiles,
          borderRadius: 6.r,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        ),
      ],
    );
  }
}
