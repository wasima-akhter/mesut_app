import 'package:construction_app/core/enums/app_enum.dart';
import 'package:construction_app/core/enums/backend_enums.dart';
import 'package:construction_app/core/providers/common_provider.dart';
import 'package:construction_app/core/storage/storage_provider.dart';
import 'package:construction_app/features/auth/domain/entities/auth_session.dart';
import 'package:construction_app/features/auth/domain/entities/auth_user.dart';
import 'package:construction_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:construction_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:construction_app/features/auth/presentation/providers/otp_provider.dart';
import 'package:construction_app/features/auth/presentation/screens/otp_page.dart';
import 'package:construction_app/features/employee/presentation/providers/employee_timer_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_app_wrapper.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserRole.employee);
  });

  group('AuthNotifier Unit Tests', () {
    late MockAuthRepository mockRepo;
    late ProviderContainer container;

    setUp(() async {
      mockRepo = MockAuthRepository();
      when(() => mockRepo.getCurrentUser()).thenReturn(null);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await createTestStorageService();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          storageServiceProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);
    });

    test('signIn authenticates active user and updates userRoleProvider', () async {
      const user = AuthUser(
        id: 'u-1',
        fullName: 'Max Mustermann',
        email: 'max@geruestbau.de',
        role: UserRole.siteManager,
        status: UserStatus.active,
        isProfileSetup: true,
      );

      when(
        () => mockRepo.login(
          email: 'max@geruestbau.de',
          password: 'Password@123',
          role: UserRole.siteManager,
          deviceIdentifier: any(named: 'deviceIdentifier'),
          rememberMe: false,
          fcmToken: any(named: 'fcmToken'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
        ),
      ).thenAnswer(
        (_) async => const AuthSession(accessToken: 'jwt-token', user: user),
      );

      final outcome = await container.read(authProvider.notifier).signIn(
        email: 'max@geruestbau.de',
        password: 'Password@123',
        role: UserRole.siteManager,
      );

      expect(outcome, LoginOutcome.authenticated);
      expect(container.read(authProvider).status, AuthStatus.authenticated);
      expect(container.read(userRoleProvider), UserRole.siteManager);
    });

    test('signIn triggers OTP verification when user status is INACTIVE', () async {
      const inactiveUser = AuthUser(
        id: 'u-2',
        fullName: 'New Employee',
        email: 'new@geruestbau.de',
        role: UserRole.employee,
        status: UserStatus.inactive,
      );

      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
          deviceIdentifier: any(named: 'deviceIdentifier'),
          rememberMe: any(named: 'rememberMe'),
          fcmToken: any(named: 'fcmToken'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
        ),
      ).thenAnswer(
        (_) async => const AuthSession(
          accessToken: 'temp-otp-token',
          user: inactiveUser,
        ),
      );
      when(() => mockRepo.resendOtp(otpPageToken: any(named: 'otpPageToken')))
          .thenAnswer((_) async {});

      final outcome = await container.read(authProvider.notifier).signIn(
        email: 'new@geruestbau.de',
        password: 'Password@123',
        role: UserRole.employee,
      );

      expect(outcome, LoginOutcome.otpVerificationRequired);
      expect(container.read(authProvider).status, AuthStatus.otpPending);
    });

    test('signIn returns suspended when user status is SUSPENDED', () async {
      const suspendedUser = AuthUser(
        id: 'u-3',
        fullName: 'Suspended User',
        email: 'susp@geruestbau.de',
        role: UserRole.employee,
        status: UserStatus.suspended,
      );

      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
          deviceIdentifier: any(named: 'deviceIdentifier'),
          rememberMe: any(named: 'rememberMe'),
          fcmToken: any(named: 'fcmToken'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
        ),
      ).thenAnswer(
        (_) async => const AuthSession(
          accessToken: 'token',
          user: suspendedUser,
        ),
      );

      final outcome = await container.read(authProvider.notifier).signIn(
        email: 'susp@geruestbau.de',
        password: 'Password@123',
        role: UserRole.employee,
      );

      expect(outcome, LoginOutcome.suspended);
      expect(container.read(authProvider).status, AuthStatus.suspended);
    });

    test('signUp stores otpPageToken and transitions to otpPending', () async {
      when(
        () => mockRepo.signUp(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@geruestbau.de',
          phone: '+491701234567',
          password: 'Password@123',
          role: UserRole.employee,
        ),
      ).thenAnswer((_) async => 'otp-page-token-xyz');

      final token = await container.read(authProvider.notifier).signUp(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@geruestbau.de',
        phone: '+491701234567',
        password: 'Password@123',
        role: UserRole.employee,
      );

      expect(token, 'otp-page-token-xyz');
      expect(container.read(authProvider).status, AuthStatus.otpPending);
    });

    test('logout resets authProvider and clears userRoleProvider', () async {
      when(() => mockRepo.logout()).thenAnswer((_) async {});
      container.read(userRoleProvider.notifier).setRole(UserRole.siteManager);

      await container.read(authProvider.notifier).logout();

      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      expect(container.read(userRoleProvider), isNull);
    });

    test('OtpController rejects incomplete OTP codes (< 6 digits)', () async {
      container.read(otpControllerProvider.notifier).updateOtp('123');
      final ok = await container
          .read(otpControllerProvider.notifier)
          .verifyOtp(OtpPurpose.signUp);

      expect(ok, isFalse);
    });
  });

  group('EmployeeTimerNotifier Timestamp Accuracy Tests', () {
    test('start, pause, resume, and finish lifecycle updates cleanly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(employeeTimerProvider.notifier);
      notifier.startTimer();
      expect(container.read(employeeTimerProvider).isTimerRunning, isTrue);
      expect(container.read(employeeTimerProvider).isOnBreak, isFalse);

      notifier.pauseTimer();
      expect(container.read(employeeTimerProvider).isOnBreak, isTrue);

      notifier.resumeTimer();
      expect(container.read(employeeTimerProvider).isOnBreak, isFalse);

      notifier.finishTimer();
      expect(container.read(employeeTimerProvider).isTimerRunning, isFalse);
      expect(container.read(employeeTimerProvider).elapsed, Duration.zero);
    });
  });
}
