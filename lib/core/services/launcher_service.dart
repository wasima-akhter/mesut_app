import 'package:url_launcher/url_launcher.dart';

class AppLauncherService {
  AppLauncherService._();

  /// Launches the phone dialer with the provided [phoneNumber].
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanedNumber.isNotEmpty ? cleanedNumber : phoneNumber);

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  /// Opens the default email app with pre-filled [email], optional [subject], and optional [body].
  static Future<bool> sendEmail({
    required String email,
    String? subject,
    String? body,
  }) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email.trim(),
      query: _encodeQueryParameters({
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      }),
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  /// Opens web URL or deep link.
  static Future<bool> openUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Opens external map application (Google Maps / Apple Maps)
  /// navigating to the given [latitude], [longitude] or [address].
  static Future<bool> openMapNavigation({
    double? latitude,
    double? longitude,
    String? address,
    String? label,
  }) async {
    Uri uri;
    if (latitude != null && longitude != null) {
      final query = label != null
          ? '$latitude,$longitude(${Uri.encodeComponent(label)})'
          : '$latitude,$longitude';
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    } else if (address != null && address.trim().isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address.trim())}',
      );
    } else {
      return false;
    }

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    if (params.isEmpty) return null;
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
