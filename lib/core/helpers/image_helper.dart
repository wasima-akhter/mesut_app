import '../utils/url_utils.dart';

class ImageHelper {
  ImageHelper._();

  static String? resolveNetworkUrl({required String? value, String? baseUrl}) {
    return UrlUtils.buildUrl(value: value, baseUrl: baseUrl);
  }

  static bool isValidNetworkImage({required String? value, String? baseUrl}) {
    final url = resolveNetworkUrl(value: value, baseUrl: baseUrl);

    return UrlUtils.isValid(url);
  }
}
