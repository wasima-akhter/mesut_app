import 'package:dio/dio.dart';

import '../../localization/localization_provider.dart';

/// Injects `x-locale` and `Accept-Language` headers matching active app language into outgoing requests.
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor([this._getLocaleCode]);

  final String Function()? _getLocaleCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final rawLocale =
        _getLocaleCode?.call() ?? AppLanguageNotifier.activeLanguageCode;
    final locale = rawLocale.trim().toLowerCase();
    final effective = locale.isNotEmpty ? locale : 'en';
    final alt = effective == 'en' ? 'de' : 'en';

    options.headers['x-locale'] = effective;
    options.headers['Accept-Language'] = '$effective;q=1.0,$alt;q=0.5';

    handler.next(options);
  }
}
