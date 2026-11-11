import 'dart:convert';

/// Pure-Dart JWT payload decoder and expiration inspector.
class JwtHelper {
  JwtHelper._();

  /// Strips potential 'Bearer ' prefix and whitespace from a JWT token.
  static String? cleanToken(String? token) {
    if (token == null) return null;
    var trimmed = token.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.toLowerCase().startsWith('bearer ')) {
      trimmed = trimmed.substring(7).trim();
    }
    return trimmed.isNotEmpty ? trimmed : null;
  }

  /// Safely decodes a JWT token into its payload map, returning null if malformed.
  static Map<String, dynamic>? decode(String? token) {
    final cleaned = cleanToken(token);
    if (cleaned == null) return null;
    try {
      final parts = cleaned.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payloadBytes = base64Url.decode(normalized);
      final payloadJson = utf8.decode(payloadBytes);
      final decoded = jsonDecode(payloadJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Extracts email claim if present in the JWT payload.
  static String? extractEmail(String? token) {
    final payload = decode(token);
    if (payload == null) return null;
    final email = payload['email'] ??
        payload['userEmail'] ??
        payload['user_email'] ??
        payload['emailAddress'] ??
        payload['mail'];
    if (email is String && email.trim().isNotEmpty) {
      return email.trim();
    }
    final sub = payload['sub'];
    if (sub is String && sub.contains('@')) {
      return sub.trim();
    }
    final identity = payload['identity'];
    if (identity is String && identity.contains('@')) {
      return identity.trim();
    }
    return null;
  }

  /// Extracts user role claim from JWT payload.
  static String? extractRole(String? token) {
    final payload = decode(token);
    if (payload == null) return null;
    final role = payload['role'] ?? payload['userRole'];
    return role is String ? role.trim() : null;
  }

  /// Extracts user id from JWT payload.
  static String? extractUserId(String? token) {
    final payload = decode(token);
    if (payload == null) return null;
    final id = payload['id'] ?? payload['userId'] ?? payload['sub'];
    return id is String ? id.trim() : null;
  }

  /// Extracts token expiry DateTime if `exp` claim is present.
  static DateTime? getExpiryDate(String? token) {
    final payload = decode(token);
    if (payload == null) return null;
    final exp = payload['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    }
    if (exp is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        (exp * 1000).round(),
        isUtc: true,
      );
    }
    return null;
  }

  /// Checks whether a JWT token is expired using its `exp` claim.
  static bool isExpired(String? token) {
    final expiry = getExpiryDate(token);
    if (expiry == null) {
      // If payload cannot be decoded at all, treat as expired/invalid.
      return decode(token) == null;
    }
    return DateTime.now().toUtc().isAfter(expiry);
  }
}
