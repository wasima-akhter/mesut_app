import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../../../core/widgets/states/app_error_widget.dart';
import '../providers/project_notes_provider.dart';
import 'project_note_card.dart';
import 'project_note_sheet.dart';
import 'project_notes_skeleton_loader.dart';

/// Full tab view for the Project Details screen displaying project notes.
class ProjectNotesTabView extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectNotesTabView({super.key, required this.projectId});

  @override
  ConsumerState<ProjectNotesTabView> createState() =>
      _ProjectNotesTabViewState();
}

class _ProjectNotesTabViewState extends ConsumerState<ProjectNotesTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectNotesProvider.notifier).loadInitial(widget.projectId);
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
      ref.read(projectNotesProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(projectNotesProvider.notifier).loadInitial(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectNotesProvider);
    final notifier = ref.read(projectNotesProvider.notifier);

    if (state.isLoading && state.items.isEmpty) {
      return const ProjectNotesSkeletonLoader();
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return AppErrorWidget(message: state.errorMessage!, onRetry: _onRefresh);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 30.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTopBar(),
                SizedBox(height: 10.h),
                if (state.isEmpty)
                  _buildEmptyState()
                else ...[
                  ...state.items.map((note) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 9.h),
                      child: ProjectNoteCard(
                        note: note,
                        onEdit: () =>
                            ProjectNoteSheet.show(context, initialNote: note),
                        onDelete: () async {
                          final success = await notifier.deleteNote(note.id);
                          if (context.mounted && success) {
                            AppSnackBar.showSuccess(
                              context,
                              context.loc.noteDeleted,
                            );
                          }
                        },
                      ),
                    );
                  }),
                  if (state.isLoadingMore)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const Spacer(),
        AppButton.small(
          text: context.loc.addNote,
          leadingIcon: Icons.add,
          onPressed: () => ProjectNoteSheet.show(context),
          borderRadius: 6.r,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notes_outlined,
            size: 42.sp,
            color: const Color(0xFFBBBBBB),
          ),
          SizedBox(height: 10.h),
          Text(
            context.loc.noProjectNotes,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 5.h),
          Text(
            context.loc.noProjectNotesDesc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5.sp, color: const Color(0xFF888888)),
          ),
        ],
      ),
    );
  }
}
