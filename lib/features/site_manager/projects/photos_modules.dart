import 'dart:io';

import 'package:construction_app/core/widgets/snack/app_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/permission_service.dart';
import 'models.dart';
import 'overview_modules.dart';

class PhotosTab extends StatefulWidget {
  const PhotosTab({super.key});

  @override
  _PhotosTabState createState() => _PhotosTabState();
}

class _PhotosTabState extends State<PhotosTab> {
  final List<ProjectPlanFile> _planFiles = [
    ProjectPlanFile(name: 'Goltstein_Scaffold_Approval_Plan.pdf'),
    ProjectPlanFile(name: 'Goltstein_Scaffold_Approval_Plan_02.pdf'),
  ];
  final List<ProjectPhoto> _photos = [
    ProjectPhoto(
      id: '1',
      url: 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5',
      isCover: true,
    ),
    ProjectPhoto(
      id: '2',
      url: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
    ),
    ProjectPhoto(
      id: '3',
      url: 'https://images.unsplash.com/photo-1590725175248-ecb2a7f7a4c6',
    ),
    ProjectPhoto(
      id: '4',
      url: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e',
    ),
    ProjectPhoto(
      id: '5',
      url: 'https://images.unsplash.com/photo-1541971875076-8f970d573be6',
    ),
    ProjectPhoto(
      id: '6',
      url: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742',
    ),
  ];
  @override
  final context = appNavigatorKey.currentContext!;
  Future<void> _takePhoto() async {
    context.pop();

    final allowed = await AppPermissions.requestCamera();

    if (!allowed) {
      await showPermissionDialog(
        title: 'Camera Permission Required',
        message: 'Please allow camera access to take a photo.',
        context: context,
      );
      return;
    }

    final picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() {
      _photos.add(
        ProjectPhoto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: image.path,
        ),
      );
    });
  }

  Future<void> _pickGallery() async {
    context.pop();
    final allowed = await AppPermissions.requestPhotos();

    if (!allowed) {
      await showPermissionDialog(
        title: 'Photo Permission Required',
        message: 'Photo library access is required to upload project photos.',
        context: context,
      );
      return;
    }
    final picker = ImagePicker();

    final images = await picker.pickMultiImage(imageQuality: 90);

    if (images.isEmpty) return;

    setState(() {
      for (final image in images) {
        _photos.add(
          ProjectPhoto(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            url: image.path,
          ),
        );
      }
    });
  }

  Future<void> _pickFiles() async {
    Navigator.pop(context);

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    for (final file in result) {
      final extension = file.extension?.toLowerCase();

      if (extension == 'pdf') {
        setState(() {
          _planFiles.add(ProjectPlanFile(name: file.name));
        });
      }
    }

    showMessage('${result.length} file(s) selected');
  }

  Widget buildPhotosTab() {
    final coverPhoto = _photos.where((photo) => photo.isCover).firstOrNull;

    final otherPhotos = _photos.where((photo) => !photo.isCover).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 25.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildPhotoToolbar(),
              SizedBox(height: 10.h),

              _buildPhotoSectionTitle('Photos', _photos.length),

              SizedBox(height: 8.h),

              if (coverPhoto != null) _buildCoverPhoto(coverPhoto),

              SizedBox(height: 8.h),

              if (otherPhotos.isNotEmpty) _buildPhotoGrid(otherPhotos),

              SizedBox(height: 18.h),

              _buildPhotoSectionTitle('PDF Plans', _planFiles.length),

              SizedBox(height: 8.h),

              ..._planFiles.map(
                (file) => Padding(
                  padding: EdgeInsets.only(bottom: 7.h),
                  child: _buildPlanFile(file),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoToolbar() {
    return Row(
      children: [
        _photoFilterButton(
          label: 'Photos (${_photos.length})',
          selected: true,
          onTap: () {},
        ),

        SizedBox(width: 7.w),

        _photoFilterButton(
          label: 'PDF Plan (${_planFiles.length})',
          selected: false,
          onTap: () {},
        ),

        const Spacer(),

        SizedBox(
          height: 36.h,
          child: ElevatedButton.icon(
            onPressed: _showUploadFilesBottomSheet,
            icon: Icon(Icons.upload_outlined, size: 16.sp),
            label: Text(
              'Upload Files',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8102E),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 9.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ),
      ],
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
            fontSize: 16.sp,
            color: selected ? Colors.white : const Color(0xFF666666),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPhoto(ProjectPhoto photo) {
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
              child: Image.network(
                photo.url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return _imagePlaceholder();
                },
              ),
            ),

            Positioned(
              left: 5.w,
              bottom: 5.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                color: Colors.white,
                child: Text(
                  'Cover',
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5.w,
        mainAxisSpacing: 5.h,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];

        return GestureDetector(
          onTap: () => _openPhoto(photo),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    photo.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return _imagePlaceholder();
                    },
                  ),
                ),

                Positioned(right: 5.w, bottom: 5.h, child: _onlineIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanFile(ProjectPlanFile file) {
    return GestureDetector(
      onTap: () {
        showMessage('Opening ${file.name}');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Icon(
                Icons.picture_as_pdf_outlined,
                color: const Color(0xFFC8102E),
                size: 18.sp,
              ),
            ),

            SizedBox(width: 8.w),

            Expanded(
              child: Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ),

            Icon(
              Icons.visibility_outlined,
              size: 17.sp,
              color: const Color(0xFF777777),
            ),

            SizedBox(width: 8.w),

            Icon(
              Icons.download_outlined,
              size: 17.sp,
              color: const Color(0xFF777777),
            ),

            SizedBox(width: 7.w),

            Icon(
              Icons.delete_outline,
              size: 18.sp,
              color: const Color(0xFFE00025),
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

  Widget _buildPhotoSectionTitle(String title, int count) {
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

  void _showUploadFilesBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
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

                SizedBox(height: 12.h),

                Text(
                  'Upload Files',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 18.h),

                Row(
                  children: [
                    Expanded(
                      child: _uploadOption(
                        icon: Icons.camera_alt_outlined,
                        title: 'Take Photo',
                        onTap: _takePhoto,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _uploadOption(
                        icon: Icons.photo_library_outlined,
                        title: 'Gallery',
                        onTap: _pickGallery,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _uploadOption(
                        icon: Icons.attach_file,
                        title: 'Files',
                        onTap: _pickFiles,
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
            style: TextStyle(fontSize: 13.5.sp, color: const Color(0xFF555555)),
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
            setState(() {
              for (final item in _photos) {
                item.isCover = item.id == photo.id;
              }
            });
          },
          onDelete: () {
            setState(() {
              _photos.removeWhere((item) => item.id == photo.id);
            });
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF333333),
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
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 35.w,
              height: 35.w,
              decoration: BoxDecoration(
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
            'Photo',
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
    final isNetwork = widget.photo.url.startsWith('http');

    if (isNetwork) {
      return Image.network(
        widget.photo.url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return _viewerPlaceholder();
        },
      );
    }

    return Image.file(
      File(widget.photo.url),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        return _viewerPlaceholder();
      },
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
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: _viewerButton(
              label: 'Set as Cover Photo',
              color: const Color(0xFFC8102E),
              icon: Icons.photo_camera_outlined,
              onTap: () {
                widget.onSetCover();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cover photo updated',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(width: 5.w),

          _viewerSmallButton(
            icon: Icons.download_outlined,
            label: 'Download',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Download started',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              );
            },
          ),

          SizedBox(width: 5.w),

          _viewerSmallButton(
            icon: Icons.delete_outline,
            label: 'Delete',
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
    return SizedBox(
      height: 38.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15.sp),
        label: Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  Widget _viewerSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 38.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14.sp),
        label: Text(label, style: TextStyle(fontSize: 12.5.sp)),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide.none,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  void _deletePhoto() {
    widget.onDelete();
    Navigator.pop(context);
  }
}
