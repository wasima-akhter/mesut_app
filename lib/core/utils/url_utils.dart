class UrlUtils {
  UrlUtils._();

  static bool isValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(value.trim());

    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static bool isAbsolute(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(value.trim());

    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  static String? buildUrl({required String? value, String? baseUrl}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmed = value.trim();

    if (isAbsolute(trimmed)) {
      return trimmed;
    }

    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return null;
    }

    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';

    return '$base$path';
  }
}
