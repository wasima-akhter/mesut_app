import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/localization/pending_refetch_controller.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/widgets/images/app_network_image.dart';
import '../../domain/entities/employee_project_details_entity.dart';
import '../providers/employee_assignment_photos_provider.dart';

class EmployeeAssignmentPhotosPage extends ConsumerStatefulWidget {
  final String? projectId;
  final String? assignmentTitle;

  const EmployeeAssignmentPhotosPage({
    super.key,
    this.projectId,
    this.assignmentTitle,
  });

  @override
  ConsumerState<EmployeeAssignmentPhotosPage> createState() =>
      _EmployeeAssignmentPhotosPageState();
}

class _EmployeeAssignmentPhotosPageState
    extends ConsumerState<EmployeeAssignmentPhotosPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pid = widget.projectId;
      if (pid != null && pid.isNotEmpty) {
        ref.read(employeeAssignmentPhotosProvider.notifier).loadInitial(pid);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(employeeAssignmentPhotosProvider.notifier).loadMore();
    }
  }

  void _openImageViewer(EmployeeProjectPhotoEntity photo) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: AppNetworkImage(
                  imageUrl: photo.url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 16.w,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            if (photo.fileName != null)
              Positioned(
                bottom: 30.h,
                left: 16.w,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    photo.fileName!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeAssignmentPhotosProvider);
    final title = widget.assignmentTitle?.isNotEmpty == true
        ? widget.assignmentTitle!
        : context.loc.smPhotos;

    final hasPendingTranslations = anyLocalizationPending(
      state.photos.map((p) => p.localization),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PendingPollEffect(
          hasPending: hasPendingTranslations,
          onPoll: () =>
              ref.read(employeeAssignmentPhotosProvider.notifier).refresh(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
                child: Row(
                  children: [
                    const AppBackButton(),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(employeeAssignmentPhotosProvider.notifier).refresh(),
                  child: _buildBody(state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(EmployeeAssignmentPhotosState state) {
    if (state.isLoading && state.photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.photos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 64.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 12.h),
              Text(
                'No Photos Uploaded',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'There are no photos for this assignment yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.0,
      ),
      itemCount: state.photos.length + (state.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= state.photos.length) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final photo = state.photos[index];
        return GestureDetector(
          onTap: () => _openImageViewer(photo),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: AppColors.neutral100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(
                  imageUrl: photo.url,
                  fit: BoxFit.cover,
                ),
                if (photo.isCover)
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'COVER',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
