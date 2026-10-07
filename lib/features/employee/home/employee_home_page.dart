// EmployeeHomePage

import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../helper/employee_enums.dart';
import '../helper/employee_models.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  bool notificationsEnabled = false;

  final List<EmployeeAssignmentModel> assignments = const [
    EmployeeAssignmentModel(
      project: 'Prj-0842 . Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.erection,
      schedule: 'Start: 07:30 am',
      scaffoldArea: '50m²',
      siteManager: 'Mesut Rahaman',
    ),
    EmployeeAssignmentModel(
      project: 'Prj-0842 . Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.dismantling,
      schedule: 'Start: 07:30 am',
      scaffoldArea: '50m²',
      siteManager: 'Mesut Rahaman',
    ),
    EmployeeAssignmentModel(
      project: 'Prj-0842 . Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.erection,
      schedule: 'Start: 07:30 am',
      scaffoldArea: '50m²',
      siteManager: 'Mesut Rahaman',
    ),
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontSize: 17.sp)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openAssignment(EmployeeAssignmentModel assignment) {
    context.push(RouteConstants.employeeAssignmentDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 10.h),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildDate()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 18.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildSectionHeader()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    for (final assignment in assignments) ...[
                      _buildAssignmentCard(assignment),
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

  Widget _buildHeader() {
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
            context.push(RouteConstants.siteManagerProfileEdit);
          },
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              notificationsEnabled
                  ? Icons.notifications
                  : Icons.notifications_none_outlined,
              size: 25,
              color: notificationsEnabled
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDate() {
    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: Text(
        'Friday, September 18',
        style: TextStyle(
          fontSize: 17.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
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

  Widget _buildAssignmentCard(EmployeeAssignmentModel assignment) {
    final activity = assignment.activity;

    return GestureDetector(
      onTap: () => _openAssignment(assignment),
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
                  assignment.schedule,
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
                  flex: 4,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.directions_outlined, size: 21),
                    label: Text(
                      context.loc.startNavigation,
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
                    onPressed: () => _openAssignment(assignment),
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
