import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../projects/models.dart';
import '../../../projects/pdf_plan_preview_screen.dart';
import '../../domain/entities/project_attachment_entity.dart';

class ProjectPlanCard extends StatelessWidget {
  final ProjectAttachmentEntity attachment;
  final String projectName;
  final VoidCallback? onDelete;

  const ProjectPlanCard({
    super.key,
    required this.attachment,
    this.projectName = '',
    this.onDelete,
  });

  void _openPreview(BuildContext context) {
    final planFile = ProjectPlanFile(
      name: attachment.fileName,
      path: attachment.url,
      size: attachment.formattedSize,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfPlanPreviewScreen(
          planFile: planFile,
          projectName: projectName,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(context.loc.deletePlan),
        content: Text(context.loc.deletePlanConfirmation),
        actions: [
          AppTextButton(
            onPressed: () => Navigator.pop(ctx),
            text: context.loc.cancel,
          ),
          AppButton.danger(
            fullWidth: false,
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
            text: context.loc.delete,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F2),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                color: const Color(0xFFC8102E),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    attachment.formattedSize.isNotEmpty
                        ? attachment.formattedSize
                        : 'PDF',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                color: const Color(0xFF555555),
                size: 20.sp,
              ),
              onPressed: () => _openPreview(context),
            ),
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade400,
                  size: 20.sp,
                ),
                onPressed: () => _confirmDelete(context),
              ),
          ],
        ),
      ),
    );
  }
}
