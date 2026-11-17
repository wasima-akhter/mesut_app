import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import 'package:construction_app/core/widgets/snack/app_snackbar.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../auth/presentation/widgets/logout_dialog.dart';
import '../../../../auth/presentation/widgets/logout_loading_overlay.dart';
import '../../../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../../../shared/mobile_dashboard/presentation/widgets/mobile_profile_stats_banner.dart';
import '../widgets/employee_contact_card.dart';
import '../widgets/employee_legal_card.dart';
import '../widgets/employee_profile_header.dart';
import '../widgets/employee_settings_card.dart';

class EmployeeProfilePage extends ConsumerStatefulWidget {
  const EmployeeProfilePage({super.key});

  @override
  ConsumerState<EmployeeProfilePage> createState() =>
      _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends ConsumerState<EmployeeProfilePage> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(mobileProfileProvider).asData?.value;
    final phone = profile?.phone ?? '';
    final email = profile?.email ?? '';
    final language = (profile?.language ?? 'DE').toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(mobileProfileProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 0),
                    sliver: SliverToBoxAdapter(
                      child: EmployeeProfileHeader(profile: profile),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    sliver: const SliverToBoxAdapter(
                      child: MobileProfileStatsBanner(),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 14.h)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    sliver: SliverToBoxAdapter(
                      child: EmployeeContactCard(
                        phone: phone,
                        email: email,
                        language: language,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 14.h)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    sliver: const SliverToBoxAdapter(
                      child: EmployeeSettingsCard(),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 14.h)),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const EmployeeLegalCard(),
                          SizedBox(height: 14.h),
                          AppOutlinedButton(
                            fullWidth: true,
                            isLoading: _isLoggingOut,
                            onPressed: _isLoggingOut ? null : _logout,
                            leadingIcon: Icons.logout,
                            text: context.loc.logout,
                            foregroundColor: AppColors.primary,
                            borderColor: AppColors.primary,
                            borderRadius: 7.r,
                            textStyle: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoggingOut) const LogoutLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  void _logout() {
    LogoutConfirmation.show(
      context: context,
      onLogout: () async {
        setState(() => _isLoggingOut = true);
        try {
          await ref.read(authProvider.notifier).logout();
          if (mounted) {
            AppSnackBar.success(context.loc.loggedOutSuccess);
            context.go(RouteConstants.signIn);
          }
        } catch (_) {
          if (mounted) {
            setState(() => _isLoggingOut = false);
          }
        }
      },
    );
  }
}
