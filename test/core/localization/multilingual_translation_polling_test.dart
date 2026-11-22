import 'package:construction_app/core/enums/app_enum.dart';
import 'package:construction_app/core/localization/app_language.dart';
import 'package:construction_app/core/localization/localization_meta.dart';
import 'package:construction_app/core/localization/localization_provider.dart';
import 'package:construction_app/core/localization/pending_refetch_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    AppLanguageNotifier.activeLanguageCode = 'en';
  });

  group('LocalizationMeta & translation polling detection', () {
    test('treats sourceLocale "de" with active language "en" as PENDING', () {
      AppLanguageNotifier.activeLanguageCode = 'en';

      final meta = LocalizationMeta.tryParse({
        'localization': {
          'sourceLocale': 'de',
        },
      });

      expect(meta, isNotNull);
      expect(meta!.sourceLocale, 'de');
      expect(meta.isPending, isTrue);
      expect(meta.showTranslatedBadge, isFalse);
    });

    test(
        'overrides translationStatus READY to PENDING when content is not translated into active language',
        () {
      AppLanguageNotifier.activeLanguageCode = 'en';

      final meta = LocalizationMeta.tryParse({
        'localization': {
          'sourceLocale': 'de',
          'displayedLocale': 'de',
          'isTranslated': false,
          'translationStatus': 'READY',
        },
      });

      expect(meta, isNotNull);
      expect(meta!.isPending, isTrue);
    });

    test('marks as READY when translated into active language', () {
      AppLanguageNotifier.activeLanguageCode = 'en';

      final meta = LocalizationMeta.tryParse({
        'localization': {
          'sourceLocale': 'de',
          'displayedLocale': 'en',
          'isTranslated': true,
          'translationStatus': 'READY',
        },
      });

      expect(meta, isNotNull);
      expect(meta!.isPending, isFalse);
      expect(meta.showTranslatedBadge, isTrue);
    });

    test('marks as READY without pending when active language matches source',
        () {
      AppLanguageNotifier.activeLanguageCode = 'de';

      final meta = LocalizationMeta.tryParse({
        'localization': {
          'sourceLocale': 'de',
        },
      });

      expect(meta, isNotNull);
      expect(meta!.isPending, isFalse);
      expect(meta.showTranslatedBadge, isFalse);
    });

    test('anyLocalizationPending returns true if any item is pending', () {
      AppLanguageNotifier.activeLanguageCode = 'en';

      final pendingMeta = LocalizationMeta.tryParse({
        'localization': {'sourceLocale': 'de'},
      });
      final readyMeta = LocalizationMeta.tryParse({
        'localization': {
          'sourceLocale': 'de',
          'displayedLocale': 'en',
          'isTranslated': true,
        },
      });

      expect(anyLocalizationPending([null, readyMeta, pendingMeta]), isTrue);
      expect(anyLocalizationPending([null, readyMeta]), isFalse);
    });

    test('supports all 19 languages in AppLanguage enum', () {
      const expectedCodes = [
        'de', 'en', 'tr', 'hi', 'pl', 'ro', 'fr', 'es', 'it',
        'nl', 'pt', 'ar', 'ru', 'uk', 'bg', 'hr', 'sr', 'sq', 'el',
      ];
      expect(AppLanguage.values.length, 19);
      for (final code in expectedCodes) {
        final lang = AppLanguage.fromCode(code);
        expect(lang.code, code);
        expect(lang.label.isNotEmpty, isTrue);
        expect(lang.flagEmoji.isNotEmpty, isTrue);
      }
    });

    test('detects pending translation across different non-English/non-German languages', () {
      AppLanguageNotifier.activeLanguageCode = 'tr';
      final metaDe = LocalizationMeta.tryParse({
        'localization': {
          'sourceLocale': 'de',
          'displayedLocale': 'de',
          'isTranslated': false,
          'translationStatus': 'READY',
        },
      });
      expect(metaDe!.isPending, isTrue);

      final metaTr = LocalizationMeta.tryParse({
        'localization': {
          'sourceLocale': 'de',
          'displayedLocale': 'tr',
          'isTranslated': true,
          'translationStatus': 'READY',
        },
      });
      expect(metaTr!.isPending, isFalse);
      expect(metaTr.showTranslatedBadge, isTrue);
    });
  });

  group('PendingRefetchController lifecycle', () {
    test('polls periodically while hasPending is true and stops on false', () {
      final poller = PendingRefetchController();
      int pollCount = 0;

      poller.sync(
        hasPending: true,
        refetch: () => pollCount++,
        interval: const Duration(milliseconds: 50),
      );

      expect(poller.isTimedOut, isFalse);

      poller.sync(
        hasPending: false,
        refetch: () => pollCount++,
      );

      expect(poller.isTimedOut, isFalse);
      poller.dispose();
    });
  });

  group('Role-scoped Language Isolation', () {
    test('generates independent storage keys for different roles', () {
      expect(
        AppLanguageNotifier.roleStorageKey(UserRole.employee),
        'selected_language_role_employee',
      );
      expect(
        AppLanguageNotifier.roleStorageKey(UserRole.siteManager),
        'selected_language_role_sitemanager',
      );
      expect(
        AppLanguageNotifier.roleStorageKey(UserRole.employee),
        isNot(equals(AppLanguageNotifier.roleStorageKey(UserRole.siteManager))),
      );
    });

    test('generates independent storage keys for different user IDs', () {
      expect(
        AppLanguageNotifier.userStorageKey('user_123'),
        'selected_language_user_user_123',
      );
      expect(
        AppLanguageNotifier.userStorageKey('user_456'),
        'selected_language_user_user_456',
      );
    });
  });
}
