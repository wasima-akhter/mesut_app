import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/jwt_helper.dart';
import '../../domain/entities/auth_session.dart';
import '../dtos/auth_request_dtos.dart';
import '../dtos/recovery_dtos.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> checkHealth();

  Future<String> signUp(SignupRequestDto request);

  Future<AuthSession> verifyOtp({
    required VerifyOtpRequestDto request,
    String? otpPageToken,
  });

  Future<String?> resendOtp({String? otpPageToken});

  Future<AuthSession> login(LoginRequestDto request);

  Future<AuthUserModel?> checkSession(CheckSessionRequestDto request);

  Future<void> logout();

  Future<RecoverUserData> findUserForRecovery(String email);

  Future<String> resendRecoveryOtp({required String recoveryToken});

  Future<bool> verifyRecoveryOtp({
    required String otp,
    required String recoveryToken,
  });

  Future<void> resetPasswordWithRecoveryToken({
    required String password,
    required String confirmPassword,
    required String recoveryToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required this.config,
  });

  final ApiClient apiClient;
  final AppConfig config;

  @override
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await apiClient.get(
        '${config.serverBaseUrl}${ApiConstants.health}',
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': true};
    } catch (e) {
      _handleError(e, 'Health check failed');
    }
  }

  @override
  Future<String> signUp(SignupRequestDto request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.signup,
        data: request.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'];
        if (nestedData is Map<String, dynamic> &&
            nestedData['token'] != null) {
          return nestedData['token'].toString();
        } else if (nestedData is String && nestedData.isNotEmpty) {
          return nestedData;
        }
      }
      return _handleResponseError(data, 'Failed to complete signup');
    } catch (e) {
      _handleError(e, 'Failed to complete signup');
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required VerifyOtpRequestDto request,
    String? otpPageToken,
  }) async {
    try {
      final options = Options();
      if (otpPageToken != null && otpPageToken.isNotEmpty) {
        options.headers = {'Authorization': 'Bearer $otpPageToken'};
      }

      final response = await apiClient.post(
        ApiConstants.verify,
        data: request.toJson(),
        options: options,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'] as Map<String, dynamic>? ?? {};
        final accessToken =
            nestedData['accessToken']?.toString() ??
            nestedData['token']?.toString() ??
            '';
        final userMap =
            nestedData['user'] as Map<String, dynamic>? ?? nestedData;
        var user = AuthUserModel.fromJson(userMap);

        final emailFromToken = JwtHelper.extractEmail(accessToken);
        if (emailFromToken != null &&
            emailFromToken.isNotEmpty &&
            user.email.isEmpty) {
          user = AuthUserModel.fromEntity(
            user.copyWith(email: emailFromToken),
          );
        }

        return AuthSession(accessToken: accessToken, user: user);
      }
      return _handleResponseError(data, 'OTP verification failed');
    } catch (e) {
      _handleError(e, 'OTP verification failed');
    }
  }

  @override
  Future<String?> resendOtp({String? otpPageToken}) async {
    try {
      final options = Options();
      if (otpPageToken != null && otpPageToken.isNotEmpty) {
        options.headers = {'Authorization': 'Bearer $otpPageToken'};
      }

      final response = await apiClient.post(
        ApiConstants.resend,
        data: const {},
        options: options,
      );

      final respData = response.data;
      if (respData is Map<String, dynamic>) {
        final nestedData = respData['data'];
        if (nestedData is Map<String, dynamic>) {
          return nestedData['token']?.toString() ??
              nestedData['otpToken']?.toString() ??
              nestedData['accessToken']?.toString();
        }
      }
      return null;
    } catch (e) {
      _handleError(e, 'Failed to resend verification code');
    }
  }

  @override
  Future<AuthSession> login(LoginRequestDto request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'] as Map<String, dynamic>? ?? {};
        final accessToken =
            nestedData['token']?.toString() ??
            nestedData['accessToken']?.toString() ??
            '';
        final userMap =
            nestedData['user'] as Map<String, dynamic>? ?? nestedData;
        var user = AuthUserModel.fromJson(userMap);

        final emailFromToken = JwtHelper.extractEmail(accessToken);
        final effectiveEmail =
            user.email.isNotEmpty
                ? user.email
                : ((emailFromToken != null && emailFromToken.isNotEmpty)
                      ? emailFromToken
                      : request.email);
        user = AuthUserModel.fromEntity(user.copyWith(email: effectiveEmail));

        return AuthSession(accessToken: accessToken, user: user);
      }
      return _handleResponseError(data, 'Login failed');
    } catch (e) {
      _handleError(e, 'Login failed');
    }
  }

  @override
  Future<AuthUserModel?> checkSession(CheckSessionRequestDto request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.check,
        data: request.toJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['success'] != true) {
          return _handleResponseError(data, 'Session validation failed');
        }
        final userMap = data['data'];
        if (userMap is Map<String, dynamic>) {
          return AuthUserModel.fromJson(userMap);
        }
        return null;
      }
      return _handleResponseError(data, 'Invalid session response');
    } catch (e) {
      _handleError(e, 'Invalid session response');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiConstants.logout, data: const {});
    } catch (_) {
      // Allow local logout cleanup even if network call fails.
    }
  }

  @override
  Future<RecoverUserData> findUserForRecovery(String email) async {
    try {
      final response = await apiClient.post(
        ApiConstants.recoverFind,
        data: {'email': email.trim().toLowerCase()},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'];
        if (nestedData is Map<String, dynamic>) {
          return RecoverUserData.fromJson(nestedData);
        }
      }
      return _handleResponseError(data, 'User with this email was not found');
    } catch (e) {
      _handleError(e, 'Failed to find user for recovery');
    }
  }

  @override
  Future<String> resendRecoveryOtp({required String recoveryToken}) async {
    try {
      final response = await apiClient.post(
        ApiConstants.recoverResend,
        data: const {},
        options: Options(headers: {'Authorization': 'Bearer $recoveryToken'}),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            'Recover user otp resend successful!';
      }
      return _handleResponseError(data, 'Failed to resend recovery OTP');
    } catch (e) {
      _handleError(e, 'Failed to resend recovery OTP');
    }
  }

  @override
  Future<bool> verifyRecoveryOtp({
    required String otp,
    required String recoveryToken,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.recoverVerify,
        data: {'otp': otp.trim()},
        options: Options(headers: {'Authorization': 'Bearer $recoveryToken'}),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return true;
      }
      return _handleResponseError(data, 'Failed to verify recovery OTP');
    } catch (e) {
      _handleError(e, 'Failed to verify recovery OTP');
    }
  }

  @override
  Future<void> resetPasswordWithRecoveryToken({
    required String password,
    required String confirmPassword,
    required String recoveryToken,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.recoverReset,
        data: {'password': password, 'confirmPassword': confirmPassword},
        options: Options(headers: {'Authorization': 'Bearer $recoveryToken'}),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return;
      }
      _handleResponseError(data, 'Failed to reset password');
    } catch (e) {
      _handleError(e, 'Failed to reset password');
    }
  }

  Never _handleError(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        throw ApiException(
          message: data['message']?.toString() ?? fallback,
          statusCode: error.response?.statusCode ?? 400,
          data: data,
          errorType: data['errorType']?.toString(),
          traceId: data['traceId']?.toString(),
        );
      }
      throw ApiException(
        message: error.message ?? fallback,
        statusCode: error.response?.statusCode ?? 500,
        data: error.response?.data,
      );
    }
    if (error is ApiException) {
      throw error;
    }
    throw ApiException(message: error.toString(), statusCode: 500);
  }

  Never _handleResponseError(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      throw ApiException(
        message: data['message']?.toString() ?? fallback,
        statusCode: 400,
        data: data,
        errorType: data['errorType']?.toString(),
        traceId: data['traceId']?.toString(),
      );
    }
    throw ApiException(message: fallback, statusCode: 400);
  }
}
