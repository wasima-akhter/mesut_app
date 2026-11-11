import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../localization/localization_provider.dart';
import '../session/session_manager.dart';
import '../storage/storage_provider.dart';
import 'api_client.dart';
import 'dio_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/in_flight_request_interceptor.dart';
import 'interceptors/locale_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/server_error_interceptor.dart';

/// App configuration provider.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.current;
});

/// Locale interceptor injecting `x-locale` and `Accept-Language`.
final localeInterceptorProvider = Provider<LocaleInterceptor>((ref) {
  return LocaleInterceptor(() {
    return ref.watch(appLanguageProvider).code;
  });
});

/// In-flight request deduplication interceptor.
final inFlightRequestInterceptorProvider =
    Provider<InFlightRequestInterceptor>((ref) {
  return InFlightRequestInterceptor();
});

/// Authentication interceptor.
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(
    storageService: ref.watch(storageServiceProvider),
    sessionManager: ref.watch(sessionManagerProvider),
  );
});

/// Server error sanitization interceptor.
final serverErrorInterceptorProvider = Provider<ServerErrorInterceptor>((ref) {
  return ServerErrorInterceptor();
});

/// API logging interceptor.
final apiLogInterceptorProvider = Provider<ApiLogInterceptor>((ref) {
  return ApiLogInterceptor();
});

/// Configured Dio client.
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    config: ref.watch(appConfigProvider),
    interceptors: [
      ref.watch(localeInterceptorProvider),
      ref.watch(inFlightRequestInterceptorProvider),
      ref.watch(authInterceptorProvider),
      ref.watch(serverErrorInterceptorProvider),
      ref.watch(apiLogInterceptorProvider),
    ],
  );
});

/// Raw Dio instance.
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});

/// Main API client.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
