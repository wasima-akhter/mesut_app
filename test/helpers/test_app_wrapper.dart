import 'package:construction_app/app/theme/app_text_styles.dart';
import 'package:construction_app/app/theme/app_theme.dart';
import 'package:construction_app/core/localization/app_language.dart';
import 'package:construction_app/core/localization/app_localization.dart';
import 'package:construction_app/core/storage/local_storage.dart';
import 'package:construction_app/core/storage/secure_storage.dart';
import 'package:construction_app/core/storage/storage_provider.dart';
import 'package:construction_app/core/storage/storage_service.dart';
import 'package:construction_app/core/widgets/snack/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory SecureStorage double for unit & widget tests (no platform channel).
class InMemorySecureStorage extends SecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      _store.containsKey(key);
}

Future<StorageService> createTestStorageService([
  Map<String, Object> initialPrefs = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();
  return StorageService(
    secureStorage: InMemorySecureStorage(),
    localStorage: LocalStorage(prefs),
  );
}

Future<void> pumpTestWidget(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const [],
  AppLanguage language = AppLanguage.english,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await AppLocalization.load(language);

  final storage = StorageService(
    secureStorage: InMemorySecureStorage(),
    localStorage: LocalStorage(prefs),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        storageServiceProvider.overrideWithValue(storage),
        ...overrides,
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        builder: (_, _) {
          final theme = AppTheme.light;
          AppTextStyles.initialize(theme.textTheme);
          return MaterialApp(
            navigatorKey: appNavigatorKey,
            theme: theme,
            locale: language.locale,
            supportedLocales: AppLocalization.supportedLocales,
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: child,
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}
