import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/services/launcher_service.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../../../core/enums/app_enum.dart';
import '../../map/domain/entities/map_location_entity.dart';
import '../../map/domain/entities/map_request_entity.dart';
import '../../map/utils/map_coordinate_resolver.dart';
import '../helper/employee_enums.dart';
import '../helper/employee_models.dart';
import '../presentation/providers/employee_assignment_details_provider.dart';
import '../presentation/providers/employee_timer_provider.dart';

class AssignmentDetailsPage extends ConsumerWidget {
  const AssignmentDetailsPage({super.key});

  void _startTimer(BuildContext context, WidgetRef ref) {
    final assignment = ref.read(assignmentDetailsProvider).assignment;
    ref
        .read(employeeTimerProvider.notifier)
        .startTimer(
          project: EmployeeProjectModel(
            id: assignment.project.split('·').first.trim(),
            name: assignment.project,
            address: assignment.address,
            activity: assignment.activity,
            startTime: '07:30 am',
            endTime: '04:15 pm',
            startTimeOfDay:
                assignment.startTimeOfDay ??
                const TimeOfDay(hour: 7, minute: 30),
            endTimeOfDay:
                assignment.endTimeOfDay ??
                const TimeOfDay(hour: 16, minute: 15),
            siteManager: assignment.siteManager,
          ),
          activity: assignment.activity,
        );
    context.push(RouteConstants.employeeActiveTimerPage);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assignmentDetailsProvider);
    final assignment = state.assignment;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 10.h),
              sliver: SliverToBoxAdapter(child: _buildHeader(context)),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildProjectCard(context, assignment),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildMapCard(context, assignment),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildManagerCard(context, assignment),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildInstructionsCard(context),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildPhotosCard(context, assignment),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildTasksCard(context, ref, state),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 16.h)),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 25.h),
              sliver: SliverToBoxAdapter(
                child: AppButton(
                  onPressed: () => _startTimer(context, ref),
                  height: 52.h,
                  text: context.loc.startNewTimer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const AppBackButton(),

        SizedBox(width: 14.w),

        Text(
          context.loc.assignmentDetail,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    EmployeeAssignmentModel assignment,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _activityChip(assignment.activity),

          SizedBox(height: 14.h),

          Text(
            assignment.project,
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 8.h),

          _infoRow(
            Icons.access_time_outlined,
            '${context.loc.today}, ${assignment.formattedSchedule}',
          ),

          SizedBox(height: 8.h),

          _infoRow(
            Icons.straighten_outlined,
            '${context.loc.scaffoldArea}: ${assignment.scaffoldArea}',
          ),

          if (assignment.totalProjectHours != null) ...[
            SizedBox(height: 8.h),
            _infoRow(
              Icons.timelapse_rounded,
              '${context.loc.totalProjectHours}: ${assignment.totalProjectHours}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapCard(
    BuildContext context,
    EmployeeAssignmentModel assignment,
  ) {
    return _card(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          Container(
            height: 145.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9.r),
              color: const Color(0xFFDDE6D8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _MapPainter())),

                const Positioned(
                  left: 115,
                  top: 52,
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),

                Positioned(
                  left: 12.w,
                  bottom: 10.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 19,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          assignment.address,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () {
                final destination = MapLocationEntity(
                  id: 'assignment_${assignment.project.hashCode}',
                  title: assignment.project,
                  address: assignment.address,
                  coordinate: MapCoordinateResolver.resolve(assignment.address),
                  type: assignment.activity.name,
                );
                context.push(
                  RouteConstants.map,
                  extra: MapRequestEntity.routeNavigation(
                    role: UserRole.employee,
                    destination: destination,
                  ),
                );
              },
              height: 48.h,
              text: context.loc.navigation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerCard(
    BuildContext context,
    EmployeeAssignmentModel assignment,
  ) {
    return _card(
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neutral200,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.neutral500,
              size: 27,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.siteManager,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  context.loc.manager,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () async {
              final success = await AppLauncherService.makePhoneCall(
                '+49 221 555 0192',
              );
              if (!success && context.mounted) {
                _showMessage(context, context.loc.callingContact);
              }
            },
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.infoLight,
              ),
              child: const Icon(Icons.phone_outlined, color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.key_outlined, context.loc.siteAccess),

          SizedBox(height: 13.h),

          _bullet('Entry via gate 2 on south side (code: 4821)'),
          _bullet('Unload truck only at designated loading bay.'),
          _bullet('Mandatory PPE: hard hat, harness & safety boots'),
        ],
      ),
    );
  }

  Widget _buildPhotosCard(
    BuildContext context,
    EmployeeAssignmentModel assignment,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.loc.smPhotos} (4)',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AppTextButton(
                onPressed: () => context.push(
                  RouteConstants.employeeAssignmentPhotos,
                  extra: assignment.project,
                ),
                text: '${context.loc.viewAll} →',
                foregroundColor: AppColors.textSecondary,
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(
                    RouteConstants.employeeAssignmentPhotos,
                    extra: assignment.project,
                  ),
                  child: _photoPlaceholder(Icons.business),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(
                    RouteConstants.employeeAssignmentPhotos,
                    extra: assignment.project,
                  ),
                  child: _photoPlaceholder(Icons.construction),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(
                    RouteConstants.employeeAssignmentPhotos,
                    extra: assignment.project,
                  ),
                  child: _photoPlaceholder(Icons.apartment),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksCard(
    BuildContext context,
    WidgetRef ref,
    AssignmentDetailsState state,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.loc.smTasks} (${state.tasks.length})',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 12.h),

          for (int i = 0; i < state.tasks.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _taskRow(context, ref, state.tasks[i]),
          ],
        ],
      ),
    );
  }

  Widget _taskRow(
    BuildContext context,
    WidgetRef ref,
    AssignmentTaskItem task,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(assignmentDetailsProvider.notifier).toggleTask(task.id);
      },
      child: Row(
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              color: task.isCompleted ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: task.isCompleted
                    ? AppColors.primary
                    : AppColors.neutral300,
              ),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 16.sp,
                color: task.isCompleted
                    ? AppColors.textTertiary
                    : AppColors.textSecondary,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder(IconData icon) {
    return Container(
      height: 82.h,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, size: 32, color: AppColors.neutral500),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(fontSize: 18.sp, color: AppColors.textSecondary),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.textPrimary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.textTertiary),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
          ),
        ),
      ],
    );
  }

  Widget _activityChip(EmployeeActivityType activity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: activity.backgroundColor,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        activity.label,
        style: TextStyle(
          fontSize: 15.sp,
          color: activity.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  void _showMessage(BuildContext context, String message) {
    AppSnackBar.showInfo(context, message);
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFD9E4D2);

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final smallRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: .8)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    final road1 = Path()
      ..moveTo(-20, size.height * .2)
      ..lineTo(size.width * .45, size.height * .55)
      ..lineTo(size.width + 20, size.height * .25);

    canvas.drawPath(road1, roadPaint);

    final road2 = Path()
      ..moveTo(size.width * .7, -20)
      ..lineTo(size.width * .55, size.height * .5)
      ..lineTo(size.width * .85, size.height + 20);

    canvas.drawPath(road2, smallRoadPaint);

    final blockPaint = Paint()..color = const Color(0xFFC8CDC6);

    for (int index = 0; index < 15; index++) {
      final x = (index % 5) * size.width * .2 + 5;
      final y = (index ~/ 5) * size.height * .3 + 5;

      canvas.drawRect(
        Rect.fromLTWH(x, y, size.width * .12, size.height * .12),
        blockPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
