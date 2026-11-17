import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../shared/mobile_dashboard/domain/entities/mobile_profile_entity.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../shared/mobile_dashboard/presentation/widgets/mobile_profile_stats_banner.dart';
import 'widgets/site_manager_contact_card.dart';

class SiteManagerProfile extends ConsumerWidget {
  const SiteManagerProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(mobileProfileProvider).asData?.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
          child: Column(
            children: [
              _buildHeader(context),
              SizedBox(height: 22.h),
              _buildProfileHeader(context, profile),
              SizedBox(height: 20.h),
              const MobileProfileStatsBanner(),
              SizedBox(height: 16.h),
              SiteManagerContactCard(
                phone: profile?.phone ?? '',
                email: profile?.email ?? '',
                language: profile?.language ?? 'DE',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
        Expanded(
          child: Center(
            child: Text(
              context.loc.profile,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ),
        _CircleButton(
          icon: Icons.edit_outlined,
          onTap: () => context.push(RouteConstants.siteManagerProfileEdit),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    MobileProfileEntity? profile,
  ) {
    final avatarUrl = profile?.avatarUrl;
    final fullName = profile?.fullName ?? '';

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 82.w,
              height: 82.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neutral200,
                border: Border.all(color: AppColors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _fallbackAvatar(),
                      )
                    : _fallbackAvatar(),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 1,
              child: GestureDetector(
                onTap: () => context.push(RouteConstants.siteManagerProfileEdit),
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          fullName.isNotEmpty ? fullName : context.loc.siteManagerRole,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        SizedBox(height: 3.h),
        Text(
          context.loc.siteManagerRole,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: AppColors.border,
      child: Icon(
        Icons.person,
        size: 46.sp,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
      ),
    );
  }
}
