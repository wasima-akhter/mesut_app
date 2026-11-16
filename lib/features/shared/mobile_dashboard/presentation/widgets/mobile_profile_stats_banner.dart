import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../providers/mobile_dashboard_provider.dart';

class MobileProfileStatsBanner extends ConsumerWidget {
  const MobileProfileStatsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);
    final profile = ref.watch(mobileProfileProvider).asData?.value;

    final assigned = '${profile?.assignedProjectsCount ?? 0}';
    final completed = '${profile?.completedProjectsCount ?? 0}';
    final hours = '${(profile?.hoursThisWeek ?? 0).toStringAsFixed(1)}h';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          _StatItem(title: context.loc.assignedProjects, value: assigned),
          _divider(),
          _StatItem(title: context.loc.completedProjects, value: completed),
          _divider(),
          _StatItem(title: context.loc.hoursThisWeek, value: hours),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36.h,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
