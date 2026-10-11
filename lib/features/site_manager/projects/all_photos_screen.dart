import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/services/permission_service.dart';
import '../presentation/providers/site_manager_photos_provider.dart';
import 'models.dart';
import 'overview_modules.dart';
import 'pdf_plan_preview_screen.dart';
import 'photos_modules.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import 'services/pdf_export_service.dart';

class AllPhotosScreen extends ConsumerStatefulWidget {
  const AllPhotosScreen({
    super.key,

    this.projectName = 'Goltstein Complex',

    this.projectId = 'Prj-0842',
  });

  final String projectName;

  final String projectId;

  @override
  ConsumerState<AllPhotosScreen> createState() => _AllPhotosScreenState();
}

class _AllPhotosScreenState extends ConsumerState<AllPhotosScreen> {
  bool _isSelectionMode = false;

  String _selectedFilter = 'All'; // 'All', 'Cover', 'Recent'

  int _gridColumns = 2; // 2 or 3

  Future<void> _exportPhotosToPdf({bool selectedOnly = false}) async {
    final notifier = ref.read(projectPhotosProvider.notifier);

    final state = ref.read(projectPhotosProvider);

    final photosToExport = (selectedOnly && state.selectedPhotoIds.isNotEmpty)
        ? state.selectedPhotos
        : state.photos;

    if (photosToExport.isEmpty) {
      AppSnackBar.showWarning(context, 'No photos available to export');

      return;
    }

    notifier.setGeneratingPdf(true);

    // Show progress dialog

    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (ctx) => PopScope(
        canPop: false,

        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),

          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8102E)),
                ),

                SizedBox(height: 18.h),

                Text(
                  'Compiling Photos into PDF...',

                  style: TextStyle(
                    fontSize: 18.sp,

                    fontWeight: FontWeight.w700,

                    color: const Color(0xFF222222),
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  'Processing ${photosToExport.length} images with project header',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 15.sp,

                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final pdfBytes = await PdfExportService.generatePhotosPdf(
        photos: photosToExport,

        projectName: widget.projectName,

        projectId: widget.projectId,
      );

      final filename =
          '${widget.projectName.replaceAll(' ', '_')}_Photos_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savedPath = await PdfExportService.savePdfToDevice(
        bytes: pdfBytes,

        filename: filename,
      );

      notifier.setGeneratingPdf(false);

      if (!mounted) return;

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(); // dismiss loading dialog

      // Show download success sheet with Preview & Share options

      _showPdfDownloadSuccessDialog(
        filename: filename,

        savedPath: savedPath,

        pdfBytes: pdfBytes,

        photoCount: photosToExport.length,
      );
    } catch (e) {
      notifier.setGeneratingPdf(false);

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog

      AppSnackBar.showError(
        context,
        'Failed to generate PDF: ${e.toString()}',
      );
    }
  }

  void _showPdfDownloadSuccessDialog({
    required String filename,

    required String savedPath,

    required dynamic pdfBytes,

    required int photoCount,
  }) {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),

          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 40.w,

                  height: 4.h,

                  margin: EdgeInsets.only(bottom: 16.h),

                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),

                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),

                Container(
                  width: 56.w,

                  height: 56.w,

                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),

                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    Icons.check_circle_rounded,

                    color: const Color(0xFF12B76A),

                    size: 38.sp,
                  ),
                ),

                SizedBox(height: 12.h),

                Text(
                  'PDF Downloaded Successfully!',

                  style: TextStyle(
                    fontSize: 20.sp,

                    fontWeight: FontWeight.w700,

                    color: const Color(0xFF111111),
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  '$photoCount photos bundled into single document:\n$filename',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 15.sp,

                    color: const Color(0xFF666666),
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: AppOutlinedButton(
                        leadingIcon: Icons.share_outlined,
                        text: 'Share',
                        foregroundColor: const Color(0xFF333333),
                        borderColor: const Color(0xFFD0D5DD),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        borderRadius: 8.r,
                        onPressed: () {
                          Navigator.pop(ctx);
                          PdfExportService.sharePdf(
                            bytes: pdfBytes,
                            filename: filename,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppButton.danger(
                        leadingIcon: Icons.visibility_outlined,
                        text: 'Preview PDF',
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        borderRadius: 8.r,
                        onPressed: () {
                          Navigator.pop(ctx);

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => PdfPlanPreviewScreen(
                                planFile: ProjectPlanFile(
                                  name: filename,

                                  fileBytes: pdfBytes,

                                  size:
                                      '${(pdfBytes.length / (1024 * 1024)).toStringAsFixed(1)} MB',
                                ),

                                projectName: widget.projectName,
                              ),
                            ),
                          );
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

    final picker = ImagePicker();

    final images = await picker.pickMultiImage(imageQuality: 90);

    if (images.isEmpty) return;

    final newPhotos = images.map((image) {
      return ProjectPhoto(
        id:
            DateTime.now().millisecondsSinceEpoch.toString() +
            image.path.hashCode.toString(),

        url: image.path,

        title: 'Gallery Upload',

        caption: 'Uploaded ${DateTime.now().toLocal()}',
      );
    }).toList();

    ref.read(projectPhotosProvider.notifier).addPhotos(newPhotos);
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
    final photosState = ref.watch(projectPhotosProvider);

    final notifier = ref.read(projectPhotosProvider.notifier);

    var displayPhotos = photosState.photos;

    if (_selectedFilter == 'Cover') {
      displayPhotos = photosState.photos.where((p) => p.isCover).toList();
    }

    final isAllSelected =
        photosState.selectedPhotoIds.isNotEmpty &&
        photosState.selectedPhotoIds.length == photosState.photos.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0.5,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,

            size: 20.sp,

            color: const Color(0xFF222222),
          ),

          onPressed: () => Navigator.of(context).pop(),
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'All Photos (${photosState.photos.length})',

              style: TextStyle(
                fontSize: 19.sp,

                fontWeight: FontWeight.w700,

                color: const Color(0xFF111111),
              ),
            ),

            SizedBox(height: 2.h),

            Text(
              '${widget.projectName} • ${widget.projectId}',

              style: TextStyle(
                fontSize: 14.sp,

                color: const Color(0xFF777777),

                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: _gridColumns == 2 ? '3 Column View' : '2 Column View',

            icon: Icon(
              _gridColumns == 2
                  ? Icons.view_comfy_alt_outlined
                  : Icons.grid_view_rounded,

              color: const Color(0xFF444444),

              size: 23.sp,
            ),

            onPressed: () {
              setState(() {
                _gridColumns = _gridColumns == 2 ? 3 : 2;
              });
            },
          ),

          IconButton(
            tooltip: _isSelectionMode ? 'Cancel Selection' : 'Select Photos',

            icon: Icon(
              _isSelectionMode
                  ? Icons.check_circle_rounded
                  : Icons.checklist_rounded,

              color: _isSelectionMode
                  ? const Color(0xFFC8102E)
                  : const Color(0xFF444444),

              size: 24.sp,
            ),

            onPressed: () {
              setState(() {
                _isSelectionMode = !_isSelectionMode;

                if (!_isSelectionMode) {
                  notifier.clearSelection();
                }
              });
            },
          ),

          SizedBox(width: 4.w),
        ],
      ),

      body: Column(
        children: [
          _buildTopBanner(photosState),

          _buildFilterToolbar(photosState, isAllSelected),

          Expanded(
            child: displayPhotos.isEmpty
                ? _buildEmptyState()
                : _buildPhotosGrid(displayPhotos, photosState),
          ),

          _buildBottomActionCard(photosState),
        ],
      ),
    );
  }

  Widget _buildTopBanner(ProjectPhotosState state) {
    return Container(
      width: double.infinity,

      color: const Color(0xFFFFF5F5),

      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),

      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.w),

            decoration: BoxDecoration(
              color: const Color(0xFFC8102E).withValues(alpha: 0.12),

              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.picture_as_pdf_rounded,

              color: const Color(0xFFC8102E),

              size: 22.sp,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Bundle Photos into One PDF',

                  style: TextStyle(
                    fontSize: 15.5.sp,

                    fontWeight: FontWeight.w700,

                    color: const Color(0xFF222222),
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  'Compile all ${state.photos.length} photos into a branded report',

                  style: TextStyle(
                    fontSize: 13.5.sp,

                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          AppButton.small(
            variant: AppButtonVariant.danger,
            onPressed: () => _exportPhotosToPdf(selectedOnly: false),
            leadingIcon: Icons.download_rounded,
            text: 'PDF',
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            borderRadius: 6.r,
            textStyle: TextStyle(fontSize: 15.5.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar(ProjectPhotosState state, bool isAllSelected) {
    final notifier = ref.read(projectPhotosProvider.notifier);

    return Container(
      color: Colors.white,

      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),

      child: Row(
        children: [
          _filterChip('All', 'All (${state.photos.length})'),

          SizedBox(width: 8.w),

          _filterChip(
            'Cover',

            'Cover (${state.photos.where((p) => p.isCover).length})',
          ),

          const Spacer(),

          if (_isSelectionMode) ...[
            AppTextButton(
              onPressed: () {
                if (isAllSelected) {
                  notifier.clearSelection();
                } else {
                  notifier.selectAllPhotos();
                }
              },
              leadingIcon: isAllSelected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              text: isAllSelected ? 'Deselect All' : 'Select All',
              foregroundColor: const Color(0xFFC8102E),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              textStyle: TextStyle(
                fontSize: 15.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFC8102E),
              ),
            ),
          ] else ...[
            Text(
              '${state.photos.length} total',

              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF888888)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),

        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222222) : const Color(0xFFF3F4F6),

          borderRadius: BorderRadius.circular(6.r),

          border: Border.all(
            color: isSelected
                ? const Color(0xFF222222)
                : const Color(0xFFE5E7EB),
          ),
        ),

        child: Text(
          label,

          style: TextStyle(
            fontSize: 15.5.sp,

            fontWeight: FontWeight.w600,

            color: isSelected ? Colors.white : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosGrid(List<ProjectPhoto> photos, ProjectPhotosState state) {
    final notifier = ref.read(projectPhotosProvider.notifier);

    return GridView.builder(
      padding: EdgeInsets.all(12.w),

      physics: const BouncingScrollPhysics(),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumns,

        crossAxisSpacing: 10.w,

        mainAxisSpacing: 10.h,

        childAspectRatio: _gridColumns == 2 ? 0.95 : 0.85,
      ),

      itemCount: photos.length,

      itemBuilder: (context, index) {
        final photo = photos[index];

        final isSelected = state.isSelected(photo.id);

        return GestureDetector(
          onTap: () {
            if (_isSelectionMode) {
              notifier.togglePhotoSelection(photo.id);
            } else {
              _openPhoto(photo);
            }
          },

          onLongPress: () {
            setState(() {
              _isSelectionMode = true;
            });

            notifier.togglePhotoSelection(photo.id);
          },

          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(10.r),

              border: Border.all(
                color: isSelected
                    ? const Color(0xFFC8102E)
                    : const Color(0xFFE5E7EB),

                width: isSelected ? 2 : 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),

                  blurRadius: 4,

                  offset: const Offset(0, 2),
                ),
              ],
            ),

            clipBehavior: Clip.antiAlias,

            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,

                          color: const Color(0xFFEAEAEA),

                          child: _buildImageThumbnail(photo.url),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,

                          vertical: 6.h,
                        ),

                        color: Colors.white,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              photo.title ?? 'Photo #${index + 1}',

                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,

                              style: TextStyle(
                                fontSize: 16.sp,

                                fontWeight: FontWeight.w600,

                                color: const Color(0xFF222222),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            Text(
                              '${photo.createdAt.day}.${photo.createdAt.month}.${photo.createdAt.year}',

                              style: TextStyle(
                                fontSize: 15.sp,

                                color: const Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Cover Badge
                if (photo.isCover)
                  Positioned(
                    top: 6.h,

                    left: 6.w,

                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,

                        vertical: 3.h,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFC8102E),

                        borderRadius: BorderRadius.circular(4.r),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),

                            blurRadius: 2,
                          ),
                        ],
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.star_rounded,

                            color: Colors.white,

                            size: 13.sp,
                          ),

                          SizedBox(width: 3.w),

                          Text(
                            'COVER',

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: 14.sp,

                              fontWeight: FontWeight.w700,

                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Selection Checkbox
                if (_isSelectionMode)
                  Positioned(
                    top: 6.h,

                    right: 6.w,

                    child: Container(
                      width: 24.w,

                      height: 24.w,

                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFC8102E)
                            : Colors.white.withValues(alpha: 0.85),

                        shape: BoxShape.circle,

                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFC8102E)
                              : const Color(0xFFCCCCCC),

                          width: 1.5,
                        ),
                      ),

                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 19.sp)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageThumbnail(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,

        fit: BoxFit.cover,

        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    return Image.file(
      File(url),

      fit: BoxFit.cover,

      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE5E5E5),

      child: Center(
        child: Icon(
          Icons.image_outlined,

          color: const Color(0xFF999999),

          size: 28.sp,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            Icons.photo_library_outlined,

            size: 50.sp,

            color: const Color(0xFFBDBDBD),
          ),

          SizedBox(height: 12.h),

          Text(
            'No photos in this category',

            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 4.h),

          Text(
            'Upload photos from camera or gallery',

            style: TextStyle(fontSize: 15.sp, color: const Color(0xFF777777)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionCard(ProjectPhotosState state) {
    final selectedCount = state.selectedPhotoIds.length;

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 16.h),

      decoration: BoxDecoration(
        color: Colors.white,

        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),

            blurRadius: 6,

            offset: const Offset(0, -2),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: AppOutlinedButton(
                onPressed: _showUploadBottomSheet,
                leadingIcon: Icons.add_a_photo_outlined,
                text: 'Add Photo',
                foregroundColor: const Color(0xFF333333),
                borderColor: const Color(0xFFD0D5DD),
                padding: EdgeInsets.symmetric(vertical: 11.h),
                borderRadius: 8.r,
                textStyle: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 2,
              child: AppButton.danger(
                onPressed: () {
                  _exportPhotosToPdf(
                    selectedOnly: _isSelectionMode && selectedCount > 0,
                  );
                },
                leadingIcon: Icons.picture_as_pdf_outlined,
                text: _isSelectionMode && selectedCount > 0
                    ? 'Download $selectedCount as PDF'
                    : 'Download All in 1 PDF',
                padding: EdgeInsets.symmetric(vertical: 11.h),
                borderRadius: 8.r,
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadBottomSheet() {
    final loc = AppLocalization.current;

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),

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

                  margin: EdgeInsets.symmetric(vertical: 8.h),

                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D5D5),

                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Upload Photos',

                  style: TextStyle(
                    fontSize: 20.sp,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: _uploadTile(
                        icon: Icons.camera_alt_outlined,

                        title: loc.takePhoto,

                        onTap: () {
                          Navigator.pop(context);

                          _takePhoto();
                        },
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: _uploadTile(
                        icon: Icons.photo_library_outlined,

                        title: loc.gallery,

                        onTap: () {
                          Navigator.pop(context);

                          _pickGallery();
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

  Widget _uploadTile({
    required IconData icon,

    required String title,

    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),

        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),

          borderRadius: BorderRadius.circular(8.r),

          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),

        child: Column(
          children: [
            Icon(icon, size: 28.sp, color: const Color(0xFFC8102E)),

            SizedBox(height: 6.h),

            Text(
              title,

              style: TextStyle(
                fontSize: 15.sp,

                fontWeight: FontWeight.w600,

                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
