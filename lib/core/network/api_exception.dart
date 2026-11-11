import '../localization/localization_provider.dart';

class ApiException implements Exception {
  final String rawMessage;
  final int statusCode;
  final dynamic data;
  final String? errorType;
  final String? traceId;

  ApiException({
    required String message,
    required this.statusCode,
    this.data,
    this.errorType,
    this.traceId,
  }) : rawMessage = message;

  /// Returns a user-friendly message when statusCode >= 500,
  /// otherwise returns the regular message.
  String get message {
    if (statusCode >= 500) {
      return localizedMessage();
    }
    return rawMessage;
  }

  String localizedMessage([String? languageCode]) {
    return getFriendlyServerError(languageCode);
  }

  static String getFriendlyServerError([String? languageCode]) {
    final effective = languageCode ?? AppLanguageNotifier.activeLanguageCode;
    final isGerman = effective.toLowerCase().startsWith('de');
    return isGerman
        ? 'Unsere Server haben derzeit technische Probleme. Bitte versuchen Sie es in wenigen Augenblicken erneut.'
        : 'Our servers are currently experiencing technical difficulties. Please try again in a few moments.';
  }

  @override
  String toString() => message;
}
