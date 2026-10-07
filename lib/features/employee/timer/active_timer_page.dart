import 'dart:async';

import 'package:construction_app/features/employee/helper/employee_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../helper/employee_enums.dart';

class ActiveTimerPage extends StatefulWidget {
  const ActiveTimerPage({super.key});

  @override
  State<ActiveTimerPage> createState() => _ActiveTimerPageState();
}

class _ActiveTimerPageState extends State<ActiveTimerPage> {
  final assignment = fakeAssignments.last;
  Timer? _timer;

  Duration elapsed = const Duration(hours: 2, minutes: 45, seconds: 20);

  Duration breakTime = Duration.zero;

  bool isOnBreak = false;

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || isOnBreak) {
        return;
      }

      setState(() {
        elapsed += const Duration(seconds: 1);
      });
    });
  }

  void _toggleBreak() {
    setState(() {
      isOnBreak = !isOnBreak;
    });

    if (isOnBreak) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  void _finishWork() {
    _timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _FinishWorkDialog(
          projectName: assignment.project,
          totalTime: _formatDuration(elapsed),
          onSave: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.loc.entrySaved,
                  style: TextStyle(fontSize: 17.sp),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
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
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildAssignmentCard()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildTimerCard()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 25.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back, size: 23),
          ),
        ),

        SizedBox(width: 14.w),

        Expanded(
          child: Text(
            context.loc.activeTimer,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        _statusBadge(),
      ],
    );
  }

  Widget _statusBadge() {
    final color = isOnBreak ? AppColors.warning : AppColors.success;

    final background = isOnBreak
        ? AppColors.warningLight
        : AppColors.successLight;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            isOnBreak ? context.loc.pauseBreak : context.loc.inProgress,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: assignment.activity.backgroundColor,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              assignment.activity.label,
              style: TextStyle(
                fontSize: 15.sp,
                color: assignment.activity.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 13.h),

          Text(
            assignment.project,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 8.h),

          Row(
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
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: isOnBreak ? const Color(0xFFFFF7E8) : AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(
          color: isOnBreak ? const Color(0xFFF9D89A) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 4.h),

          Text(
            _formatDuration(elapsed),
            style: TextStyle(
              fontSize: 44.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: isOnBreak ? const Color(0xFFC47A0A) : AppColors.success,
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            'Started today at 07:30 am',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
          ),

          SizedBox(height: 5.h),

          Text(
            '${context.loc.breakTime}: ${_formatDuration(breakTime)}',
            style: TextStyle(
              fontSize: 16.sp,
              color: isOnBreak ? AppColors.warningDark : AppColors.textTertiary,
            ),
          ),

          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleBreak,
                  icon: Icon(
                    isOnBreak ? Icons.play_arrow : Icons.pause,
                    size: 22,
                  ),
                  label: Text(
                    isOnBreak ? context.loc.resumeWork : context.loc.pauseBreak,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isOnBreak
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    side: BorderSide(
                      color: isOnBreak
                          ? AppColors.primary
                          : AppColors.borderDark,
                    ),
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: AppButton(
                  onPressed: _finishWork,
                  height: 48.h,
                  text: context.loc.finishWork,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinishWorkDialog extends StatelessWidget {
  final String projectName;
  final String totalTime;
  final VoidCallback onSave;

  const _FinishWorkDialog({
    required this.projectName,
    required this.totalTime,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 18.h),

            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.info,
                size: 30,
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              '${context.loc.finishWork} $projectName?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              '${context.loc.totalHoursLogged}: $totalTime',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
            ),

            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: onSave,
                height: 48.h,
                text: context.loc.saveEntry,
              ),
            ),

            SizedBox(height: 5.h),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.loc.cancel,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
