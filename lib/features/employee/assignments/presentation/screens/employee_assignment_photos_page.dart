import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/extensions/date_time_extensions.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/services/image_service.dart';
import 'package:construction_app/core/services/permission_service.dart';
import 'package:construction_app/core/widgets/images/app_network_image.dart';
import 'package:construction_app/core/widgets/snack/app_snackbar.dart';

class EmployeePhotoItem {
  final String id;
  final String title;
  final String category;
  final String? url;
  final IconData placeholderIcon;
  final DateTime timestamp;

  const EmployeePhotoItem({
    required this.id,
    required this.title,
    required this.category,
    this.url,
    this.placeholderIcon = Icons.business_outlined,
    required this.timestamp,
  });

  String formattedTimestamp() => timestamp.formatRelative();
}

class EmployeeAssignmentPhotosPage extends StatefulWidget {
  final String? assignmentTitle;

  const EmployeeAssignmentPhotosPage({super.key, this.assignmentTitle});

  @override
  State<EmployeeAssignmentPhotosPage> createState() =>
      _EmployeeAssignmentPhotosPageState();
}

class _EmployeeAssignmentPhotosPageState
    extends State<EmployeeAssignmentPhotosPage> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Scaffold Setup',
    'Ground Level',
    'Safety Checks',
    'Progress',
  ];

  final List<EmployeePhotoItem> _photos = [
    EmployeePhotoItem(
      id: 'photo-1',
      title: 'North Facade Scaffold Setup',
      category: 'Scaffold Setup',
      url:
          'https://images.unsplash.com/photo-1541888946425-d0fbb18f15f6?w=600&auto=format&fit=crop&q=80',
      placeholderIcon: Icons.business,
      timestamp: DateTime.utc(2026, 10, 8, 8, 30),
    ),
    EmployeePhotoItem(
      id: 'photo-2',
      title: 'Ground Frame & Base Jacks',
      category: 'Ground Level',
      url:
          'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&auto=format&fit=crop&q=80',
      placeholderIcon: Icons.construction,
      timestamp: DateTime.utc(2026, 10, 8, 9, 15),
    ),
    EmployeePhotoItem(
      id: 'photo-3',
      title: 'Safety Netting & Guard Rails',
      category: 'Safety Checks',
      url:
          'https://images.unsplash.com/photo-1590381105924-c72589b9ef3f?w=600&auto=format&fit=crop&q=80',
      placeholderIcon: Icons.security,
      timestamp: DateTime.utc(2026, 10, 7, 16, 45),
    ),
    EmployeePhotoItem(
      id: 'photo-4',
      title: 'Upper Section Assembly',
      category: 'Progress',
      url:
          'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600&auto=format&fit=crop&q=80',
      placeholderIcon: Icons.apartment,
      timestamp: DateTime.utc(2026, 10, 7, 14, 10),
    ),
    EmployeePhotoItem(
      id: 'photo-5',
      title: 'Anchor Wall Mount Details',
      category: 'Safety Checks',
      url:
          'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=600&auto=format&fit=crop&q=80',
      placeholderIcon: Icons.hardware,
      timestamp: DateTime.utc(2026, 10, 4, 11, 20),
    ),
    EmployeePhotoItem(
      id: 'photo-6',
      title: 'Material Delivery & Stockpile',
      category: 'Ground Level',
      url:
          'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=600&auto=format&fit=crop&q=80',
      placeholderIcon: Icons.local_shipping_outlined,
      timestamp: DateTime.utc(2026, 10, 3, 8, 0),
    ),
  ];

  List<EmployeePhotoItem> get _filteredPhotos {
    if (_selectedCategory == 'All') return _photos;
    return _photos
        .where((photo) => photo.category == _selectedCategory)
        .toList();
  }

  Future<void> _showAddPhotoSheet() async {
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
                onTap: () {
                  Navigator.pop(ctx);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.folder_outlined,
                  color: AppColors.primary,
                ),
                title: Text(context.loc.deviceStorage),
                subtitle: Text(context.loc.chooseFromDevice),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromDeviceStorage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromDeviceStorage() async {
    final images = await AppImageService.pickMultipleCompressedImages();
    if (images.isEmpty || !mounted) return;

    setState(() {
      for (final image in images) {
        _photos.insert(
          0,
          EmployeePhotoItem(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                image.path.hashCode.toString(),
            title:
                'Site Photo (${DateTime.now().hour}:${DateTime.now().minute})',
            category: _selectedCategory,
            url: image.path,
            placeholderIcon: Icons.photo_camera,
            timestamp: DateTime.now().toUtc(),
          ),
        );
      }
    });

    AppSnackBar.showSuccess(
      context,
      context.loc.get('siteManager.photoAdded', 'Photo added successfully'),
    );
  }

  Future<void> _takePhoto() async {
    final allowed = await AppPermissions.requestCamera();
    if (!allowed) {
      if (mounted) {
        AppSnackBar.showWarning(
          context,
          context.loc.get(
            'common.cameraPermissionDenied',
            'Camera permission denied',
          ),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      setState(() {
        _photos.insert(
          0,
          EmployeePhotoItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title:
                'Site Photo (${DateTime.now().hour}:${DateTime.now().minute})',
            category: 'Scaffold Setup',
            url: image.path,
            placeholderIcon: Icons.photo_camera,
            timestamp: DateTime.now().toUtc(),
          ),
        );
      });
      AppSnackBar.showSuccess(
        context,
        context.loc.get('siteManager.photoAdded', 'Photo added successfully'),
      );
    }
  }

  void _openFullScreenViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenEmployeePhotoViewer(
          photos: _filteredPhotos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
              child: _buildHeader(),
            ),

            // Category Filter Chips
            _buildCategoryFilter(),

            SizedBox(height: 8.h),

            // Photo Grid
            Expanded(
              child: _filteredPhotos.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 20.h),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: _filteredPhotos.length,
                      itemBuilder: (context, index) {
                        final photo = _filteredPhotos[index];
                        return _buildPhotoCard(photo, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(50.r),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                color: AppColors.surface,
              ),
              child: Icon(Icons.arrow_back_rounded, size: 18.sp),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.loc.smPhotos} (${_photos.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (widget.assignmentTitle != null)
                Text(
                  widget.assignmentTitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(50.r),
          child: InkWell(
            onTap: _showAddPhotoSheet,
            borderRadius: BorderRadius.circular(50.r),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 19.sp,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Material(
            color: isSelected ? AppColors.black : AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.black : AppColors.border,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoCard(EmployeePhotoItem photo, int index) {
    return GestureDetector(
      onTap: () => _openFullScreenViewer(index),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWidget(photo),
                  // Category Badge
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        photo.category,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  // Fullscreen preview hint
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fullscreen_rounded,
                        size: 17.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          photo.formattedTimestamp(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(EmployeePhotoItem photo) {
    if (photo.url == null || photo.url!.isEmpty) {
      return Container(
        color: AppColors.neutral200,
        child: Center(
          child: Icon(
            photo.placeholderIcon,
            size: 36.sp,
            color: AppColors.neutral500,
          ),
        ),
      );
    }

    if (photo.url!.startsWith('http://') || photo.url!.startsWith('https://')) {
      return AppNetworkImage(
        imageUrl: photo.url!,
        fit: BoxFit.cover,
        fallback: Container(
          color: AppColors.neutral200,
          child: Center(
            child: Icon(
              photo.placeholderIcon,
              size: 36.sp,
              color: AppColors.neutral500,
            ),
          ),
        ),
      );
    }

    return Image.file(
      File(photo.url!),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.neutral200,
        child: Center(
          child: Icon(
            photo.placeholderIcon,
            size: 36.sp,
            color: AppColors.neutral500,
          ),
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
            size: 48.sp,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            context.loc.noData,
            style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FullScreenEmployeePhotoViewer extends StatefulWidget {
  final List<EmployeePhotoItem> photos;
  final int initialIndex;

  const _FullScreenEmployeePhotoViewer({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_FullScreenEmployeePhotoViewer> createState() =>
      _FullScreenEmployeePhotoViewerState();
}

class _FullScreenEmployeePhotoViewerState
    extends State<_FullScreenEmployeePhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhoto = widget.photos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Interactive PageView
            PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(child: _buildViewerImage(photo)),
                );
              },
            ),

            // Top Bar
            Positioned(
              top: 10.h,
              left: 14.w,
              right: 14.w,
              child: Row(
                children: [
                  Material(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(50.r),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(50.r),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.photos.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Information Overlay
            Positioned(
              bottom: 16.h,
              left: 14.w,
              right: 14.w,
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentPhoto.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            currentPhoto.category,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          currentPhoto.formattedTimestamp(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewerImage(EmployeePhotoItem photo) {
    if (photo.url == null || photo.url!.isEmpty) {
      return Icon(photo.placeholderIcon, size: 90.sp, color: Colors.white54);
    }

    if (photo.url!.startsWith('http://') || photo.url!.startsWith('https://')) {
      return AppNetworkImage(
        imageUrl: photo.url!,
        fit: BoxFit.contain,
        fallback:
            Icon(photo.placeholderIcon, size: 90.sp, color: Colors.white54),
      );
    }

    return Image.file(
      File(photo.url!),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          Icon(photo.placeholderIcon, size: 90.sp, color: Colors.white54),
    );
  }
}
