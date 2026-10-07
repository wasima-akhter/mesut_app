import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';
import 'app_localization.dart';
import 'app_strings.dart';

/// NotifierProvider for managing the current application language
final appLanguageProvider =
    NotifierProvider<AppLanguageNotifier, AppLanguage>(
      AppLanguageNotifier.new,
    );

class AppLanguageNotifier extends Notifier<AppLanguage> {
  static const String _storageKey = 'selected_language_code';

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
        await AppLocalization.load(language);
        state = language;
      } else {
        await AppLocalization.load(AppLanguage.english);
      }
    } catch (_) {
      await AppLocalization.load(AppLanguage.english);
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (state == language) return;
    await AppLocalization.load(language);
    state = language;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, language.code);
    } catch (_) {}
  }
}

/// Provider that exposes the current AppStrings
final appStringsProvider = Provider<AppStrings>((ref) {
  final language = ref.watch(appLanguageProvider);
  return AppLocalization.getStringsForLanguage(language);
});
