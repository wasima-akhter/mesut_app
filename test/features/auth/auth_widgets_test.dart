import 'package:construction_app/core/enums/app_enum.dart';
import 'package:construction_app/core/providers/common_provider.dart';
import 'package:construction_app/core/widgets/fields/app_phone_field.dart';
import 'package:construction_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:construction_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:construction_app/features/auth/presentation/screens/sign_in_page.dart';
import 'package:construction_app/features/auth/presentation/screens/sign_up_page.dart';
import 'package:construction_app/features/site_manager/profile/site_manager_edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_app_wrapper.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserRole.employee);
  });

  group('SignInScreen Widget Tests', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
      when(() => mockRepo.getCurrentUser()).thenReturn(null);
    });

    testWidgets('shows validation snackbar when submitting empty email', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: const SignInScreen(),
      );

      final signInBtn = find.textContaining('Sign In').last;
      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('remember me toggle updates state and submits signIn', (
      tester,
    ) async {
      when(
        () => mockRepo.login(
          email: 'mesut@geruestbau.de',
          password: 'Password@1',
          role: UserRole.employee,
          deviceIdentifier: any(named: 'deviceIdentifier'),
          rememberMe: true,
          fcmToken: any(named: 'fcmToken'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
        ),
      ).thenThrow(Exception('Invalid credentials'));

      await pumpTestWidget(
        tester,
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: const SignInScreen(),
      );

      final rememberMeFinder = find.text('Remember me');
      await tester.ensureVisible(rememberMeFinder);
      await tester.tap(rememberMeFinder);
      await tester.pump();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'mesut@geruestbau.de');
      await tester.enterText(textFields.at(1), 'Password@1');

      final signInBtn = find.textContaining('Sign In').last;
      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);
      await tester.pump();

      verify(
        () => mockRepo.login(
          email: 'mesut@geruestbau.de',
          password: 'Password@1',
          role: UserRole.employee,
          deviceIdentifier: any(named: 'deviceIdentifier'),
          rememberMe: true,
          fcmToken: any(named: 'fcmToken'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
        ),
      ).called(1);
    });
  });

  group('SignUpScreen Phone Validation Widget Tests', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
      when(() => mockRepo.getCurrentUser()).thenReturn(null);
    });

    testWidgets('renders AppPhoneField and rejects invalid short phone', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: const SignUpScreen(),
      );

      expect(find.byType(AppPhoneField), findsOneWidget);
      expect(find.byType(IntlPhoneField), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'John');
      await tester.enterText(textFields.at(1), 'Doe');
      await tester.enterText(textFields.at(2), '123'); // Invalid short phone
      await tester.enterText(textFields.at(3), 'john@geruestbau.de');
      await tester.enterText(textFields.at(4), 'SecretP@ss1');
      await tester.enterText(textFields.at(5), 'SecretP@ss1');

      final createBtn = find.textContaining('Create Account').last;
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await tester.pump();

      // Localized phone length validation message appears
      expect(find.textContaining('at least'), findsWidgets);
      verifyNever(
        () => mockRepo.signUp(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          password: any(named: 'password'),
          role: any(named: 'role'),
        ),
      );
    });

    testWidgets('selects Site Manager role and formats phone for signUp', (
      tester,
    ) async {
      when(
        () => mockRepo.signUp(
          firstName: 'Mesut',
          lastName: 'Gundogdu',
          email: 'mesut@geruestbau.de',
          phone: '+491701234567',
          password: 'SecretP@ss1',
          role: UserRole.siteManager,
        ),
      ).thenThrow(Exception('Stop navigation in unit test'));

      await pumpTestWidget(
        tester,
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: const SignUpScreen(),
      );

      await tester.tap(find.text('Site Manager'));
      await tester.pump();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Mesut');
      await tester.enterText(textFields.at(1), 'Gundogdu');
      await tester.enterText(textFields.at(2), '1701234567');
      await tester.enterText(textFields.at(3), 'mesut@geruestbau.de');
      await tester.enterText(textFields.at(4), 'SecretP@ss1');
      await tester.enterText(textFields.at(5), 'SecretP@ss1');

      final createBtn = find.textContaining('Create Account').last;
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await tester.pump();

      verify(
        () => mockRepo.signUp(
          firstName: 'Mesut',
          lastName: 'Gundogdu',
          email: 'mesut@geruestbau.de',
          phone: '+491701234567',
          password: 'SecretP@ss1',
          role: UserRole.siteManager,
        ),
      ).called(1);
    });
  });

  group('EditProfilePage Phone Selector Widget Tests', () {
    testWidgets('loads parsed employee phone and validates repeating digits', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        overrides: [
          userRoleProvider.overrideWith(
            () => _FixedRoleNotifier(UserRole.employee),
          ),
        ],
        child: const EditProfilePage(),
      );

      expect(find.byType(AppPhoneField), findsOneWidget);
      // Pre-populated employee national phone number from +49 170 1234567
      expect(find.text('1701234567'), findsOneWidget);

      // Replace phone with invalid repeating digits
      final phoneInput = find.descendant(
        of: find.byType(IntlPhoneField),
        matching: find.byType(TextField),
      );
      await tester.enterText(phoneInput, '000000000');
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(
        find.text('Please enter a realistic phone number'),
        findsWidgets,
      );
    });
  });
}

class _FixedRoleNotifier extends UserRoleNotifier {
  _FixedRoleNotifier(this.initialRole);
  final UserRole initialRole;

  @override
  UserRole? build() => initialRole;
}
