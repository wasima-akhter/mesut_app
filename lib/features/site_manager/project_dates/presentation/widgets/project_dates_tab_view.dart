import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/localization/pending_refetch_controller.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../../../core/widgets/states/app_data_state.dart';
import '../../../../../core/widgets/states/app_empty_widget.dart';
import '../../../../../core/widgets/states/app_screen_state_view.dart';
import '../providers/project_dates_provider.dart';
import '../providers/project_dates_state.dart';
import 'project_dates_skeleton_loader.dart';
import 'project_phase_date_card.dart';

class ProjectDatesTabView extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDatesTabView({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDatesTabView> createState() =>
      _ProjectDatesTabViewState();
}

class _ProjectDatesTabViewState extends ConsumerState<ProjectDatesTabView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectDatesProvider.notifier).loadInitial(widget.projectId);
    });
  }

  Future<void> _onRefresh() async {
    await ref
        .read(projectDatesProvider.notifier)
        .loadInitial(widget.projectId, isRefresh: true);
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FF),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: const Color(0xFF1799D6), size: 18.sp),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              context.loc.changesNotice,
              style: TextStyle(
                fontSize: 15.sp,
                color: const Color(0xFF1799D6),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ProjectDatesState state) {
    if (state.isEmpty) {
      return Center(
        child: AppEmptyWidget(
          message: context.loc.noPhases,
          onRetry: _onRefresh,
        ),
      );
    }

    final notifier = ref.read(projectDatesProvider.notifier);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 30.h),
      children: [
        _buildInfoBanner(),
        ...state.items.map(
          (phase) => ProjectPhaseDateCard(
            phase: phase,
            isSaving: state.isSaving,
            onSave:
                ({
                  required startDate,
                  required endDate,
                  required durationDays,
                  safetyInspectionComplete,
                }) async {
                  final ok = await notifier.updatePhaseDates(
                    phaseId: phase.id,
                    startDate: startDate,
                    endDate: endDate,
                    durationDays: durationDays,
                    safetyInspectionComplete: safetyInspectionComplete,
                  );
                  if (!mounted) return;
                  if (ok) {
                    AppSnackBar.showSuccess(
                      context,
                      context.loc.scheduleChangesSaved,
                    );
                  } else {
                    AppSnackBar.showError(context, context.loc.operationFailed);
                  }
                },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectDatesProvider);
    final status = state.isLoading && state.items.isEmpty
        ? AppDataStatus.loading
        : (state.errorMessage != null && state.items.isEmpty
              ? AppDataStatus.error
              : AppDataStatus.success);

    return AppScreenStateView(
      status: status,
      errorMessage: state.errorMessage,
      loadingShimmer: const ProjectDatesSkeletonLoader(),
      onRetry: _onRefresh,
      child: PendingPollEffect(
        hasPending: anyLocalizationPending(state.items.map((i) => i.localization)),
        onPoll: _onRefresh,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: _buildContent(state),
        ),
      ),
    );
  }
}
