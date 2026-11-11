import 'package:dio/dio.dart';

import '../../localization/localization_provider.dart';

/// Injects `x-locale` and `Accept-Language` headers (`en` or `de`) into outgoing requests.
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor([this._getLocaleCode]);

  final String Function()? _getLocaleCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final rawLocale =
        _getLocaleCode?.call() ?? AppLanguageNotifier.activeLanguageCode;
    final locale = rawLocale.toLowerCase().startsWith('de') ? 'de' : 'en';
    final alt = locale == 'de' ? 'en' : 'de';

    options.headers['x-locale'] = locale;
    options.headers['Accept-Language'] = '$locale;q=1.0,$alt;q=0.5';

    handler.next(options);
  }
}
