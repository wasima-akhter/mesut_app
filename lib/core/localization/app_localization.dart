import 'dart:convert';
import 'package:flutter/services.dart';

import 'app_language.dart';
import 'app_strings.dart';

class AppLocalization {
  static final Map<AppLanguage, AppStrings> _cache = {};
  static AppStrings _current = const AppStrings({});

  static AppStrings get current => _current;

  static Future<AppStrings> load(AppLanguage language) async {
    if (_cache.containsKey(language)) {
      _current = _cache[language]!;
      AppStrings.current = _current;
      return _current;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/l10n/${language.code}.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final stringMap = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      final appStrings = AppStrings(stringMap);
      _cache[language] = appStrings;
      _current = appStrings;
      AppStrings.current = _current;
      return appStrings;
    } catch (e) {
      // Fallback to empty Map if asset loading fails, AppStrings will use default fallbacks
      final fallback = AppStrings(const {});
      _cache[language] = fallback;
      _current = fallback;
      AppStrings.current = _current;
      return fallback;
    }
  }

  static AppStrings getStringsForLanguage(AppLanguage language) {
    return _cache[language] ?? _current;
  }
}
