import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/images/app_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';

class SiteManagerProfileCard extends ConsumerWidget {
  const SiteManagerProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(mobileProfileProvider).asData?.value;
    final currentUser = ref.watch(currentUserProvider);
    final fullName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (currentUser?.fullName ?? '');
    final avatarUrl = profile?.avatarUrl ?? currentUser?.avatarUrl;

    return GestureDetector(
      onTap: () => context.push(RouteConstants.siteManagerProfileEdit),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.medium,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neutral200,
              ),
              child: ClipOval(
                child: AppNetworkImage(
                  imageUrl: avatarUrl,
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                  fallback: _fallbackIcon(),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isNotEmpty ? fullName : context.loc.siteManagerRole,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context.loc.siteManagerRole,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: AppColors.border,
      child: Icon(
        Icons.person,
        color: AppColors.textSecondary,
        size: 25.sp,
      ),
    );
  }
}
