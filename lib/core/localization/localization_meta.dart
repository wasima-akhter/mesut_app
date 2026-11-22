import 'localization_provider.dart';

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
    if (status == 'PENDING' || status == 'PROCESSING') return true;
    if (isFailed) return false;

    final activeLang =
        AppLanguageNotifier.activeLanguageCode.toLowerCase().trim();
    if (activeLang.isEmpty) return false;

    final src = sourceLocale.toLowerCase().trim();
    final displayed = displayedLocale.toLowerCase().trim();

    if (displayed.isNotEmpty && displayed != activeLang) {
      return true;
    }

    if (src.isNotEmpty && src != activeLang && !isTranslated) {
      return true;
    }

    return false;
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

    final active = AppLanguageNotifier.activeLanguageCode.toLowerCase().trim();
    final resolvedSource =
        (source != null && source.isNotEmpty) ? source.toLowerCase() : 'en';
    final resolvedDisplayed = (displayed != null && displayed.isNotEmpty)
        ? displayed.toLowerCase()
        : resolvedSource;
    final isTrans = translated is bool ? translated : false;

    String resolvedStatus;
    if (status != null && status.isNotEmpty) {
      resolvedStatus = status.toUpperCase();
      if (resolvedStatus == 'READY' &&
          (resolvedDisplayed != active ||
              (resolvedSource != active && !isTrans))) {
        resolvedStatus = 'PENDING';
      }
    } else if (resolvedDisplayed != active ||
        (resolvedSource != active && !isTrans)) {
      resolvedStatus = 'PENDING';
    } else {
      resolvedStatus = 'READY';
    }

    return LocalizationMeta(
      sourceLocale: resolvedSource,
      displayedLocale: resolvedDisplayed,
      isTranslated: isTrans,
      translationStatus: resolvedStatus,
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
