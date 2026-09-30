import 'package:construction_app/features/auth/change_password/change_password_page.dart';
import 'package:construction_app/features/auth/forgot_password/forgot_password_page.dart';
import 'package:construction_app/features/auth/otp/otp_page.dart';
import 'package:construction_app/features/auth/sign_in/sign_in_page.dart';
import 'package:construction_app/features/auth/sign_up/sign_up_page.dart';
import 'package:construction_app/features/entry/splash/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/snack/app_snackbar.dart';
import '../../features/entry/nav/navigation_page.dart';
import '../../features/entry/onboarding/onboarding_page.dart';
import '../../features/site_manager/projects/create_project_modules.dart';
import '../../features/site_manager/projects/site_manager_project_details_screen.dart';
import '../constants/route_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: RouteConstants.splash,
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) {
          return const SplashPage();
        },
      ),

      GoRoute(
        path: RouteConstants.onboarding,
        builder: (context, state) {
          return const OnboardingPage();
        },
      ),

      GoRoute(
        path: RouteConstants.signIn,
        builder: (context, state) {
          return const SignInScreen();
        },
      ),
      GoRoute(
        path: RouteConstants.signUp,
        builder: (context, state) {
          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        builder: (context, state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: RouteConstants.otp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return OtpVerifyScreen(
            email: extra['email'] as String,
            purpose: extra['purpose'] as OtpPurpose? ?? OtpPurpose.signUp,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.changePassword,
        builder: (context, state) {
          return const ChangePasswordScreen(email: "email");
        },
      ),

      //
      GoRoute(
        path: RouteConstants.mainNav,
        builder: (context, state) {
          return const NavigationPage();
        },
      ),

      // Site Manager Indiv screens ---
      GoRoute(
        path: RouteConstants.siteManagerProjectDetail,
        builder: (context, state) {
          final extra = state.extra as String?;
          return ProjectDetailsScreen(projectId: extra ?? '');
        },
      ),
      GoRoute(
        path: RouteConstants.siteManagerCreateproject,
        builder: (context, state) {
          return NewProjectPage();
        },
      ),
    ],
  );
});
