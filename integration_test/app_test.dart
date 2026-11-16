import 'package:construction_app/app/app.dart';
import 'package:construction_app/core/enums/app_enum.dart';
import 'package:construction_app/core/enums/backend_enums.dart';
import 'package:construction_app/core/localization/app_language.dart';
import 'package:construction_app/core/localization/app_localization.dart';
import 'package:construction_app/core/storage/local_storage.dart';
import 'package:construction_app/core/storage/storage_provider.dart';
import 'package:construction_app/core/storage/storage_service.dart';
import 'package:construction_app/features/auth/domain/entities/auth_session.dart';
import 'package:construction_app/features/auth/domain/entities/auth_user.dart';
import 'package:construction_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:construction_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/test_app_wrapper.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(UserRole.employee);
  });

  testWidgets(
    'End-to-end flow: Splash -> Language -> Onboarding -> Sign In -> Role Home',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await AppLocalization.load(AppLanguage.english);

      final mockRepo = _MockAuthRepository();
      when(() => mockRepo.getCurrentUser()).thenReturn(null);
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
          accessToken: 'integration-jwt',
          user: AuthUser(
            id: 'emp-1',
            fullName: 'Tim Muler',
            email: 'tim@geruestbau.de',
            role: UserRole.employee,
            status: UserStatus.active,
            isProfileSetup: true,
          ),
        ),
      );

      final storage = StorageService(
        secureStorage: InMemorySecureStorage(),
        localStorage: LocalStorage(prefs),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            storageServiceProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const App(),
        ),
      );

      // Wait for Splash delay (1600ms) -> ChooseLanguagePage
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Choose Your Language'), findsOneWidget);

      // Language -> Onboarding
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Onboarding -> Sign In
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsWidgets);

      // Sign in as Employee
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'tim@geruestbau.de');
      await tester.enterText(fields.at(1), 'Password@123');
      await tester.tap(find.textContaining('Sign In').last);
      await tester.pumpAndSettle();

      // Verify Employee Home loaded cleanly
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Navigate to Profile tab lazily
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Contact Information'), findsOneWidget);
    },
  );
}
