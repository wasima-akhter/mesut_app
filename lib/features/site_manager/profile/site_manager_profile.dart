import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';

class SiteManagerProfile extends StatelessWidget {
  const SiteManagerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // No bottomNavigationBar.
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 30.h),
          child: Column(
            children: [
              _buildHeader(context),

              SizedBox(height: 25.h),

              _buildProfileHeader(context),

              SizedBox(height: 22.h),

              _buildStats(context),

              SizedBox(height: 14.h),

              _buildContactInformation(context),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

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
          onTap: () {
            context.push('/profile/edit');
          },
        ),
      ],
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 78.w,
              height: 78.w,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.network(
                  'https://i.pravatar.cc/300?img=12',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Container(
                      color: AppColors.border,
                      child: Icon(
                        Icons.person,
                        size: 42.sp,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),

            Positioned(
              right: 0,
              bottom: 1,
              child: Container(
                width: 27.w,
                height: 27.w,
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
          ],
        ),

        SizedBox(height: 12.h),

        Text(
          'Mesut Rahman',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 21.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        SizedBox(height: 3.h),

        Text(
          context.loc.siteManagerRole,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),

        SizedBox(height: 7.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5.w,
                height: 5.w,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),

              SizedBox(width: 5.w),

              Text(
                context.loc.inProgress,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        children: [
          _stat(context, title: context.loc.activeSites, value: '8'),

          _divider(),

          _stat(context, title: context.loc.completed, value: '34'),

          _divider(),

          _stat(context, title: context.loc.totalWorkTime, value: '38.5 h'),
        ],
      ),
    );
  }

  Widget _stat(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 10.sp,
              color: Colors.white.withValues(alpha: .55),
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 19.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 42.h,
      color: Colors.white.withValues(alpha: .15),
    );
  }

  // ============================================================
  // CONTACT INFORMATION
  // ============================================================

  Widget _buildContactInformation(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.contactInformation,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8.h),

          _contactRow(
            context,
            icon: Icons.phone_outlined,
            text: '+49 170 1234567',
          ),

          _contactRow(
            context,
            icon: Icons.mail_outline_rounded,
            text: 'tim.mueller@allround.de',
          ),

          _contactRow(
            context,
            icon: Icons.business_outlined,
            text: context.loc.smOverview,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _contactRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: AppColors.textSecondary),

              SizedBox(width: 9.w),

              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (showDivider) Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

// ============================================================
// CIRCLE BUTTON
// ============================================================

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 39.w,
          height: 39.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 19.sp, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
