import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';

class ProjectUploadAttachmentsSheet extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseGallery;
  final VoidCallback onUploadPdf;

  const ProjectUploadAttachmentsSheet({
    super.key,
    required this.onTakePhoto,
    required this.onChooseGallery,
    required this.onUploadPdf,
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onTakePhoto,
    required VoidCallback onChooseGallery,
    required VoidCallback onUploadPdf,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => ProjectUploadAttachmentsSheet(
        onTakePhoto: () {
          Navigator.pop(ctx);
          onTakePhoto();
        },
        onChooseGallery: () {
          Navigator.pop(ctx);
          onChooseGallery();
        },
        onUploadPdf: () {
          Navigator.pop(ctx);
          onUploadPdf();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFFC8102E),
              ),
              title: Text(context.loc.takePhoto),
              onTap: onTakePhoto,
            ),
            ListTile(
              leading: const Icon(
                Icons.folder_outlined,
                color: Color(0xFFC8102E),
              ),
              title: Text(context.loc.deviceStorage),
              subtitle: Text(context.loc.chooseFromDevice),
              onTap: onChooseGallery,
            ),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: Color(0xFFC8102E),
              ),
              title: Text(context.loc.pdfPlans),
              onTap: onUploadPdf,
            ),
          ],
        ),
      ),
    );
  }
}
