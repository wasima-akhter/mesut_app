import 'package:construction_app/app/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../presentation/providers/site_manager_phase_board_provider.dart';

enum ProjectPhase { enquiry, erection, dismantling, standing }

class SiteManagerPhaseBoardPage extends ConsumerStatefulWidget {
  const SiteManagerPhaseBoardPage({super.key});

  @override
  ConsumerState<SiteManagerPhaseBoardPage> createState() =>
      _SiteManagerPhaseBoardPageState();
}

class _SiteManagerPhaseBoardPageState
    extends ConsumerState<SiteManagerPhaseBoardPage> {
  ProjectPhase get _selectedPhase =>
      ref.watch(phaseBoardProvider).selectedPhase;

  List<ProjectBoardModel> get _projects =>
      ref.watch(phaseBoardProvider).projects;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky header
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 18.h, 12.w, 0),
              child: _buildHeader(),
            ),

            SizedBox(height: 14.h),

            // Sticky phase tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: _buildPhaseTabs(),
            ),

            SizedBox(height: 12.h),

            // Only the project cards scroll
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 20.h),
                    sliver: SliverList.builder(
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildProjectCard(_projects[index]),
                        );
                      },
                    ),
                  ),
                ],
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
        _buildBackButton(),

        SizedBox(width: 12.w),

        Expanded(
          child: Text(
            context.loc.phaseBoard,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        _headerIcon(Icons.search_rounded, onTap: () {}),

        SizedBox(width: 7.w),

        _headerIcon(Icons.tune_rounded, onTap: () {}),
      ],
    );
  }

  Widget _buildBackButton() {
    return Material(
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
          ),
          child: Icon(Icons.arrow_back_rounded, size: 18.sp),
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildPhaseTabs() {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ProjectPhase.values.length,
        separatorBuilder: (_, _) => SizedBox(width: 6.w),
        itemBuilder: (context, index) {
          final phase = ProjectPhase.values[index];

          final selected = phase == _selectedPhase;

          return Material(
            color: selected ? AppColors.black : AppColors.surface,
            borderRadius: BorderRadius.circular(7.r),
            child: InkWell(
              onTap: () {
                ref.read(phaseBoardProvider.notifier).setPhase(phase);
              },
              borderRadius: BorderRadius.circular(7.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Row(
                  children: [
                    if (phase != ProjectPhase.enquiry)
                      Container(
                        width: 7.w,
                        height: 7.w,
                        margin: EdgeInsets.only(right: 6.w),
                        decoration: BoxDecoration(
                          color: _phaseColor(phase),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      _phaseLabel(phase),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: selected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(ProjectBoardModel project) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.siteManagerProjectDetail),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _priorityBadge(project.priority),

                const Spacer(),

                Icon(
                  Icons.calendar_month_outlined,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),

                SizedBox(width: 5.w),

                Text(
                  project.days,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            SizedBox(height: 10.h),

            Text(
              '${project.id} • ${project.title}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),

            SizedBox(height: 7.h),

            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 15.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    '${project.company} • ${project.type}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 15.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    project.address,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),

            SizedBox(height: 11.h),

            Divider(height: 1, color: AppColors.border),

            SizedBox(height: 9.h),

            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 17.sp,
                  color: AppColors.textSecondary,
                ),

                SizedBox(width: 5.w),

                Expanded(
                  child: Text(
                    project.assignee,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),

                _moreButton(project),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    Color color;
    String label;

    switch (priority.toLowerCase()) {
      case 'high':
        color = AppColors.error;
        label = context.loc.high;
        break;
      case 'medium':
        color = AppColors.warning;
        label = context.loc.medium;
        break;
      default:
        color = AppColors.textSecondary;
        label = context.loc.low;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  Widget _moreButton(ProjectBoardModel project) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showMoveToBottomSheet(project),
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(Icons.more_vert_rounded, size: 17.sp),
        ),
      ),
    );
  }

  void _showMoveToBottomSheet(ProjectBoardModel project) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  '${project.id}.${project.title}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  context.loc.get('siteManager.moveTo', 'Move to...'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 19.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildMoveOption(
                  sheetContext,
                  icon: Icons.apartment_rounded,
                  iconColor: const Color(0xFF0EA5E9),
                  iconBgColor: const Color(0xFFE8F6FE),
                  title: context.loc.get(
                    'siteManager.standingScaffold',
                    'Standing Scaffold',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _onMoveProject(project, ProjectPhase.standing);
                  },
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
                _buildMoveOption(
                  sheetContext,
                  icon: Icons.build_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  iconBgColor: const Color(0xFFFFF4E5),
                  title: context.loc.get(
                    'siteManager.dismantling',
                    'Dismantling',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _onMoveProject(project, ProjectPhase.dismantling);
                  },
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
                _buildMoveOption(
                  sheetContext,
                  icon: Icons.check_rounded,
                  iconColor: const Color(0xFF4B5563),
                  iconBgColor: const Color(0xFFF3F4F6),
                  title: context.loc.get('siteManager.completed', 'Completed'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _onMoveProject(project, null, isCompleted: true);
                  },
                ),
                SizedBox(height: 16.h),
                Center(
                  child: InkWell(
                    onTap: () => Navigator.of(sheetContext).pop(),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      child: Text(
                        context.loc.cancel,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                        ),
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

  Widget _buildMoveOption(
    BuildContext sheetContext, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19.sp, color: iconColor),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: Theme.of(sheetContext).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMoveProject(
    ProjectBoardModel project,
    ProjectPhase? phase, {
    bool isCompleted = false,
  }) {
    final destination = isCompleted
        ? context.loc.get('siteManager.completed', 'Completed')
        : (phase != null ? _phaseLabel(phase) : '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.loc.get(
            'siteManager.projectMovedTo',
            'Moved ${project.id} to $destination',
            {'id': project.id, 'phase': destination},
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _phaseLabel(ProjectPhase phase) {
    switch (phase) {
      case ProjectPhase.enquiry:
        return context.loc.enquiry;
      case ProjectPhase.erection:
        return context.loc.erectionPhase;
      case ProjectPhase.dismantling:
        return context.loc.dismantlingPhase;
      case ProjectPhase.standing:
        return context.loc.standing;
    }
  }

  Color _phaseColor(ProjectPhase phase) {
    switch (phase) {
      case ProjectPhase.erection:
        return AppColors.success;
      case ProjectPhase.dismantling:
        return AppColors.warning;
      case ProjectPhase.standing:
        return AppColors.info;
      case ProjectPhase.enquiry:
        return AppColors.textSecondary;
    }
  }
}

class ProjectBoardModel {
  final String id;
  final String title;
  final String company;
  final String type;
  final String address;
  final String assignee;
  final String priority;
  final String days;

  const ProjectBoardModel({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.address,
    required this.assignee,
    required this.priority,
    required this.days,
  });
}
