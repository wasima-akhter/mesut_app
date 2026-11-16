import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../domain/entities/project_measurement_entity.dart';

/// Card widget rendering a single measurement line item with edit & delete actions.
class ProjectMeasurementCard extends StatelessWidget {
  final ProjectMeasurementEntity item;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectMeasurementCard({
    super.key,
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldTitle = item.scaffoldType.isNotEmpty
        ? item.scaffoldType
        : context.loc.frontScaffold;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Line number & Position + Action icons
          Row(
            children: [
              Expanded(
                child: Text(
                  context.loc.lineItem(index + 1, item.position),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    color: const Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => _showDeleteConfirmation(context),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    Icons.delete_outline,
                    size: 19.sp,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // Row 2: Scaffold Type
          Text(
            scaffoldTitle,
            style: TextStyle(
              fontSize: 17.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),

          SizedBox(height: 4.h),

          // Row 3: Dimensions
          Text(
            item.dimensionsText,
            style: TextStyle(
              fontSize: 14.5.sp,
              color: const Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8.h),

          // Row 4: Remark quote and Calculated Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  item.remark.isNotEmpty ? '"${item.remark}"' : '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${item.calculatedArea.toStringAsFixed(0)} m²',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.loc.deleteMeasurement,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.loc.deleteMeasurementConfirm,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.loc.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              onDelete();
            },
            child: Text(
              context.loc.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
