import 'package:flutter/material.dart';

enum AppLanguage {
  german('de', 'Deutsch', 'German (DE/AT/CH)', '🇩🇪'),
  english('en', 'English', 'English (US/UK)', '🇬🇧'),
  turkish('tr', 'Türkçe', 'Turkish (TR)', '🇹🇷'),
  hindi('hi', 'हिन्दी', 'Hindi (IN)', '🇮🇳'),
  polish('pl', 'Polski', 'Polish (PL)', '🇵🇱'),
  romanian('ro', 'Română', 'Romanian (RO)', '🇷🇴'),
  french('fr', 'Français', 'French (FR)', '🇫🇷'),
  spanish('es', 'Español', 'Spanish (ES)', '🇪🇸'),
  italian('it', 'Italiano', 'Italian (IT)', '🇮🇹'),
  dutch('nl', 'Nederlands', 'Dutch (NL)', '🇳🇱'),
  portuguese('pt', 'Português', 'Portuguese (PT/BR)', '🇵🇹'),
  arabic('ar', 'العربية', 'Arabic (AR)', '🇸🇦', isRtl: true),
  russian('ru', 'Русский', 'Russian (RU)', '🇷🇺'),
  ukrainian('uk', 'Українська', 'Ukrainian (UA)', '🇺🇦'),
  bulgarian('bg', 'Български', 'Bulgarian (BG)', '🇧🇬'),
  croatian('hr', 'Hrvatski', 'Croatian (HR)', '🇭🇷'),
  serbian('sr', 'Српски', 'Serbian (SR)', '🇷🇸'),
  albanian('sq', 'Shqip', 'Albanian (AL)', '🇦🇱'),
  greek('el', 'Ελληνικά', 'Greek (GR)', '🇬🇷');

  final String code;
  final String label;
  final String subtitle;
  final String flagEmoji;
  final bool isRtl;

  const AppLanguage(
    this.code,
    this.label,
    this.subtitle,
    this.flagEmoji, {
    this.isRtl = false,
  });

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return AppLanguage.english;
    final normalized = code.trim().toLowerCase();
    for (final lang in AppLanguage.values) {
      if (lang.code == normalized) return lang;
    }
    return AppLanguage.english;
  }
}
