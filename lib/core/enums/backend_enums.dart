import 'app_enum.dart';

/// Backend-aligned role enum matching API payloads (`EMPLOYEE`, `SITE_MANAGER`, `ADMIN`).
enum BackendRole {
  employee('EMPLOYEE'),
  siteManager('SITE_MANAGER'),
  admin('ADMIN');

  const BackendRole(this.serializedName);
  final String serializedName;

  static BackendRole fromString(
    String? raw, {
    BackendRole fallback = BackendRole.employee,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase().replaceAll(' ', '_');
    return BackendRole.values.firstWhere(
      (e) =>
          e.serializedName == normalized ||
          e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }

  static BackendRole fromUserRole(UserRole role) {
    switch (role) {
      case UserRole.siteManager:
        return BackendRole.siteManager;
      case UserRole.employee:
        return BackendRole.employee;
    }
  }

  UserRole toUserRole() {
    switch (this) {
      case BackendRole.siteManager:
      case BackendRole.admin:
        return UserRole.siteManager;
      case BackendRole.employee:
        return UserRole.employee;
    }
  }
}

/// Backend account status enum (`ACTIVE`, `INACTIVE`, `SUSPENDED`).
enum UserStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  suspended('SUSPENDED');

  const UserStatus(this.serializedName);
  final String serializedName;

  static UserStatus fromString(
    String? raw, {
    UserStatus fallback = UserStatus.active,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return UserStatus.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () => fallback,
    );
  }
}

/// Platform identifiers expected by auth endpoints (`ANDROID`, `IOS`, `WEB`).
enum DevicePlatform {
  android('ANDROID'),
  ios('IOS'),
  web('WEB');

  const DevicePlatform(this.serializedName);
  final String serializedName;
}

/// API failure errorType codes returned by the backend.
enum ApiErrorType {
  invalidCredentials('INVALID_CREDENTIALS'),
  userNotFound('USER_NOT_FOUND'),
  userInactive('USER_INACTIVE'),
  accountInactive('ACCOUNT_INACTIVE'),
  userSuspended('USER_SUSPENDED'),
  invalidOtp('INVALID_OTP'),
  otpExpired('OTP_EXPIRED'),
  duplicateData('DUPLICATE_DATA'),
  emailAlreadyExists('EMAIL_ALREADY_EXISTS'),
  phoneAlreadyExists('PHONE_ALREADY_EXISTS'),
  invalidJson('INVALID_JSON'),
  tokenInvalid('TOKEN_INVALID'),
  tokenExpired('TOKEN_EXPIRED'),
  tokenBlacklisted('TOKEN_BLACKLISTED'),
  sessionExpired('SESSION_EXPIRED'),
  unauthorized('UNAUTHORIZED'),
  forbidden('FORBIDDEN'),
  notFound('NOT_FOUND'),
  validationError('VALIDATION_ERROR'),
  fileTooLarge('FILE_TOO_LARGE'),
  invalidFileType('INVALID_FILE_TYPE'),
  rateLimitExceeded('RATE_LIMIT_EXCEEDED'),
  serverError('SERVER_ERROR'),
  networkError('NETWORK_ERROR'),
  unknown('UNKNOWN');

  const ApiErrorType(this.serializedName);
  final String serializedName;

  static ApiErrorType fromString(
    String? raw, {
    ApiErrorType fallback = ApiErrorType.unknown,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final normalized = raw.trim().toUpperCase();
    return ApiErrorType.values.firstWhere(
      (e) =>
          e.serializedName == normalized || e.name.toUpperCase() == normalized,
      orElse: () {
        if (normalized == 'ACCOUNT_INACTIVE' || normalized.contains('INACTIVE')) {
          return ApiErrorType.accountInactive;
        }
        if (normalized.contains('CREDENTIAL')) {
          return ApiErrorType.invalidCredentials;
        }
        if (normalized == 'DUPLICATE_DATA') {
          return ApiErrorType.duplicateData;
        }
        if (normalized.contains('USER') && normalized.contains('NOT_FOUND')) {
          return ApiErrorType.userNotFound;
        }
        if (normalized.contains('OTP') && normalized.contains('EXPIRED')) {
          return ApiErrorType.otpExpired;
        }
        if (normalized.contains('OTP')) {
          return ApiErrorType.invalidOtp;
        }
        if (normalized == 'TOKEN_INVALID') {
          return ApiErrorType.tokenInvalid;
        }
        if (normalized == 'TOKEN_BLACKLISTED') {
          return ApiErrorType.tokenBlacklisted;
        }
        if (normalized.contains('TOKEN') || normalized.contains('SESSION')) {
          return ApiErrorType.tokenExpired;
        }
        if (normalized.contains('AUTH') || normalized.contains('UNAUTHORIZED')) {
          return ApiErrorType.unauthorized;
        }
        if (normalized.contains('SERVER') || normalized.contains('INTERNAL')) {
          return ApiErrorType.serverError;
        }
        return fallback;
      },
    );
  }
}
