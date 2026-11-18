/// Shared multilingual translation metadata returned by the backend.
///
/// Supports both flat payloads (`sourceLocale` / `displayedLocale` /
/// `isTranslated` / `translationStatus` on the item root) and nested
/// `localization: { ... }` payloads (Guide Section 4).
class LocalizationMeta {
  const LocalizationMeta({
    this.sourceLocale = 'en',
    this.displayedLocale = 'en',
    this.isTranslated = false,
    this.translationStatus = 'READY',
  });

  final String sourceLocale;
  final String displayedLocale;
  final bool isTranslated;
  final String translationStatus;

  static const LocalizationMeta empty = LocalizationMeta();

  bool get isPending {
    final status = translationStatus.toUpperCase();
    return status == 'PENDING' || status == 'PROCESSING';
  }

  bool get isFailed => translationStatus.toUpperCase() == 'FAILED';

  bool get showTranslatedBadge =>
      isTranslated &&
      !isPending &&
      !isFailed &&
      sourceLocale.toLowerCase() != displayedLocale.toLowerCase();

  /// Parses flat or nested `localization` metadata from a JSON map.
  /// Returns `null` if none of the localization fields are present.
  static LocalizationMeta? tryParse(Map<String, dynamic>? json) {
    if (json == null) return null;

    final nested = json['localization'];
    final Map<String, dynamic> src = nested is Map<String, dynamic>
        ? nested
        : (nested is Map
            ? Map<String, dynamic>.from(nested)
            : json);

    final hasAnyField = src.containsKey('sourceLocale') ||
        src.containsKey('displayedLocale') ||
        src.containsKey('isTranslated') ||
        src.containsKey('translationStatus');

    if (!hasAnyField && nested == null) return null;

    final source = src['sourceLocale']?.toString().trim();
    final displayed = src['displayedLocale']?.toString().trim();
    final status = src['translationStatus']?.toString().trim();
    final translated = src['isTranslated'];

    return LocalizationMeta(
      sourceLocale:
          (source != null && source.isNotEmpty) ? source.toLowerCase() : 'en',
      displayedLocale: (displayed != null && displayed.isNotEmpty)
          ? displayed.toLowerCase()
          : 'en',
      isTranslated: translated is bool ? translated : false,
      translationStatus: (status != null && status.isNotEmpty)
          ? status.toUpperCase()
          : 'READY',
    );
  }

  /// Parses metadata with safe defaults when callers require non-null fields.
  static LocalizationMeta parseOrDefault(Map<String, dynamic>? json) {
    return tryParse(json) ?? empty;
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceLocale': sourceLocale,
      'displayedLocale': displayedLocale,
      'isTranslated': isTranslated,
      'translationStatus': translationStatus,
    };
  }
}
