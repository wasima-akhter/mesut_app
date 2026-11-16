import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../session/session_manager.dart';
import '../../storage/storage_service.dart';
import '../../utils/jwt_helper.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storageService, this.sessionManager});

  final StorageService storageService;
  final SessionManager? sessionManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers.containsKey('Authorization')) {
      handler.next(options);
      return;
    }

    // Signup OTP Token endpoints
    if (options.path.contains(ApiConstants.verify) ||
        options.path.contains(ApiConstants.resend)) {
      if (!options.path.contains(ApiConstants.recoverVerify) &&
          !options.path.contains(ApiConstants.recoverResend)) {
        final otpToken = await storageService.getOtpPageToken();
        if (otpToken != null && otpToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $otpToken';
        } else {
          final accessToken = await storageService.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        handler.next(options);
        return;
      }
    }

    // Password Recovery endpoints (resend, verify, reset)
    if (options.path.contains(ApiConstants.recoverResend) ||
        options.path.contains(ApiConstants.recoverVerify) ||
        options.path.contains(ApiConstants.recoverReset)) {
      final resetToken = await storageService.getPasswordResetToken();
      if (resetToken != null && resetToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $resetToken';
      }
      handler.next(options);
      return;
    }

    // Public endpoints
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Authenticated endpoints require Access Token
    final accessToken = await storageService.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      if (JwtHelper.isExpired(accessToken)) {
        if (sessionManager != null) {
          await sessionManager!.handleSessionExpired();
        }
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: const {
                'success': false,
                'errorType': 'TOKEN_EXPIRED',
                'message': 'Session has expired',
              },
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }

      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    final errorType = err.response?.data is Map
        ? err.response!.data['errorType']?.toString().toUpperCase()
        : null;

    final isSessionErrorCode =
        errorType != null &&
        (errorType.startsWith('TOKEN_') ||
            errorType.startsWith('SESSION_') ||
            errorType.startsWith('DEVICE_') ||
            errorType == 'UNAUTHORIZED');

    final isAuthError =
        (statusCode == 401 && errorType != 'INVALID_OTP') || isSessionErrorCode;

    if (isAuthError && !_isExcludedFromSessionExpiry(path)) {
      if (sessionManager != null) {
        await sessionManager!.handleSessionExpired();
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    const publicEndpoints = <String>{
      ApiConstants.health,
      ApiConstants.signup,
      ApiConstants.login,
      ApiConstants.recoverFind,
      ApiConstants.adminRecoverFind,
    };

    return publicEndpoints.any((endpoint) => path.endsWith(endpoint));
  }

  bool _isExcludedFromSessionExpiry(String path) {
    const excluded = <String>{
      ApiConstants.health,
      ApiConstants.signup,
      ApiConstants.verify,
      ApiConstants.resend,
      ApiConstants.login,
      ApiConstants.check,
      ApiConstants.logout,
      ApiConstants.recoverFind,
      ApiConstants.recoverResend,
      ApiConstants.recoverVerify,
      ApiConstants.recoverReset,
      ApiConstants.adminRecoverFind,
      ApiConstants.adminRecoverResend,
      ApiConstants.adminRecoverVerify,
      ApiConstants.adminRecoverReset,
    };

    return excluded.any((endpoint) => path.endsWith(endpoint));
  }
}
