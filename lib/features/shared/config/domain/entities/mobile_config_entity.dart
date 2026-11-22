import '../../../../../core/localization/app_language.dart';

enum LegalContentType {
  privacyPolicy('PRIVACY_AND_POLICY'),
  termsAndConditions('TERMS_AND_CONDITION'),
  aboutUs('ABOUT_US'),
  other('OTHER');

  const LegalContentType(this.serializedName);
  final String serializedName;

  static LegalContentType fromString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return LegalContentType.other;
    final normalized = raw.trim().toUpperCase().replaceAll(' ', '_');
    if (normalized.contains('PRIVACY')) {
      return LegalContentType.privacyPolicy;
    }
    if (normalized.contains('TERMS') || normalized.contains('CONDITION')) {
      return LegalContentType.termsAndConditions;
    }
    if (normalized.contains('ABOUT')) {
      return LegalContentType.aboutUs;
    }
    return LegalContentType.other;
  }
}

class LegalContentItem {
  const LegalContentItem({
    required this.type,
    required this.rawType,
    required this.content,
    this.updatedAt,
  });

  final LegalContentType type;
  final String rawType;
  final String content;
  final DateTime? updatedAt;

  factory LegalContentItem.fromJson(Map<String, dynamic> json) {
    final rawType = (json['legalContentType'] ?? json['type'] ?? '').toString();
    final updatedAtRaw = json['updatedAt']?.toString();
    return LegalContentItem(
      type: LegalContentType.fromString(rawType),
      rawType: rawType,
      content: (json['content'] ?? json['html'] ?? '').toString(),
      updatedAt: updatedAtRaw != null ? DateTime.tryParse(updatedAtRaw) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'legalContentType': rawType,
    'content': content,
    if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
  };
}

class MobileConfigEntity {
  const MobileConfigEntity({
    this.defaultLanguage = 'en',
    this.enabledLanguages = const [
      'de', 'en', 'tr', 'pl', 'ro', 'fr', 'es', 'it', 'nl', 'pt',
      'ru', 'uk', 'bg', 'hr', 'sr', 'sq', 'el', 'hi', 'ar',
    ],
    this.allowEmployeeManualTime = true,
    this.legalContents = const [],
  });

  final String defaultLanguage;
  final List<String> enabledLanguages;
  final bool allowEmployeeManualTime;
  final List<LegalContentItem> legalContents;

  factory MobileConfigEntity.fromJson(Map<String, dynamic> json) {
    final defaultLangRaw = (json['defaultLanguage'] ?? 'en')
        .toString()
        .trim()
        .toLowerCase();

    final rawEnabled = json['enabledLanguages'];
    final enabled = <String>[];
    if (rawEnabled is List) {
      for (final item in rawEnabled) {
        String? code;
        if (item is String) {
          code = item.trim().toLowerCase();
        } else if (item is Map) {
          code = (item['code'] ?? item['language'] ?? item['locale'])
              ?.toString()
              .trim()
              .toLowerCase();
        }
        if (code != null && code.isNotEmpty) {
          final lang = AppLanguage.fromCode(code);
          if (!enabled.contains(lang.code)) {
            enabled.add(lang.code);
          }
        }
      }
    }

    final rawLegal = json['legalContents'];
    final legal = <LegalContentItem>[];
    if (rawLegal is List) {
      for (final item in rawLegal) {
        if (item is Map) {
          legal.add(LegalContentItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return MobileConfigEntity(
      defaultLanguage: AppLanguage.fromCode(defaultLangRaw).code,
      enabledLanguages: enabled.isEmpty
          ? AppLanguage.companyEnabledApiCodes
              .map((c) => c.toLowerCase())
              .toList()
          : enabled,
      allowEmployeeManualTime: json['allowEmployeeManualTime'] is bool
          ? json['allowEmployeeManualTime'] as bool
          : true,
      legalContents: legal,
    );
  }

  Map<String, dynamic> toJson() => {
    'defaultLanguage': defaultLanguage,
    'enabledLanguages': enabledLanguages,
    'allowEmployeeManualTime': allowEmployeeManualTime,
    'legalContents': legalContents.map((e) => e.toJson()).toList(),
  };

  List<AppLanguage> get supportedAppLanguages {
    final langs = <AppLanguage>[];
    for (final code in enabledLanguages) {
      final lang = AppLanguage.fromCode(code);
      if (!langs.contains(lang)) {
        langs.add(lang);
      }
    }
    return langs.isEmpty ? AppLanguage.companyEnabledLanguages : langs;
  }

  LegalContentItem? findLegal(LegalContentType type) {
    for (final item in legalContents) {
      if (item.type == type && item.content.trim().isNotEmpty) {
        return item;
      }
    }
    return null;
  }

  String? get privacyPolicyHtml =>
      findLegal(LegalContentType.privacyPolicy)?.content;

  String? get termsAndConditionsHtml =>
      findLegal(LegalContentType.termsAndConditions)?.content;
}
