import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/enums/app_enum.dart';
import '../../../../core/enums/backend_enums.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/jwt_helper.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../dtos/auth_request_dtos.dart';
import '../dtos/recovery_dtos.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  }) {
    _loadCachedUser();
  }

  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthUser? _currentUser;

  void _loadCachedUser() {
    final cached = storageService.getCurrentUserJson();
    if (cached != null && cached.isNotEmpty) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        _currentUser = AuthUserModel.fromJson(map);
      } catch (_) {}
    }
  }

  @override
  AuthUser? getCurrentUser() => _currentUser;

  @override
  Future<String> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final request = SignupRequestDto(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      role: role,
      password: password,
    );

    final otpPageToken = await remoteDataSource.signUp(request);
    await storageService.saveOtpPageToken(otpPageToken);
    await storageService.saveUserRole(
      BackendRole.fromUserRole(role).serializedName,
    );
    await storageService.saveUserEmail(email);
    return otpPageToken;
  }

  @override
  Future<AuthSession> verifyOtp({
    required String otp,
    required String deviceIdentifier,
    String? fcmToken,
    double? lat,
    double? lng,
    String? otpPageToken,
  }) async {
    final token = (otpPageToken != null && otpPageToken.isNotEmpty)
        ? otpPageToken
        : await storageService.getOtpPageToken();
    final request = VerifyOtpRequestDto(
      otp: otp,
      deviceIdentifier: deviceIdentifier,
      fcmToken: fcmToken,
      lat: lat,
      lng: lng,
    );

    var session = await remoteDataSource.verifyOtp(
      request: request,
      otpPageToken: token,
    );

    final emailFromToken = JwtHelper.extractEmail(session.accessToken);
    final storedEmail = storageService.getUserEmail();
    final effectiveEmail =
        session.user.email.isNotEmpty
            ? session.user.email
            : ((emailFromToken != null && emailFromToken.isNotEmpty)
                  ? emailFromToken
                  : (storedEmail ?? ''));

    if (effectiveEmail.isNotEmpty) {
      session = session.copyWith(
        user: session.user.copyWith(email: effectiveEmail),
      );
      await storageService.saveUserEmail(effectiveEmail);
    }

    await storageService.saveAccessToken(session.accessToken);
    await storageService.saveCurrentUserJson(
      jsonEncode(AuthUserModel.fromEntity(session.user).toJson()),
    );
    await storageService.saveUserRole(
      BackendRole.fromUserRole(session.user.role).serializedName,
    );
    await storageService.clearOtpPageToken();

    _currentUser = session.user;
    return session;
  }

  @override
  Future<void> resendOtp({String? otpPageToken}) async {
    final token = (otpPageToken != null && otpPageToken.isNotEmpty)
        ? otpPageToken
        : await storageService.getOtpPageToken();
    final newToken = await remoteDataSource.resendOtp(otpPageToken: token);
    if (newToken != null && newToken.isNotEmpty) {
      await storageService.saveOtpPageToken(newToken);
    }
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required UserRole role,
    required String deviceIdentifier,
    bool rememberMe = false,
    String? fcmToken,
    double? lat,
    double? lng,
  }) async {
    final request = LoginRequestDto(
      email: email,
      password: password,
      role: role,
      deviceIdentifier: deviceIdentifier,
      rememberMe: rememberMe,
      fcmToken: fcmToken,
      lat: lat,
      lng: lng,
    );

    var session = await remoteDataSource.login(request);

    final emailFromToken = JwtHelper.extractEmail(session.accessToken);
    final effectiveEmail =
        session.user.email.isNotEmpty
            ? session.user.email
            : ((emailFromToken != null && emailFromToken.isNotEmpty)
                  ? emailFromToken
                  : email);

    session = session.copyWith(
      user: session.user.copyWith(email: effectiveEmail),
    );

    await storageService.saveUserEmail(effectiveEmail);
    await storageService.saveAccessToken(session.accessToken);
    await storageService.saveCurrentUserJson(
      jsonEncode(AuthUserModel.fromEntity(session.user).toJson()),
    );
    await storageService.saveUserRole(
      BackendRole.fromUserRole(session.user.role).serializedName,
    );
    await storageService.setRememberMe(rememberMe);

    if (session.user.isInactive && session.accessToken.isNotEmpty) {
      await storageService.saveOtpPageToken(session.accessToken);
    }

    if (rememberMe) {
      await storageService.setRememberedEmail(effectiveEmail);
    }

    _currentUser = session.user;
    return session;
  }

  @override
  Future<AuthUser?> checkSession({
    required String deviceIdentifier,
    String? fcmToken,
    double? lat,
    double? lng,
  }) async {
    final isValid = await storageService.hasValidAccessToken();
    if (!isValid) {
      final hasToken = await storageService.hasAccessToken();
      if (hasToken) {
        await storageService.clearAuthentication();
      }
      _currentUser = null;
      return null;
    }

    final token = await storageService.getAccessToken();
    final emailFromToken = JwtHelper.extractEmail(token);
    if (emailFromToken != null && emailFromToken.isNotEmpty) {
      await storageService.saveUserEmail(emailFromToken);
    }

    try {
      final remoteUser = await remoteDataSource.checkSession(
        CheckSessionRequestDto(
          deviceIdentifier: deviceIdentifier,
          fcmToken: fcmToken,
          lat: lat,
          lng: lng,
        ),
      );

      // `/auth/check` may return `{ success: true, message: ... }` with no `data` payload;
      // in that case keep cached user or reconstruct from JWT claims.
      AuthUser resolvedUser;
      if (remoteUser != null) {
        resolvedUser = remoteUser;
      } else if (_currentUser != null) {
        resolvedUser = _currentUser!;
      } else {
        final roleFromToken = BackendRole.fromString(
          JwtHelper.extractRole(token) ?? storageService.getUserRole(),
        ).toUserRole();
        resolvedUser = AuthUser(
          id: JwtHelper.extractUserId(token) ?? '',
          fullName: '',
          email: emailFromToken ?? storageService.getUserEmail() ?? '',
          role: roleFromToken,
        );
      }

      await storageService.saveCurrentUserJson(
        jsonEncode(AuthUserModel.fromEntity(resolvedUser).toJson()),
      );
      await storageService.saveUserRole(
        BackendRole.fromUserRole(resolvedUser.role).serializedName,
      );
      _currentUser = resolvedUser;
      return resolvedUser;
    } catch (e) {
      final isAuthError =
          (e is ApiException &&
              (e.statusCode == 401 ||
                  e.statusCode == 403 ||
                  e.errorType == 'TOKEN_INVALID' ||
                  e.errorType == 'TOKEN_EXPIRED' ||
                  e.errorType == 'TOKEN_BLACKLISTED' ||
                  e.errorType == 'UNAUTHORIZED' ||
                  e.errorType == 'USER_SUSPENDED')) ||
          (e is DioException &&
              (e.response?.statusCode == 401 || e.response?.statusCode == 403));

      if (isAuthError) {
        await storageService.clearAuthentication();
        _currentUser = null;
        return null;
      }

      // Offline startup fallback if token is valid locally.
      if (_currentUser != null) {
        return _currentUser;
      }
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {}
    await storageService.logout();
    _currentUser = null;
  }

  @override
  Future<RecoverUserData> findUserForRecovery({required String email}) async {
    final userData = await remoteDataSource.findUserForRecovery(email);
    if (userData.token.isNotEmpty) {
      await storageService.savePasswordResetToken(userData.token);
    }
    return userData;
  }

  @override
  Future<String> resendRecoveryOtp({String? recoveryToken}) async {
    final token =
        (recoveryToken != null && recoveryToken.isNotEmpty)
            ? recoveryToken
            : await storageService.getPasswordResetToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        message: 'Recovery session expired, please request OTP again',
        statusCode: 401,
        errorType: 'TOKEN_EXPIRED',
      );
    }
    return remoteDataSource.resendRecoveryOtp(recoveryToken: token);
  }

  @override
  Future<bool> verifyRecoveryOtp({
    required String otp,
    String? recoveryToken,
  }) async {
    final token =
        (recoveryToken != null && recoveryToken.isNotEmpty)
            ? recoveryToken
            : await storageService.getPasswordResetToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        message: 'Recovery session expired, please request OTP again',
        statusCode: 401,
        errorType: 'TOKEN_EXPIRED',
      );
    }
    return remoteDataSource.verifyRecoveryOtp(otp: otp, recoveryToken: token);
  }

  @override
  Future<void> resetPasswordWithRecoveryToken({
    required String password,
    required String confirmPassword,
    String? recoveryToken,
  }) async {
    final token =
        (recoveryToken != null && recoveryToken.isNotEmpty)
            ? recoveryToken
            : await storageService.getPasswordResetToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        message: 'Recovery session expired, please request OTP again',
        statusCode: 401,
        errorType: 'TOKEN_EXPIRED',
      );
    }
    await remoteDataSource.resetPasswordWithRecoveryToken(
      password: password,
      confirmPassword: confirmPassword,
      recoveryToken: token,
    );
    await storageService.clearPasswordResetToken();
  }
}
