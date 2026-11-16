import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/services/permission_service.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../../../core/widgets/states/app_data_state.dart';
import '../../../../../core/widgets/states/app_screen_state_view.dart';
import '../../../projects/overview_modules.dart';
import '../../domain/entities/project_attachment_entity.dart';
import '../providers/project_attachments_provider.dart';
import '../providers/project_attachments_state.dart';
import 'project_attachment_card.dart';
import 'project_attachment_viewer_dialog.dart';
import 'project_attachments_skeleton_loader.dart';
import 'project_cover_photo_card.dart';
import 'project_photos_empty_view.dart';
import 'project_photos_toolbar.dart';
import 'project_plan_card.dart';
import 'project_upload_attachments_sheet.dart';

class ProjectPhotosTabView extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectPhotosTabView({
    super.key,
    required this.projectId,
    this.projectName = '',
  });

  @override
  ConsumerState<ProjectPhotosTabView> createState() =>
      _ProjectPhotosTabViewState();
}

class _ProjectPhotosTabViewState extends ConsumerState<ProjectPhotosTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(projectAttachmentsProvider.notifier)
          .loadInitial(widget.projectId);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(projectAttachmentsProvider.notifier).loadMore();
    }
  }

  Future<void> _handleCameraUpload() async {
    final allowed = await AppPermissions.requestCamera();
    if (!allowed) {
      if (!mounted) return;
      await showPermissionDialog(
        title: context.loc.cameraPermissionRequired,
        message: context.loc.cameraPermissionMessage,
        context: context,
      );
      return;
    }
    final success = await ref
        .read(projectAttachmentsProvider.notifier)
        .uploadPhotoFromSource(source: ImageSource.camera);
    if (!mounted) return;
    if (success) {
      AppSnackBar.showSuccess(context, context.loc.photoUploaded);
    }
  }

  Future<void> _handleGalleryUpload() async {
    final allowed = await AppPermissions.requestPhotos();
    if (!allowed) {
      if (!mounted) return;
      await showPermissionDialog(
        title: context.loc.photoPermissionRequired,
        message: context.loc.photoPermissionMessage,
        context: context,
      );
      return;
    }
    final success = await ref
        .read(projectAttachmentsProvider.notifier)
        .uploadMultiplePhotos();
    if (!mounted) return;
    if (success) {
      AppSnackBar.showSuccess(context, context.loc.photoUploaded);
    }
  }

  Future<void> _handlePdfUpload() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result.isEmpty) return;
    final file = result.first;
    if (file.path == null) return;

    final success = await ref
        .read(projectAttachmentsProvider.notifier)
        .uploadPlanFile(file: File(file.path!), fileName: file.name);
    if (!mounted) return;
    if (success) {
      AppSnackBar.showSuccess(context, context.loc.planUploaded);
    }
  }

  void _showUploadSheet() {
    ProjectUploadAttachmentsSheet.show(
      context: context,
      onTakePhoto: _handleCameraUpload,
      onChooseGallery: _handleGalleryUpload,
      onUploadPdf: _handlePdfUpload,
    );
  }

  void _openViewer(ProjectAttachmentEntity attachment) {
    ProjectAttachmentViewerDialog.show(
      context: context,
      attachment: attachment,
      onSetCover: () => _setCover(attachment.id),
      onDelete: () => _deleteAttachment(attachment.id),
    );
  }

  Future<void> _setCover(String id) async {
    final ok = await ref
        .read(projectAttachmentsProvider.notifier)
        .setCoverPhoto(id);
    if (!mounted) return;
    if (ok) {
      AppSnackBar.showSuccess(context, context.loc.coverPhotoUpdated);
    } else {
      AppSnackBar.showError(context, context.loc.operationFailed);
    }
  }

  Future<void> _deleteAttachment(String id) async {
    final ok = await ref
        .read(projectAttachmentsProvider.notifier)
        .deleteAttachment(id);
    if (!mounted) return;
    if (ok) {
      AppSnackBar.showSuccess(context, context.loc.attachmentDeleted);
    } else {
      AppSnackBar.showError(context, context.loc.operationFailed);
    }
  }

  Widget _buildContent(ProjectAttachmentsState state) {
    final cover = state.coverPhoto;
    final otherPhotos = state.otherPhotos;
    final pdfPlans = state.pdfPlans;
    final notifier = ref.read(projectAttachmentsProvider.notifier);

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 25.h),
      children: [
        ProjectPhotosToolbar(
          photoCount: state.photoCount,
          planCount: state.planCount,
          activeFilter: state.activeFilter,
          onFilterChanged: notifier.setActiveFilter,
          onUploadPressed: _showUploadSheet,
        ),
        SizedBox(height: 12.h),
        if (state.isEmpty)
          ProjectPhotosEmptyView(onUploadPressed: _showUploadSheet)
        else ...[
          if (state.showPhotosSection) ...[
            if (cover != null) ...[
              ProjectCoverPhotoCard(
                photo: cover,
                onTap: () => _openViewer(cover),
                onSetCover: () => _setCover(cover.id),
                onDelete: () => _deleteAttachment(cover.id),
              ),
              SizedBox(height: 12.h),
            ],
            if (otherPhotos.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1.25,
                ),
                itemCount: otherPhotos.length,
                itemBuilder: (ctx, index) {
                  final photo = otherPhotos[index];
                  return ProjectAttachmentCard(
                    attachment: photo,
                    onTap: () => _openViewer(photo),
                    onSetCover: () => _setCover(photo.id),
                    onDelete: () => _deleteAttachment(photo.id),
                  );
                },
              ),
              SizedBox(height: 14.h),
            ],
          ],
          if (state.showPlansSection && pdfPlans.isNotEmpty) ...[
            Text(
              '${context.loc.pdfPlans} (${pdfPlans.length})',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            ...pdfPlans.map(
              (plan) => ProjectPlanCard(
                attachment: plan,
                projectName: widget.projectName,
                onDelete: () => _deleteAttachment(plan.id),
              ),
            ),
          ],
        ],
        if (state.isLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectAttachmentsProvider);
    final status = state.isLoading && state.items.isEmpty
        ? AppDataStatus.loading
        : (state.errorMessage != null && state.items.isEmpty
              ? AppDataStatus.error
              : AppDataStatus.success);

    return Stack(
      children: [
        AppScreenStateView(
          status: status,
          errorMessage: state.errorMessage,
          loadingShimmer: const ProjectAttachmentsSkeletonLoader(),
          onRetry: () => ref
              .read(projectAttachmentsProvider.notifier)
              .loadInitial(widget.projectId, isRefresh: true),
          child: RefreshIndicator(
            onRefresh: () => ref
                .read(projectAttachmentsProvider.notifier)
                .loadInitial(widget.projectId, isRefresh: true),
            child: _buildContent(state),
          ),
        ),
        if (state.isMutating)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFC8102E)),
            ),
          ),
      ],
    );
  }
}
