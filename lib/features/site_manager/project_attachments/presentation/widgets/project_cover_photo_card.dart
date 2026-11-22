import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/images/app_network_image.dart';
import '../../domain/entities/project_attachment_entity.dart';

class ProjectCoverPhotoCard extends StatelessWidget {
  final ProjectAttachmentEntity photo;
  final VoidCallback onTap;
  final VoidCallback? onSetCover;
  final VoidCallback? onDelete;

  const ProjectCoverPhotoCard({
    super.key,
    required this.photo,
    required this.onTap,
    this.onSetCover,
    this.onDelete,
  });

  Widget _buildImage() {
    return AppNetworkImage(
      imageUrl: photo.url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      fallback: _errorPlaceholder(),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      color: const Color(0xFFEEEEEE),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: const Color(0xFF999999),
          size: 36.sp,
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!photo.isCover && onSetCover != null)
                ListTile(
                  leading: const Icon(
                    Icons.star_outline_rounded,
                    color: Color(0xFFC8102E),
                  ),
                  title: Text(context.loc.setAsCoverPhoto),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSetCover?.call();
                  },
                ),
              if (onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    context.loc.deletePhoto,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onDelete?.call();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 185.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: _buildImage()),
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8102E),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 15.sp, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      context.loc.coverPhoto,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Material(
                color: Colors.black.withValues(alpha: 0.4),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _showOptionsMenu(context),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
