import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/localization/pending_refetch_controller.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../../../core/widgets/states/app_empty_widget.dart';
import '../../../../../core/widgets/states/app_error_widget.dart';
import '../providers/project_measurements_provider.dart';
import 'project_measurement_card.dart';
import 'project_measurement_header_card.dart';
import 'project_measurement_sheet.dart';
import 'project_measurement_skeleton_loader.dart';

/// Full tab view for the Project Details screen displaying scaffold measurements.
class ProjectMeasurementTabView extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectMeasurementTabView({super.key, required this.projectId});

  @override
  ConsumerState<ProjectMeasurementTabView> createState() =>
      _ProjectMeasurementTabViewState();
}

class _ProjectMeasurementTabViewState
    extends ConsumerState<ProjectMeasurementTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(projectMeasurementsProvider.notifier)
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
      ref.read(projectMeasurementsProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref
        .read(projectMeasurementsProvider.notifier)
        .loadInitial(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectMeasurementsProvider);
    final notifier = ref.read(projectMeasurementsProvider.notifier);

    if (state.isLoading && state.items.isEmpty) {
      return const ProjectMeasurementSkeletonLoader();
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return AppErrorWidget(message: state.errorMessage!, onRetry: _onRefresh);
    }

    return PendingPollEffect(
      hasPending: anyLocalizationPending(state.items.map((m) => m.localization)),
      onPoll: _onRefresh,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 25.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ProjectMeasurementHeaderCard(
                  totalArea: state.displayTotalArea,
                  onAddLine: () => ProjectMeasurementSheet.show(context),
                ),
                SizedBox(height: 10.h),
                if (state.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: AppEmptyWidget(
                      title: context.loc.noMeasurements,
                      message: context.loc.noMeasurementsSubtitle,
                      onRetry: () => ProjectMeasurementSheet.show(context),
                    ),
                  )
                else ...[
                  ...state.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: ProjectMeasurementCard(
                        item: item,
                        index: index,
                        onEdit: () => ProjectMeasurementSheet.show(
                          context,
                          initialItem: item,
                        ),
                        onDelete: () async {
                          final success = await notifier.deleteMeasurement(
                            item.id,
                          );
                          if (context.mounted && success) {
                            AppSnackBar.showSuccess(
                              context,
                              context.loc.measurementDeleted,
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
    ),
  );
  }
}
