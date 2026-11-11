import 'package:construction_app/features/auth/presentation/screens/forgot_password_page.dart';
import 'package:construction_app/features/auth/presentation/screens/otp_page.dart';
import 'package:construction_app/features/auth/presentation/screens/reset_password_page.dart';
import 'package:construction_app/features/auth/presentation/screens/sign_in_page.dart';
import 'package:construction_app/features/auth/presentation/screens/sign_up_page.dart';
import 'package:construction_app/features/employee/assignments/employee_assignment_detail_page.dart';
import 'package:construction_app/features/employee/assignments/employee_assignment_photos_page.dart';
import 'package:construction_app/features/employee/timer/active_timer_page.dart';
import 'package:construction_app/features/entry/splash/splash_page.dart';
import 'package:construction_app/features/site_manager/profile/site_manager_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_manager.dart';
import '../../core/widgets/snack/app_snackbar.dart';
import '../../features/entry/language_selection/choose_language_page.dart';
import '../../features/entry/nav/navigation_page.dart';
import '../../features/entry/onboarding/onboarding_page.dart';
import '../../features/shared/change_password/change_password_page.dart';
import '../../features/shared/legal/privacy_policy.dart';
import '../../features/shared/legal/terms_conditions.dart';
import '../../features/shared/notifications/notifications_page.dart';
import '../../features/map/domain/entities/map_request_entity.dart';
import '../../features/map/presentation/screens/central_map_screen.dart';
import '../../features/site_manager/inspection_pages/inspection_calender_page.dart';
import '../../features/site_manager/inspection_pages/inspection_photos_view_all_page.dart';
import '../../features/site_manager/inspection_pages/inspection_survey_page.dart';
import '../../features/site_manager/inspection_pages/site_manager_inspections_page.dart';
import '../../features/site_manager/phase_board/site_manager_phase_board.dart';
import '../../features/site_manager/profile/site_manager_edit_profile.dart';
import '../../features/site_manager/projects/create_project_modules.dart';
import '../../features/site_manager/projects/site_manager_project_details_screen.dart';
import '../constants/route_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
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
        path: RouteConstants.chooseLanguage,
        builder: (context, state) {
          return const ChooseLanguagePage();
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
          final extra = state.extra as Map<String, dynamic>? ?? const {};

          return OtpVerifyScreen(
            email: extra['email'] as String? ?? '',
            purpose: extra['purpose'] as OtpPurpose? ?? OtpPurpose.signUp,
            otpPageToken: extra['otpPageToken'] as String?,
            recoveryToken: extra['recoveryToken'] as String?,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return ResetPasswordScreen(
            email: extra['email'] as String? ?? '',
            recoveryToken: extra['recoveryToken'] as String?,
          );
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
      GoRoute(
        path: RouteConstants.changePassword,
        builder: (context, state) {
          return ChangePasswordPage();
        },
      ),
      GoRoute(
        path: RouteConstants.siteManagerPhaseBoard,
        builder: (context, state) {
          return SiteManagerPhaseBoardPage();
        },
      ),
      GoRoute(
        path: RouteConstants.siteManagerSiteInspection,
        builder: (context, state) {
          return SiteInspectionPage();
        },
      ),
      GoRoute(
        path: RouteConstants.siteManagerInspectionSurveyPage,
        builder: (context, state) {
          return InspectionSurveyPage();
        },
      ),
      GoRoute(
        path: RouteConstants.siteManagerInspectionPhotos,
        builder: (context, state) {
          return const InspectionPhotosViewAllPage();
        },
      ),
      GoRoute(
        path: RouteConstants.siteManagerInspectionCalendarPage,
        builder: (context, state) {
          return InspectionCalendarPage();
        },
      ),
      GoRoute(
        path: RouteConstants.siteManagerProfile,
        builder: (context, state) {
          return SiteManagerProfile();
        },
      ),

      GoRoute(
        path: RouteConstants.siteManagerProfileEdit,
        builder: (context, state) {
          return const EditProfilePage();
        },
      ),

      // Employee
      GoRoute(
        path: RouteConstants.employeeAssignmentDetails,
        builder: (context, state) {
          return const AssignmentDetailsPage();
        },
      ),
      GoRoute(
        path: RouteConstants.employeeAssignmentPhotos,
        builder: (context, state) {
          final assignmentTitle = state.extra as String?;
          return EmployeeAssignmentPhotosPage(
            assignmentTitle: assignmentTitle,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.employeeActiveTimerPage,
        builder: (context, state) {
          return const ActiveTimerPage();
        },
      ),

      GoRoute(
        path: RouteConstants.privacyPolicy,
        builder: (context, state) {
          return const PrivacyPolicyPage();
        },
      ),

      GoRoute(
        path: RouteConstants.termsAndConditions,
        builder: (context, state) {
          return const TermsAndConditionsPage();
        },
      ),
      GoRoute(
        path: RouteConstants.notifications,
        builder: (context, state) {
          return const NotificationsPage();
        },
      ),
      GoRoute(
        path: RouteConstants.map,
        builder: (context, state) {
          final request = state.extra as MapRequestEntity?;
          return CentralMapScreen(initialRequest: request);
        },
      ),
    ],
  );
  ref.read(sessionManagerProvider).attachRouter(router);
  return router;
});
