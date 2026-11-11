import 'package:dio/dio.dart';

import '../../errors/app_error_resolver.dart';
import '../../localization/localization_provider.dart';

/// Sanitizes 5xx HTTP responses into localized, non-technical error messages.
class ServerErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode ?? 0;
    if (status >= 500) {
      final lang = AppLanguageNotifier.activeLanguageCode;
      final resolved = AppErrorResolver.resolve(err, languageCode: lang);

      final sanitizedError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: resolved,
        message: resolved.displayMessage,
      );
      return handler.next(sanitizedError);
    }
    handler.next(err);
  }
}
