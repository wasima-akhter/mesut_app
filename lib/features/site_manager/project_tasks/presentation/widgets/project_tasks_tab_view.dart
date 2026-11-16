import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/states/app_screen_state_view.dart';
import '../../../projects/enums.dart';
import '../providers/project_tasks_provider.dart';
import 'project_task_card.dart';
import 'project_tasks_skeleton_loader.dart';
import 'project_tasks_tab_bar.dart';

class ProjectTasksTabView extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectTasksTabView({super.key, required this.projectId});

  @override
  ConsumerState<ProjectTasksTabView> createState() =>
      _ProjectTasksTabViewState();
}

class _ProjectTasksTabViewState extends ConsumerState<ProjectTasksTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(projectTasksProvider.notifier).loadInitial(widget.projectId);
    });
  }

  @override
  void didUpdateWidget(ProjectTasksTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      ref.read(projectTasksProvider.notifier).loadInitial(widget.projectId);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(projectTasksProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectTasksProvider);
    final notifier = ref.read(projectTasksProvider.notifier);

    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectTasksTabBar(projectId: widget.projectId),
          SizedBox(height: 10.h),
          Expanded(
            child: AppScreenStateView(
              status: state.status,
              loadingShimmer: const ProjectTasksSkeletonLoader(),
              errorMessage: state.errorMessage,
              errorObject: state.errorObject,
              onRetry: () => notifier.loadInitial(widget.projectId, isRefresh: true),
              emptyPlaceholder: _buildEmptyState(
                context,
                state.selectedTab == TaskStatusTab.open,
                notifier,
              ),
              child: RefreshIndicator(
                onRefresh: () => notifier.loadInitial(widget.projectId, isRefresh: true),
                color: const Color(0xFFC8102E),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount:
                      state.currentTasks.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.currentTasks.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFC8102E),
                            ),
                          ),
                        ),
                      );
                    }

                    final task = state.currentTasks[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: ProjectTaskCard(task: task),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isOpen,
    ProjectTasksNotifier notifier,
  ) {
    return RefreshIndicator(
      onRefresh: () => notifier.loadInitial(widget.projectId, isRefresh: true),
      color: const Color(0xFFC8102E),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE7E7E7)),
            ),
            child: Column(
              children: [
                Icon(
                  isOpen ? Icons.task_alt_outlined : Icons.check_circle_outline,
                  size: 38.sp,
                  color: const Color(0xFFBDBDBD),
                ),
                SizedBox(height: 10.h),
                Text(
                  isOpen
                      ? context.loc.noOpenTasks
                      : context.loc.noCompletedTasks,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF555555),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isOpen
                      ? context.loc.allTasksCompleted
                      : context.loc.completedTasksAppearHere,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
