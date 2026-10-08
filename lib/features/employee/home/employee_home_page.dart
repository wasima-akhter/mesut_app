import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/localization/context_extensions.dart';
import '../helper/employee_enums.dart';
import '../helper/employee_models.dart';
import '../presentation/providers/employee_assignment_details_provider.dart';
import '../presentation/providers/employee_timer_provider.dart';

class EmployeeHomePage extends ConsumerWidget {
  const EmployeeHomePage({super.key});

  static const List<EmployeeAssignmentModel> assignments = [
    EmployeeAssignmentModel(
      project: 'Prj-0842 . Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.erection,
      schedule: 'Start: 07:30 am',
      startTimeOfDay: TimeOfDay(hour: 7, minute: 30),
      endTimeOfDay: TimeOfDay(hour: 16, minute: 15),
      scaffoldArea: '50m²',
      siteManager: 'Mesut Rahaman',
    ),
    EmployeeAssignmentModel(
      project: 'Prj-0842 . Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.dismantling,
      schedule: 'Start: 07:30 am',
      startTimeOfDay: TimeOfDay(hour: 7, minute: 30),
      endTimeOfDay: TimeOfDay(hour: 16, minute: 15),
      scaffoldArea: '50m²',
      siteManager: 'Mesut Rahaman',
    ),
    EmployeeAssignmentModel(
      project: 'Prj-0842 . Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.erection,
      schedule: 'Start: 07:30 am',
      startTimeOfDay: TimeOfDay(hour: 7, minute: 30),
      endTimeOfDay: TimeOfDay(hour: 16, minute: 15),
      scaffoldArea: '50m²',
      siteManager: 'Mesut Rahaman',
    ),
  ];

  void _openAssignment(
    BuildContext context,
    WidgetRef ref,
    EmployeeAssignmentModel assignment,
  ) {
    ref.read(assignmentDetailsProvider.notifier).setAssignment(assignment);
    context.push(RouteConstants.employeeAssignmentDetails);
  }

  void _startNewTimer(
    BuildContext context,
    WidgetRef ref,
    EmployeeAssignmentModel assignment,
  ) {
    ref.read(assignmentDetailsProvider.notifier).setAssignment(assignment);
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
                assignment.startTimeOfDay ?? const TimeOfDay(hour: 7, minute: 30),
            endTimeOfDay:
                assignment.endTimeOfDay ?? const TimeOfDay(hour: 16, minute: 15),
            siteManager: assignment.siteManager,
          ),
          activity: assignment.activity,
        );
    context.push(RouteConstants.employeeActiveTimerPage);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 10.h),
              sliver: SliverToBoxAdapter(child: _buildHeader(context)),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildDate(context)),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 18.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildSectionHeader(context)),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    for (final assignment in assignments) ...[
                      _buildAssignmentCard(context, ref, assignment),
                      SizedBox(height: 14.h),
                    ],
                  ],
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
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
          child: const CircleAvatar(
            backgroundColor: AppColors.neutral200,
            child: Icon(Icons.person, color: AppColors.neutral500, size: 28),
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.loc.welcomeBack,
                style: TextStyle(
                  fontSize: 17.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Mesut',
                style: TextStyle(
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () {
            context.push(RouteConstants.notifications);
          },
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 25,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDate(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: Text(
        DateTime.now().formatLocalized(style: 'weekday_full'),
        style: TextStyle(
          fontSize: 17.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.loc.upcomingTasks,
            style: TextStyle(
              fontSize: 23.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '${assignments.length} ${context.loc.smTasks}',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    WidgetRef ref,
    EmployeeAssignmentModel assignment,
  ) {
    final activity = assignment.activity;

    return GestureDetector(
      onTap: () => _openAssignment(context, ref, assignment),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _activityChip(activity),

                const Spacer(),

                Text(
                  assignment.formattedSchedule,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 15.h),

            Text(
              assignment.project,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 7.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    assignment.address,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            Text(
              '${context.loc.manager}: ${assignment.siteManager}',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
            ),

            SizedBox(height: 14.h),

            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showNavigationMessage(context, assignment.address);
                    },
                    icon: const Icon(Icons.directions_outlined, size: 21),
                    label: Text(
                      context.loc.navigation,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                Expanded(
                  flex: 5,
                  child: AppButton(
                    onPressed: () => _startNewTimer(context, ref, assignment),
                    text: context.loc.startNewTimer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNavigationMessage(BuildContext context, String address) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${context.loc.navigation}: $address',
            style: TextStyle(fontSize: 16.sp),
          ),
          behavior: SnackBarBehavior.floating,
        ),
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
}
