import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../services/address_resolver_service.dart';
import 'app_language.dart';
import 'app_localization.dart';
import 'app_strings.dart';

/// NotifierProvider for managing the current application language
final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(
  AppLanguageNotifier.new,
);

class AppLanguageNotifier extends Notifier<AppLanguage> {
  static const String _storageKey = StorageKeys.selectedLanguage;
  static String activeLanguageCode = 'en';

  @override
  AppLanguage build() {
    _loadPersistedLanguage();
    return AppLanguage.english;
  }

  Future<void> _loadPersistedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_storageKey);
      if (code != null) {
        final language = AppLanguage.fromCode(code);
        activeLanguageCode = language.code;
        await AppLocalization.load(language);
        state = language;
      } else {
        activeLanguageCode = AppLanguage.english.code;
        await AppLocalization.load(AppLanguage.english);
      }
    } catch (_) {
      activeLanguageCode = AppLanguage.english.code;
      await AppLocalization.load(AppLanguage.english);
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    activeLanguageCode = language.code;
    AddressResolverService.clearCache();
    if (state != language) {
      await AppLocalization.load(language);
      state = language;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, language.code);
      await prefs.setBool(StorageKeys.hasUserSelectedLanguage, true);
    } catch (_) {}
  }

  /// Applies backend `defaultLanguage` from `/mobile/config` only when the
  /// user has not explicitly picked a language on-device.
  Future<void> applyServerDefault(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasExplicitChoice =
          prefs.getBool(StorageKeys.hasUserSelectedLanguage) ?? false;
      if (hasExplicitChoice) return;

      activeLanguageCode = language.code;
      if (state != language) {
        await AppLocalization.load(language);
        state = language;
      }
      await prefs.setString(_storageKey, language.code);
    } catch (_) {}
  }
}

/// Provider that exposes the current AppStrings
final appStringsProvider = Provider<AppStrings>((ref) {
  final language = ref.watch(appLanguageProvider);
  return AppLocalization.getStringsForLanguage(language);
});
