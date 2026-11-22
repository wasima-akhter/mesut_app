import 'package:flutter/material.dart';

enum AppLanguage {
  german('de', 'DE', 'Deutsch', 'German (DE)', '🇩🇪'),
  english('en', 'EN', 'English', 'English (GB)', '🇬🇧'),
  polish('pl', 'PL', 'Polski', 'Polish (PL)', '🇵🇱'),
  romanian('ro', 'RO', 'Română', 'Romanian (RO)', '🇷🇴'),
  turkish('tr', 'TR', 'Türkçe', 'Turkish (TR)', '🇹🇷'),
  bulgarian('bg', 'BG', 'Български', 'Bulgarian (BG)', '🇧🇬'),
  croatian('hr', 'HR', 'Hrvatski', 'Croatian (HR)', '🇭🇷'),
  serbian('sr', 'SR', 'Српски', 'Serbian (RS)', '🇷🇸'),
  ukrainian('uk', 'UK', 'Українська', 'Ukrainian (UA)', '🇺🇦'),
  russian('ru', 'RU', 'Русский', 'Russian (RU)', '🇷🇺'),
  albanian('sq', 'SQ', 'Shqip', 'Albanian (AL)', '🇦🇱'),
  italian('it', 'IT', 'Italiano', 'Italian (IT)', '🇮🇹'),
  french('fr', 'FR', 'Français', 'French (FR)', '🇫🇷'),
  spanish('es', 'ES', 'Español', 'Spanish (ES)', '🇪🇸'),
  portuguese('pt', 'PT', 'Português', 'Portuguese (PT)', '🇵🇹'),
  dutch('nl', 'NL', 'Nederlands', 'Dutch (NL)', '🇳🇱'),
  greek('el', 'EL', 'Ελληνικά', 'Greek (GR)', '🇬🇷'),
  hungarian('hu', 'HU', 'Magyar', 'Hungarian (HU)', '🇭🇺'),
  hindi('hi', 'HI', 'हिन्दी', 'Hindi (IN)', '🇮🇳'),
  arabic('ar', 'AR', 'العربية', 'Arabic (SA)', '🇸🇦');

  final String code;
  final String apiCode;
  final String label;
  final String subtitle;
  final String flagEmoji;

  const AppLanguage(
    this.code,
    this.apiCode,
    this.label,
    this.subtitle,
    this.flagEmoji,
  );

  bool get isRtl => this == AppLanguage.arabic;

  Locale get locale => Locale(code);

  /// Catalog of all 20 API codes.
  static const List<String> allApiCodes = [
    'DE',
    'EN',
    'PL',
    'RO',
    'TR',
    'BG',
    'HR',
    'SR',
    'UK',
    'RU',
    'SQ',
    'IT',
    'FR',
    'ES',
    'PT',
    'NL',
    'EL',
    'HU',
    'HI',
    'AR',
  ];

  /// Enabled subset for this company (19 languages; HU kept in catalog only).
  static const List<String> companyEnabledApiCodes = [
    'DE',
    'EN',
    'TR',
    'PL',
    'RO',
    'FR',
    'ES',
    'IT',
    'NL',
    'PT',
    'RU',
    'UK',
    'BG',
    'HR',
    'SR',
    'SQ',
    'EL',
    'HI',
    'AR',
  ];

  static List<AppLanguage> get companyEnabledLanguages =>
      companyEnabledApiCodes.map(fromCode).toList();

  static AppLanguage fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return AppLanguage.english;
    final normalized = code.trim().toLowerCase();
    for (final lang in AppLanguage.values) {
      if (lang.code.toLowerCase() == normalized ||
          lang.apiCode.toLowerCase() == normalized) {
        return lang;
      }
    }
    return AppLanguage.english;
  }
}
