import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/image_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/widgets/images/app_network_image.dart';
import '../../../core/widgets/snack/app_snackbar.dart';

class InspectionPhotoItem {
  final String id;
  final String title;
  final String category;
  final String url;
  final String timestamp;

  const InspectionPhotoItem({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.timestamp,
  });
}

class InspectionPhotosViewAllPage extends StatefulWidget {
  const InspectionPhotosViewAllPage({super.key});

  @override
  State<InspectionPhotosViewAllPage> createState() =>
      _InspectionPhotosViewAllPageState();
}

class _InspectionPhotosViewAllPageState
    extends State<InspectionPhotosViewAllPage> {
  String _selectedCategory = 'All';

  final List<InspectionPhotoItem> _photos = [
    const InspectionPhotoItem(
      id: '1',
      title: 'North Facade - Level 3 Base Jack',
      category: 'Foundation',
      url: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800',
      timestamp: 'Today, 10:15 am',
    ),
    const InspectionPhotoItem(
      id: '2',
      title: 'West Wing Wall Anchor Ties',
      category: 'Anchors',
      url: 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800',
      timestamp: 'Today, 10:20 am',
    ),
    const InspectionPhotoItem(
      id: '3',
      title: 'Main Entrance Pedestrian Tunnel',
      category: 'Scaffold',
      url: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
      timestamp: 'Today, 10:24 am',
    ),
    const InspectionPhotoItem(
      id: '4',
      title: 'Guardrail & Toe-board Inspection',
      category: 'Safety',
      url: 'https://images.unsplash.com/photo-1590725175248-ecb2a7f7a4c6?w=800',
      timestamp: 'Yesterday, 04:10 pm',
    ),
    const InspectionPhotoItem(
      id: '5',
      title: 'Base Jack Leveling on Compact Ground',
      category: 'Foundation',
      url: 'https://images.unsplash.com/photo-1541971875076-8f970d573be6?w=800',
      timestamp: '16 Sep 2026, 14:00',
    ),
    const InspectionPhotoItem(
      id: '6',
      title: 'Roof Protection Scaffold Section B',
      category: 'Scaffold',
      url: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=800',
      timestamp: '16 Sep 2026, 11:30',
    ),
    const InspectionPhotoItem(
      id: '7',
      title: 'Ladder Access Hatch Security Check',
      category: 'Safety',
      url: 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800',
      timestamp: '15 Sep 2026, 09:45',
    ),
    const InspectionPhotoItem(
      id: '8',
      title: 'Diagonal Bracing Alignment',
      category: 'Scaffold',
      url: 'https://images.unsplash.com/photo-1508873696983-2df5293cb395?w=800',
      timestamp: '15 Sep 2026, 08:30',
    ),
  ];

  List<String> get _categories => [
        'All',
        'Scaffold',
        'Foundation',
        'Anchors',
        'Safety',
      ];

  List<InspectionPhotoItem> get _filteredPhotos {
    if (_selectedCategory == 'All') return _photos;
    return _photos
        .where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase())
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
                  color: Color(0xFFC8102E),
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
                  color: Color(0xFFC8102E),
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
          InspectionPhotoItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                image.path.hashCode.toString(),
            title: 'New Site Photo',
            category: _selectedCategory,
            url: image.path,
            timestamp: 'Just now',
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
          InspectionPhotoItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'New Site Photo',
            category: 'Scaffold',
            url: image.path,
            timestamp: 'Just now',
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
        builder: (_) => _FullScreenPhotoViewer(
          photos: _filteredPhotos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPhotos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text(
              context.loc.sitePhoto,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceTertiary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${filtered.length}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: AppColors.textPrimary),
            tooltip: context.loc.takePhoto,
            onPressed: _showAddPhotoSheet,
          ),
          SizedBox(width: 4.w),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPhotoSheet,
        backgroundColor: const Color(0xFFC8102E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt),
        label: Text(
          context.loc.takePhoto,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category filter chips
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        labelStyle: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        selectedColor: Colors.black87,
                        backgroundColor: const Color(0xFFF3F3F3),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          side: BorderSide.none,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            Divider(height: 1, color: AppColors.border),

            // Photo Grid
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 48.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            context.loc.noData,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 80.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final photo = filtered[index];
                        return _buildPhotoCard(photo, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(InspectionPhotoItem photo, int index) {
    return GestureDetector(
      onTap: () => _openFullScreenViewer(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
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
                  AppNetworkImage(
                    imageUrl: photo.url,
                    fit: BoxFit.cover,
                    fallback: Container(
                      color: const Color(0xFFEEEEEE),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        photo.category,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          photo.timestamp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
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
}

/// Full screen interactive zoom/pan photo viewer
class _FullScreenPhotoViewer extends StatefulWidget {
  final List<InspectionPhotoItem> photos;
  final int initialIndex;

  const _FullScreenPhotoViewer({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<_FullScreenPhotoViewer> {
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: TextStyle(fontSize: 16.sp, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
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
                maxScale: 3.5,
                child: Center(
                  child: AppNetworkImage(
                    imageUrl: photo.url,
                    fit: BoxFit.contain,
                    fallback: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentPhoto.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8102E),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          currentPhoto.category,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        currentPhoto.timestamp,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
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
    );
  }
}
