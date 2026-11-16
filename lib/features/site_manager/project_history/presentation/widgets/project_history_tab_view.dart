import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/states/app_data_state.dart';
import '../../../../../core/widgets/states/app_empty_widget.dart';
import '../../../../../core/widgets/states/app_screen_state_view.dart';
import '../providers/project_history_provider.dart';
import '../providers/project_history_state.dart';
import 'project_history_item_card.dart';
import 'project_history_skeleton_loader.dart';

class ProjectHistoryTabView extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectHistoryTabView({super.key, required this.projectId});

  @override
  ConsumerState<ProjectHistoryTabView> createState() =>
      _ProjectHistoryTabViewState();
}

class _ProjectHistoryTabViewState extends ConsumerState<ProjectHistoryTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectHistoryProvider.notifier).loadInitial(widget.projectId);
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
      ref.read(projectHistoryProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref
        .read(projectHistoryProvider.notifier)
        .loadInitial(widget.projectId, isRefresh: true);
  }

  Widget _buildContent(ProjectHistoryState state) {
    if (state.isEmpty) {
      return Center(
        child: AppEmptyWidget(
          message: context.loc.noHistory,
          onRetry: _onRefresh,
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (ctx, index) {
        if (index >= state.items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFC8102E),
              ),
            ),
          );
        }

        final item = state.items[index];
        final isLast = index == state.items.length - 1 && !state.isLoadingMore;
        return ProjectHistoryItemCard(item: item, isLast: isLast);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectHistoryProvider);
    final status = state.isLoading && state.items.isEmpty
        ? AppDataStatus.loading
        : (state.errorMessage != null && state.items.isEmpty
              ? AppDataStatus.error
              : AppDataStatus.success);

    return AppScreenStateView(
      status: status,
      errorMessage: state.errorMessage,
      loadingShimmer: const ProjectHistorySkeletonLoader(),
      onRetry: _onRefresh,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildContent(state),
      ),
    );
  }
}
