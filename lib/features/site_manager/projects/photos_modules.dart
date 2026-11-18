import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/services/image_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/widgets/images/app_network_image.dart';
import 'presentation/providers/site_manager_photos_provider.dart';
import 'all_photos_screen.dart';
import 'models.dart';
import 'overview_modules.dart';
import 'pdf_plan_preview_screen.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import 'services/pdf_export_service.dart';

class PhotosTab extends ConsumerStatefulWidget {
  const PhotosTab({
    super.key,
    this.projectName = 'Goltstein Complex',
    this.projectId = 'Prj-0842',
  });

  final String projectName;
  final String projectId;

  @override
  ConsumerState<PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends ConsumerState<PhotosTab> {
  Future<void> _takePhoto() async {
    final allowed = await AppPermissions.requestCamera();
    final loc = AppLocalization.current;

    if (!allowed) {
      if (!mounted) return;
      await showPermissionDialog(
        title: loc.cameraPermissionRequired,
        message: loc.cameraPermissionMessage,
        context: context,
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    ref
        .read(projectPhotosProvider.notifier)
        .addPhoto(
          ProjectPhoto(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            url: image.path,
            title: 'Camera Photo',
            caption: 'Captured on ${DateTime.now().toLocal()}',
          ),
        );
  }

  Future<void> _pickGallery() async {
    final allowed = await AppPermissions.requestPhotos();
    final loc = AppLocalization.current;

    if (!allowed) {
      if (!mounted) return;
      await showPermissionDialog(
        title: loc.photoPermissionRequired,
        message: loc.photoPermissionMessage,
        context: context,
      );
      return;
    }
    final images = await AppImageService.pickMultipleCompressedImages();

    if (images.isEmpty) return;

    final newPhotos = images.map((file) {
      return ProjectPhoto(
        id:
            DateTime.now().millisecondsSinceEpoch.toString() +
            file.path.hashCode.toString(),
        url: file.path,
        title: 'Device Upload',
        caption: 'Uploaded ${DateTime.now().toLocal()}',
      );
    }).toList();

    ref.read(projectPhotosProvider.notifier).addPhotos(newPhotos);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result.isEmpty) return;

    final notifier = ref.read(projectPhotosProvider.notifier);
    var addedCount = 0;

    for (final file in result) {
      final extension = file.extension?.toLowerCase();

      if (extension == 'pdf') {
        notifier.addPlanFile(ProjectPlanFile(name: file.name, path: file.path));
        addedCount++;
      } else if (file.path != null &&
          ['jpg', 'jpeg', 'png'].contains(extension)) {
        notifier.addPhoto(
          ProjectPhoto(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                file.name.hashCode.toString(),
            url: file.path!,
            title: file.name,
          ),
        );
        addedCount++;
      }
    }

    showMessage(AppLocalization.current.filesSelected(addedCount));
  }

  void _openAllPhotos() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllPhotosScreen(
          projectName: widget.projectName,
          projectId: widget.projectId,
        ),
      ),
    );
  }

  void _previewPlan(ProjectPlanFile file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfPlanPreviewScreen(
          planFile: file,
          projectName: widget.projectName,
        ),
      ),
    );
  }

  Future<void> _downloadPlan(ProjectPlanFile file) async {
    try {
      final bytes = await PdfExportService.getPlanBytes(file);
      await PdfExportService.savePdfToDevice(bytes: bytes, filename: file.name);

      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        'Downloaded: ${file.name}',
        actionLabel: 'Open',
        onAction: () => _previewPlan(file),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        'Download failed: $e',
      );
    }
  }

  void _confirmDeletePlan(ProjectPlanFile file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          AppTextButton(
            onPressed: () => Navigator.pop(ctx),
            text: 'Cancel',
          ),
          AppButton.danger(
            fullWidth: false,
            onPressed: () {
              ref
                  .read(projectPhotosProvider.notifier)
                  .removePlanFile(file.name);
              Navigator.pop(ctx);
              AppSnackBar.showInfo(
                context,
                'Removed ${file.name}',
              );
            },
            text: 'Delete',
          ),
        ],
      ),
    );
  }

  Widget buildPhotosTab() {
    final loc = AppLocalization.current;
    final photosState = ref.watch(projectPhotosProvider);
    final photos = photosState.photos;
    final planFiles = photosState.planFiles;
    final coverPhoto = photosState.coverPhoto;
    final otherPhotos = photosState.otherPhotos;

    final showPhotosSection =
        photosState.activeFilter == 'all' ||
        photosState.activeFilter == 'photos';
    final showPlansSection =
        photosState.activeFilter == 'all' ||
        photosState.activeFilter == 'plans';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 25.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildPhotoToolbar(photos.length, planFiles.length),
              SizedBox(height: 12.h),

              // Photos Section
              if (showPhotosSection) ...[
                _buildPhotoSectionTitle(
                  title: loc.photos,
                  count: photos.length,
                  onSeeAll: _openAllPhotos,
                ),
                SizedBox(height: 8.h),
                if (coverPhoto != null) _buildCoverPhoto(coverPhoto),
                SizedBox(height: 8.h),
                if (otherPhotos.isNotEmpty) _buildPhotoGrid(otherPhotos),
                SizedBox(height: 8.h),
                _buildSeeAllPhotosCard(photos.length),
                SizedBox(height: 18.h),
              ],

              // PDF Plans Section
              if (showPlansSection) ...[
                _buildPdfPlansSectionTitle(
                  title: loc.pdfPlans,
                  count: planFiles.length,
                ),
                SizedBox(height: 8.h),
                if (planFiles.isEmpty)
                  _buildNoPlansCard()
                else
                  ...planFiles.map(
                    (file) => Padding(
                      padding: EdgeInsets.only(bottom: 7.h),
                      child: _buildPlanFile(file),
                    ),
                  ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoToolbar(int photoCount, int planCount) {
    final loc = AppLocalization.current;
    final photosState = ref.watch(projectPhotosProvider);
    final notifier = ref.read(projectPhotosProvider.notifier);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _photoFilterButton(
            label: '${loc.photos} ($photoCount)',
            selected:
                photosState.activeFilter == 'all' ||
                photosState.activeFilter == 'photos',
            onTap: () {
              if (photosState.activeFilter == 'photos') {
                notifier.setActiveFilter('all');
              } else {
                notifier.setActiveFilter('photos');
              }
            },
          ),
          SizedBox(width: 7.w),
          _photoFilterButton(
            label: loc.pdfPlan(planCount),
            selected: photosState.activeFilter == 'plans',
            onTap: () {
              if (photosState.activeFilter == 'plans') {
                notifier.setActiveFilter('all');
              } else {
                notifier.setActiveFilter('plans');
              }
            },
          ),
          SizedBox(width: 14.w),
          AppButton.small(
            variant: AppButtonVariant.danger,
            onPressed: _showUploadFilesBottomSheet,
            leadingIcon: Icons.upload_outlined,
            text: loc.uploadFiles,
            borderRadius: 6.r,
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
            textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _photoFilterButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF222222) : Colors.white,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: selected ? const Color(0xFF222222) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            color: selected ? Colors.white : const Color(0xFF666666),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSectionTitle({
    required String title,
    required int count,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(width: 5.w),
        Text(
          '($count)',
          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF777777)),
        ),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F2),
                borderRadius: BorderRadius.circular(5.r),
                border: Border.all(
                  color: const Color(0xFFC8102E).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All Photos',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC8102E),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11.sp,
                    color: const Color(0xFFC8102E),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPdfPlansSectionTitle({
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(width: 5.w),
        Text(
          '($count)',
          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF777777)),
        ),
      ],
    );
  }

  Widget _buildSeeAllPhotosCard(int count) {
    return GestureDetector(
      onTap: _openAllPhotos,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.collections_outlined,
                color: const Color(0xFFC8102E),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View all $count photos',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Browse gallery & download all together in 1 PDF',
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFC8102E),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf_outlined,
                    color: Colors.white,
                    size: 15.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPhoto(ProjectPhoto photo) {
    final loc = AppLocalization.current;
    return GestureDetector(
      onTap: () => _openPhoto(photo),
      child: Container(
        height: 145.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: AppNetworkImage(
                imageUrl: photo.url,
                fit: BoxFit.cover,
                fallback: _imagePlaceholder(),
              ),
            ),
            Positioned(
              left: 5.w,
              bottom: 5.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                color: Colors.white,
                child: Text(
                  loc.cover,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(right: 6.w, bottom: 6.h, child: _onlineIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(List<ProjectPhoto> photos) {
    // Show maximum 6 photos in the preview grid; additional photos accessed via See All
    final displayPhotos = photos.take(6).toList();
    final remainingCount = photos.length - displayPhotos.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5.w,
        mainAxisSpacing: 5.h,
        childAspectRatio: 1,
      ),
      itemCount: displayPhotos.length,
      itemBuilder: (context, index) {
        final photo = displayPhotos[index];
        final isLast = index == 5 && remainingCount > 0;

        return GestureDetector(
          onTap: () {
            if (isLast) {
              _openAllPhotos();
            } else {
              _openPhoto(photo);
            }
          },
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppNetworkImage(
                    imageUrl: photo.url,
                    fit: BoxFit.cover,
                    fallback: _imagePlaceholder(),
                  ),
                ),
                if (isLast)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.65),
                      child: Center(
                        child: Text(
                          '+$remainingCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    right: 5.w,
                    bottom: 5.h,
                    child: _onlineIndicator(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanFile(ProjectPlanFile file) {
    return GestureDetector(
      onTap: () => _previewPlan(file),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE7E7E7)),
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
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F2),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.picture_as_pdf_outlined,
                color: const Color(0xFFC8102E),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${file.size} • Tap to preview',
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),

            // Preview Button
            IconButton(
              tooltip: 'Preview PDF',
              icon: Icon(
                Icons.visibility_outlined,
                size: 19.sp,
                color: const Color(0xFF475569),
              ),
              onPressed: () => _previewPlan(file),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.all(6.w),
            ),
            SizedBox(width: 4.w),

            // Download Button
            IconButton(
              tooltip: 'Download PDF',
              icon: Icon(
                Icons.download_outlined,
                size: 19.sp,
                color: const Color(0xFFC8102E),
              ),
              onPressed: () => _downloadPlan(file),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.all(6.w),
            ),
            SizedBox(width: 4.w),

            // Delete Button
            IconButton(
              tooltip: 'Delete Plan',
              icon: Icon(
                Icons.delete_outline,
                size: 19.sp,
                color: const Color(0xFFEF4444),
              ),
              onPressed: () => _confirmDeletePlan(file),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.all(6.w),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPlansCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 32.sp,
              color: const Color(0xFF999999),
            ),
            SizedBox(height: 6.h),
            Text(
              'No PDF plans uploaded yet',
              style: TextStyle(
                fontSize: 15.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onlineIndicator() {
    return Container(
      width: 7.w,
      height: 7.w,
      decoration: BoxDecoration(
        color: const Color(0xFF12B76A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE5E5E5),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 28.sp,
          color: const Color(0xFF999999),
        ),
      ),
    );
  }

  void _showUploadFilesBottomSheet() {
    final loc = AppLocalization.current;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D5D5),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  loc.uploadFiles,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: _uploadOption(
                        icon: Icons.camera_alt_outlined,
                        title: loc.takePhoto,
                        onTap: () {
                          Navigator.pop(context);
                          _takePhoto();
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _uploadOption(
                        icon: Icons.folder_outlined,
                        title: context.loc.deviceStorage,
                        onTap: () {
                          Navigator.pop(context);
                          _pickGallery();
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _uploadOption(
                        icon: Icons.attach_file,
                        title: loc.files,
                        onTap: () {
                          Navigator.pop(context);
                          _pickFiles();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _uploadOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFD8D8D8)),
            ),
            child: Icon(icon, size: 23.sp, color: const Color(0xFF444444)),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyle(fontSize: 15.5.sp, color: const Color(0xFF555555)),
          ),
        ],
      ),
    );
  }

  void _openPhoto(ProjectPhoto photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          photo: photo,
          onSetCover: () {
            ref.read(projectPhotosProvider.notifier).setCoverPhoto(photo.id);
          },
          onDelete: () {
            ref.read(projectPhotosProvider.notifier).removePhoto(photo.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildPhotosTab();
  }
}

class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({
    super.key,
    required this.photo,
    required this.onSetCover,
    required this.onDelete,
  });

  final ProjectPhoto photo;
  final VoidCallback onSetCover;
  final VoidCallback onDelete;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  Future<void> _downloadSinglePhoto() async {
    final loc = AppLocalization.current;
    try {
      if (widget.photo.url.startsWith('http')) {
        final dio = Dio();
        final response = await dio.get<List<int>>(
          widget.photo.url,
          options: Options(responseType: ResponseType.bytes),
        );
        if (response.data != null) {
          final filename =
              'Photo_${widget.photo.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await PdfExportService.savePdfToDevice(
            bytes: response.data as dynamic,
            filename: filename,
          );
        }
      }

      if (!mounted) return;
      AppSnackBar.showInfo(context, loc.downloadStarted);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showInfo(context, loc.downloadStarted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      body: SafeArea(
        child: Column(
          children: [
            _buildViewerHeader(),
            Expanded(
              child: InteractiveViewer(
                minScale: .8,
                maxScale: 4,
                child: Center(child: _buildImage()),
              ),
            ),
            _buildViewerActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewerHeader() {
    final loc = AppLocalization.current;
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 35.w,
              height: 35.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 17.sp,
                color: Colors.black,
              ),
            ),
          ),
          const Spacer(),
          Text(
            loc.photoViewer,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          SizedBox(width: 35.w),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return AppNetworkImage(
      imageUrl: widget.photo.url,
      fit: BoxFit.contain,
      fallback: _viewerPlaceholder(),
    );
  }

  Widget _viewerPlaceholder() {
    return Container(
      width: 300.w,
      height: 500.h,
      color: const Color(0xFF444444),
      child: Icon(Icons.image_outlined, color: Colors.white54, size: 60.sp),
    );
  }

  Widget _buildViewerActions() {
    final loc = AppLocalization.current;
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: _viewerButton(
              label: loc.setAsCoverPhoto,
              color: const Color(0xFFC8102E),
              icon: Icons.photo_camera_outlined,
              onTap: () {
                widget.onSetCover();
                AppSnackBar.showSuccess(
                  context,
                  loc.coverPhotoUpdated,
                );
              },
            ),
          ),
          SizedBox(width: 5.w),
          _viewerSmallButton(
            icon: Icons.download_outlined,
            label: loc.download,
            onTap: _downloadSinglePhoto,
          ),
          SizedBox(width: 5.w),
          _viewerSmallButton(
            icon: Icons.delete_outline,
            label: loc.delete,
            onTap: _deletePhoto,
          ),
        ],
      ),
    );
  }

  Widget _viewerButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppButton.small(
      onPressed: onTap,
      leadingIcon: icon,
      text: label,
      backgroundColor: color,
      foregroundColor: Colors.white,
      borderRadius: 4.r,
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 7.h),
      textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    );
  }

  Widget _viewerSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AppOutlinedButton.small(
      onPressed: onTap,
      leadingIcon: icon,
      text: label,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderColor: Colors.transparent,
      borderRadius: 4.r,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      textStyle: TextStyle(fontSize: 12.5.sp),
    );
  }

  void _deletePhoto() {
    widget.onDelete();
    Navigator.pop(context);
  }
}
