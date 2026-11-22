import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../enums/app_enum.dart';
import '../network/network_providers.dart';
import '../providers/common_provider.dart';
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
  static const String preLoginKey = 'pre_login_language';
  static String activeLanguageCode = 'en';

  static String roleStorageKey(UserRole role) =>
      'selected_language_role_${role.name.toLowerCase()}';
  static String userStorageKey(String userId) =>
      'selected_language_user_$userId';

  @override
  AppLanguage build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final currentRole = ref.watch(userRoleProvider);

    // 1. If a role is active:
    if (currentRole != null) {
      final roleCode = prefs.getString(roleStorageKey(currentRole));
      if (roleCode != null) {
        final lang = AppLanguage.fromCode(roleCode);
        activeLanguageCode = lang.code;
        return lang;
      }
      // Never inherit another role's selection; default to German 'de'
      const defaultLang = AppLanguage.german;
      activeLanguageCode = defaultLang.code;
      return defaultLang;
    }

    // 2. Pre-login / unauthenticated:
    final preLoginCode =
        prefs.getString(preLoginKey) ?? prefs.getString(_storageKey);
    final language = preLoginCode != null
        ? AppLanguage.fromCode(preLoginCode)
        : AppLanguage.german;
    activeLanguageCode = language.code;
    return language;
  }

  Future<void> setLanguage(
    AppLanguage language, {
    UserRole? role,
    String? userId,
  }) async {
    activeLanguageCode = language.code;
    AddressResolverService.clearCache();
    if (state != language) {
      await AppLocalization.load(language);
      state = language;
    }

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final currentRole = role ?? ref.read(userRoleProvider);

      if (currentRole != null) {
        await prefs.setString(roleStorageKey(currentRole), language.code);
      }
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString(userStorageKey(userId), language.code);
      }

      await prefs.setString(_storageKey, language.code);
      if (currentRole == null) {
        await prefs.setString(preLoginKey, language.code);
      }
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

  /// Sync language when a session is authenticated for a specific user/role.
  Future<void> syncForSession({
    required UserRole role,
    required String userId,
    String? backendLanguage,
  }) async {
    final prefs = ref.read(sharedPreferencesProvider);
    AppLanguage? targetLang;

    // 1. Check user-specific preference
    if (userId.isNotEmpty) {
      final userCode = prefs.getString(userStorageKey(userId));
      if (userCode != null) {
        targetLang = AppLanguage.fromCode(userCode);
      }
    }

    // 2. Check user's backend profile language
    if (targetLang == null &&
        backendLanguage != null &&
        backendLanguage.isNotEmpty) {
      targetLang = AppLanguage.fromCode(backendLanguage);
    }

    // 3. Check role-specific preference
    if (targetLang == null) {
      final roleCode = prefs.getString(roleStorageKey(role));
      if (roleCode != null) {
        targetLang = AppLanguage.fromCode(roleCode);
      }
    }

    // 4. Default for this role (never leak previous role's language)
    targetLang ??= AppLanguage.german;

    activeLanguageCode = targetLang.code;
    AddressResolverService.clearCache();
    if (state != targetLang) {
      await AppLocalization.load(targetLang);
      state = targetLang;
      await onAppLanguageChanged(ref);
    }
  }

  /// Reset active language when a user logs out so next role does not inherit it.
  Future<void> resetOnLogout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final preLoginCode = prefs.getString(preLoginKey) ?? 'de';
    final targetLang = AppLanguage.fromCode(preLoginCode);

    activeLanguageCode = targetLang.code;
    AddressResolverService.clearCache();
    if (state != targetLang) {
      await AppLocalization.load(targetLang);
      state = targetLang;
    }
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
