import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/images/app_network_image.dart';
import '../../domain/entities/project_attachment_entity.dart';

class ProjectAttachmentViewerDialog extends StatelessWidget {
  final ProjectAttachmentEntity attachment;
  final VoidCallback? onSetCover;
  final VoidCallback? onDelete;

  const ProjectAttachmentViewerDialog({
    super.key,
    required this.attachment,
    this.onSetCover,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required ProjectAttachmentEntity attachment,
    VoidCallback? onSetCover,
    VoidCallback? onDelete,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => ProjectAttachmentViewerDialog(
        attachment: attachment,
        onSetCover: onSetCover,
        onDelete: onDelete,
      ),
    );
  }

  Widget _buildImage() {
    return AppNetworkImage(
      imageUrl: attachment.url,
      fit: BoxFit.contain,
      fallback: const Center(
        child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      attachment.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (attachment.isCover)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8102E),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        context.loc.cover,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Center(child: _buildImage()),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!attachment.isCover && onSetCover != null)
                    TextButton.icon(
                      icon: const Icon(Icons.star_outline_rounded,
                          color: Colors.white),
                      label: Text(
                        context.loc.setAsCoverPhoto,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onSetCover?.call();
                      },
                    ),
                  if (onDelete != null)
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      label: Text(
                        context.loc.deletePhoto,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete?.call();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
