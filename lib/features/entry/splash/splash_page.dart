import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/asset_constants.dart';
import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/storage/storage_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bootstrapNavigation();
      }
    });
  }

  Future<void> _bootstrapNavigation() async {
    bool isAuthenticated = false;
    bool onboardingCompleted = false;

    try {
      onboardingCompleted =
          ref.read(storageServiceProvider).onboardingCompleted;

      final results = await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 500)),
        ref
            .read(authProvider.notifier)
            .checkSession()
            .timeout(const Duration(seconds: 2), onTimeout: () => false),
      ]);

      isAuthenticated = results[1] as bool;
    } catch (e, st) {
      debugPrint('[SPLASH] Bootstrap check error: $e\n$st');
      isAuthenticated = false;
    }

    if (!mounted) return;

    if (isAuthenticated) {
      context.go(RouteConstants.mainNav);
      return;
    }

    if (onboardingCompleted) {
      context.go(RouteConstants.signIn);
    } else {
      context.go(RouteConstants.chooseLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary600,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Logo(),
                SizedBox(height: 24.h),
                Text(
                  'Workforce',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.white,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Work smarter. Stay connected.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88.r,
      height: 88.r,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Image.asset(
        AssetConstants.appLogo,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return Icon(
            Icons.business_center_rounded,
            size: 48.r,
            color: AppColors.primary600,
          );
        },
      ),
    );
  }
}
