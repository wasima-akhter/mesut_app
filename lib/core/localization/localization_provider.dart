import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../network/network_providers.dart';
import '../services/address_resolver_service.dart';
import '../storage/storage_provider.dart';
import 'app_language.dart';
import 'app_localization.dart';
import 'app_strings.dart';
import 'locale_cache_invalidator.dart';

/// NotifierProvider for managing the current application language
final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(
  AppLanguageNotifier.new,
);

class AppLanguageNotifier extends Notifier<AppLanguage> {
  static const String _storageKey = StorageKeys.selectedLanguage;
  static String activeLanguageCode = 'en';

  @override
  AppLanguage build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_storageKey);
    final language =
        code != null ? AppLanguage.fromCode(code) : AppLanguage.english;
    activeLanguageCode = language.code;
    return language;
  }

  Future<void> setLanguage(AppLanguage language) async {
    activeLanguageCode = language.code;
    AddressResolverService.clearCache();
    if (state != language) {
      await AppLocalization.load(language);
      state = language;
    }

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_storageKey, language.code);
      await prefs.setBool(StorageKeys.hasUserSelectedLanguage, true);
    } catch (_) {}

    // Persist to backend preference if reachable
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        ApiConstants.settingsLanguage,
        data: {'language': language.code.toUpperCase()},
      );
    } catch (_) {}

    // Clear caches and refetch active screens
    await onAppLanguageChanged(ref);
  }

  /// Applies backend `defaultLanguage` from `/mobile/config` only when the
  /// user has not explicitly picked a language on-device.
  Future<void> applyServerDefault(AppLanguage language) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
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
