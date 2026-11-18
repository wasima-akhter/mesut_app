import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/widgets/images/app_network_image.dart';

class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    required this.currentAvatarUrl,
    required this.selectedLocalImage,
    required this.onImagePicked,
  });

  final String? currentAvatarUrl;
  final File? selectedLocalImage;
  final ValueChanged<File> onImagePicked;

  Future<void> _showPickerOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
                title: Text(context.loc.takePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await AppImageService.pickCompressedImage(
                    source: ImageSource.camera,
                  );
                  if (file != null) onImagePicked(file);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.folder_outlined,
                  color: AppColors.primary,
                ),
                title: Text(context.loc.deviceStorage),
                subtitle: Text(context.loc.chooseFromDevice),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file =
                      await AppImageService.pickImageFromDeviceStorage();
                  if (file != null) onImagePicked(file);
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
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _showPickerOptions(context),
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neutral200,
                border: Border.all(color: AppColors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildImage(),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: GestureDetector(
              onTap: () => _showPickerOptions(context),
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 17.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (selectedLocalImage != null) {
      return Image.file(
        selectedLocalImage!,
        fit: BoxFit.cover,
        width: 90.w,
        height: 90.w,
      );
    }

    if (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: currentAvatarUrl!,
        fit: BoxFit.cover,
        width: 90.w,
        height: 90.w,
        fallback: _fallbackIcon(),
      );
    }

    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return Icon(
      Icons.person,
      size: 48.sp,
      color: AppColors.textSecondary.withValues(alpha: 0.6),
    );
  }
}
