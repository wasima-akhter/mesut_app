import 'package:dio/dio.dart';

import '../enums/backend_enums.dart';
import '../localization/localization_provider.dart';
import '../network/api_exception.dart';
import 'app_failure.dart';

/// User-facing structured error payload separating clean communication from raw traces.
class UserFriendlyMessage {
  final String title;
  final String message;
  final String? directive;
  final ApiErrorType errorType;
  final String? traceId;
  final List<String>? errors;
  final dynamic rawSource;

  const UserFriendlyMessage({
    required this.title,
    required this.message,
    this.directive,
    this.errorType = ApiErrorType.unknown,
    this.traceId,
    this.errors,
    this.rawSource,
  });

  String get displayMessage => message;

  @override
  String toString() => displayMessage;
}

/// Resolves backend responses, Dio exceptions, and domain failures into localized EN/DE messages.
class AppErrorResolver {
  const AppErrorResolver._();

  static UserFriendlyMessage resolve(
    Object? error, {
    String? languageCode,
    String? fallbackDirective,
  }) {
    final effectiveLang =
        languageCode ?? AppLanguageNotifier.activeLanguageCode;
    final isGerman = _isGerman(effectiveLang);

    if (error == null) {
      return _buildMessage(
        type: ApiErrorType.unknown,
        isGerman: isGerman,
        customDirective: fallbackDirective,
      );
    }

    if (error is ApiErrorType) {
      return _buildMessage(
        type: error,
        isGerman: isGerman,
        customDirective: fallbackDirective,
      );
    }

    if (error is UserFriendlyMessage) {
      if (languageCode != null && error.rawSource != null) {
        return resolve(
          error.rawSource,
          languageCode: languageCode,
          fallbackDirective: fallbackDirective ?? error.directive,
        );
      }
      return error;
    }

    if (error is Map) {
      return _fromBackendMap(
        Map<String, dynamic>.from(error),
        isGerman: isGerman,
        customDirective: fallbackDirective,
      );
    }

    if (error is DioException) {
      return _fromDioException(
        error,
        isGerman: isGerman,
        customDirective: fallbackDirective,
      );
    }

    if (error is ApiException) {
      return _fromApiException(
        error,
        isGerman: isGerman,
        customDirective: fallbackDirective,
      );
    }

    if (error is AppFailure) {
      return _fromAppFailure(
        error,
        isGerman: isGerman,
        customDirective: fallbackDirective,
      );
    }

    return _fromString(
      error.toString(),
      isGerman: isGerman,
      customDirective: fallbackDirective,
    );
  }

  static bool _isGerman(String? languageCode) {
    if (languageCode == null) return false;
    return languageCode.toLowerCase().startsWith('de');
  }

  static UserFriendlyMessage _fromBackendMap(
    Map<String, dynamic> data, {
    required bool isGerman,
    String? customDirective,
  }) {
    final rawErrorType = data['errorType']?.toString();
    final rawMessage = data['message']?.toString();
    final traceId = data['traceId']?.toString();
    final rawErrors = data['errors'];
    final rawStatusCode = data['statusCode'] ?? data['status'];
    final parsedStatus = rawStatusCode is int
        ? rawStatusCode
        : (int.tryParse(rawStatusCode?.toString() ?? '') ?? 0);

    if (parsedStatus >= 500 ||
        rawErrorType == 'INTERNAL_SERVER_ERROR' ||
        rawErrorType == 'SERVER_ERROR' ||
        (rawErrorType != null &&
            (rawErrorType.contains('SERVER') ||
                rawErrorType.contains('INTERNAL')))) {
      return _buildMessage(
        type: ApiErrorType.serverError,
        isGerman: isGerman,
        customDirective: customDirective,
        traceId: traceId,
      );
    }

    final cleanMessage = _sanitizeMessage(rawMessage);

    if (rawErrors != null) {
      final parsedErrors = _parseRawErrors(rawErrors, isGerman: isGerman);
      final title = isGerman ? 'Validierungsfehler' : 'Validation Error';
      final fallbackMsg = isGerman
          ? 'Einige Pflichtfelder fehlen oder sind ungültig.'
          : 'Some required fields are missing or contain invalid values.';

      return UserFriendlyMessage(
        title: title,
        message: cleanMessage ?? fallbackMsg,
        directive: customDirective,
        errorType: ApiErrorType.validationError,
        traceId: traceId,
        errors: parsedErrors.isEmpty ? null : parsedErrors,
        rawSource: data,
      );
    }

    if (rawMessage != null &&
        (rawMessage.toLowerCase().contains('validation failed') ||
            rawMessage.toLowerCase().contains('validation error'))) {
      return UserFriendlyMessage(
        title: isGerman ? 'Validierungsfehler' : 'Validation Error',
        message: cleanMessage ??
            (isGerman
                ? 'Einige Pflichtfelder fehlen oder sind ungültig.'
                : 'Some required fields are missing or contain invalid values.'),
        directive: customDirective,
        errorType: ApiErrorType.validationError,
        traceId: traceId,
        rawSource: data,
      );
    }

    final errorType = ApiErrorType.fromString(rawErrorType);

    final msg = _buildMessage(
      type: errorType,
      isGerman: isGerman,
      customMessage: cleanMessage,
      customDirective: customDirective,
      traceId: traceId,
    );

    return UserFriendlyMessage(
      title: msg.title,
      message: cleanMessage ?? msg.message,
      directive: msg.directive,
      errorType: msg.errorType,
      traceId: msg.traceId,
      rawSource: data,
    );
  }

  static UserFriendlyMessage _fromDioException(
    DioException dioError, {
    required bool isGerman,
    String? customDirective,
  }) {
    if (dioError.error is UserFriendlyMessage) {
      return dioError.error as UserFriendlyMessage;
    }

    final response = dioError.response;
    final status = response?.statusCode ?? 0;

    if (status >= 500) {
      return _buildMessage(
        type: ApiErrorType.serverError,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }

    if (response != null && response.data is Map) {
      return _fromBackendMap(
        Map<String, dynamic>.from(response.data as Map),
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return _buildMessage(
          type: ApiErrorType.networkError,
          isGerman: isGerman,
          customDirective: customDirective,
        );
      case DioExceptionType.badResponse:
        if (status == 401) {
          return _buildMessage(
            type: ApiErrorType.unauthorized,
            isGerman: isGerman,
            customDirective: customDirective,
          );
        } else if (status == 403) {
          return _buildMessage(
            type: ApiErrorType.forbidden,
            isGerman: isGerman,
            customDirective: customDirective,
          );
        } else if (status == 404) {
          return _buildMessage(
            type: ApiErrorType.notFound,
            isGerman: isGerman,
            customDirective: customDirective,
          );
        } else if (status == 409) {
          return _buildMessage(
            type: ApiErrorType.duplicateData,
            isGerman: isGerman,
            customDirective: customDirective,
          );
        } else if (status == 422) {
          return _buildMessage(
            type: ApiErrorType.validationError,
            isGerman: isGerman,
            customDirective: customDirective,
          );
        } else if (status == 429) {
          return _buildMessage(
            type: ApiErrorType.rateLimitExceeded,
            isGerman: isGerman,
            customDirective: customDirective,
          );
        }
        return _buildMessage(
          type: ApiErrorType.unknown,
          isGerman: isGerman,
          customDirective: customDirective,
        );
      case DioExceptionType.cancel:
        return _buildMessage(
          type: ApiErrorType.unknown,
          isGerman: isGerman,
          customMessage: isGerman
              ? 'Die Anfrage wurde abgebrochen.'
              : 'The request was cancelled.',
          customDirective: customDirective,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return _buildMessage(
          type: ApiErrorType.networkError,
          isGerman: isGerman,
          customDirective: customDirective,
        );
    }
  }

  static UserFriendlyMessage _fromApiException(
    ApiException apiException, {
    required bool isGerman,
    String? customDirective,
  }) {
    if (apiException.statusCode >= 500) {
      return _buildMessage(
        type: ApiErrorType.serverError,
        isGerman: isGerman,
        customDirective: customDirective,
        traceId: apiException.traceId,
      );
    }

    if (apiException.data is Map) {
      return _fromBackendMap(
        Map<String, dynamic>.from(apiException.data as Map),
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }

    if (apiException.errorType != null) {
      return _buildMessage(
        type: ApiErrorType.fromString(apiException.errorType),
        isGerman: isGerman,
        customMessage: _sanitizeMessage(apiException.rawMessage),
        customDirective: customDirective,
        traceId: apiException.traceId,
      );
    }

    return _fromString(
      apiException.message,
      isGerman: isGerman,
      customDirective: customDirective,
    );
  }

  static UserFriendlyMessage _fromAppFailure(
    AppFailure failure, {
    required bool isGerman,
    String? customDirective,
  }) {
    if (failure is UnauthorizedFailure) {
      return _buildMessage(
        type: ApiErrorType.unauthorized,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return _buildMessage(
        type: ApiErrorType.networkError,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (failure is ForbiddenFailure) {
      return _buildMessage(
        type: ApiErrorType.forbidden,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (failure is NotFoundFailure) {
      return _buildMessage(
        type: ApiErrorType.notFound,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (failure is ServerFailure) {
      return _buildMessage(
        type: ApiErrorType.serverError,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    return _fromString(
      failure.userMessage,
      isGerman: isGerman,
      customDirective: customDirective,
    );
  }

  static UserFriendlyMessage _fromString(
    String raw, {
    required bool isGerman,
    String? customDirective,
  }) {
    final lower = raw.toLowerCase();

    if (lower.contains('invalid credential') ||
        lower.contains('wrong password') ||
        lower.contains('check your email and password')) {
      return _buildMessage(
        type: ApiErrorType.invalidCredentials,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (lower.contains('user with this email already exist') ||
        lower.contains('already exist') ||
        lower.contains('duplicate')) {
      return _buildMessage(
        type: ApiErrorType.duplicateData,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (lower.contains('invalid otp')) {
      return _buildMessage(
        type: ApiErrorType.invalidOtp,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (lower.contains('token has been expired') ||
        lower.contains('token expired') ||
        lower.contains('session expired')) {
      return _buildMessage(
        type: ApiErrorType.tokenExpired,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (lower.contains('suspended')) {
      return _buildMessage(
        type: ApiErrorType.userSuspended,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (lower.contains('user not found') ||
        lower.contains('user with the email is not found')) {
      return _buildMessage(
        type: ApiErrorType.userNotFound,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }
    if (lower.contains('socketexception') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('timeout')) {
      return _buildMessage(
        type: ApiErrorType.networkError,
        isGerman: isGerman,
        customDirective: customDirective,
      );
    }

    return _buildMessage(
      type: ApiErrorType.unknown,
      isGerman: isGerman,
      customMessage: _sanitizeMessage(raw),
      customDirective: customDirective,
    );
  }

  static List<String> _parseRawErrors(
    dynamic rawErrors, {
    required bool isGerman,
  }) {
    final results = <String>[];
    if (rawErrors is List) {
      for (final item in rawErrors) {
        if (item is Map) {
          final msg = item['message']?.toString().trim();
          final field = item['field']?.toString().trim();
          if (msg != null && msg.isNotEmpty) {
            results.add(field != null && field.isNotEmpty ? '$field: $msg' : msg);
          }
        } else if (item != null && item.toString().trim().isNotEmpty) {
          results.add(item.toString().trim());
        }
      }
    } else if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          results.add('$key: ${value.toString().trim()}');
        }
      });
    }
    return results;
  }

  static String? _sanitizeMessage(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var cleaned = raw.trim();
    if (cleaned.startsWith('Exception: ')) {
      cleaned = cleaned.substring(11).trim();
    }
    if (cleaned.startsWith('ApiException: ')) {
      cleaned = cleaned.substring(14).trim();
    }
    if (cleaned.contains('DioException') ||
        cleaned.contains('StackTrace') ||
        cleaned.contains('SocketException')) {
      return null;
    }
    return cleaned.isEmpty ? null : cleaned;
  }

  static UserFriendlyMessage _buildMessage({
    required ApiErrorType type,
    required bool isGerman,
    String? customMessage,
    String? customDirective,
    String? traceId,
  }) {
    switch (type) {
      case ApiErrorType.invalidCredentials:
        return UserFriendlyMessage(
          title: isGerman ? 'Anmeldung fehlgeschlagen' : 'Sign In Failed',
          message: isGerman
              ? 'Ungültige E-Mail-Adresse, falsches Passwort oder falsche Rolle.'
              : 'Invalid email, password, or selected role.',
          directive:
              customDirective ??
              (isGerman
                  ? 'Bitte überprüfen Sie Ihre Zugangsdaten und gewählte Rolle.'
                  : 'Please check your credentials and selected role.'),
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.userNotFound:
        return UserFriendlyMessage(
          title: isGerman ? 'Konto nicht gefunden' : 'Account Not Found',
          message: isGerman
              ? 'Es wurde kein Konto mit dieser E-Mail-Adresse gefunden.'
              : 'No account was found with this email address.',
          directive:
              customDirective ??
              (isGerman
                  ? 'Bitte prüfen Sie Ihre E-Mail-Adresse oder registrieren Sie sich.'
                  : 'Please verify your email address or sign up.'),
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.userInactive:
      case ApiErrorType.accountInactive:
        return UserFriendlyMessage(
          title: isGerman ? 'Verifizierung erforderlich' : 'Verification Required',
          message: isGerman
              ? 'Ihr Konto ist noch nicht aktiviert.'
              : 'Your account has not been verified yet.',
          directive:
              customDirective ??
              (isGerman
                  ? 'Bitte schließen Sie die E-Mail-Bestätigung per OTP-Code ab.'
                  : 'Please complete email verification with your OTP code.'),
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.userSuspended:
        return UserFriendlyMessage(
          title: isGerman ? 'Konto gesperrt' : 'Account Suspended',
          message: isGerman
              ? 'Ihr Konto wurde vorübergehend gesperrt.'
              : 'Your account has been suspended.',
          directive:
              customDirective ??
              (isGerman
                  ? 'Bitte wenden Sie sich an Ihren Bauleiter oder Administrator.'
                  : 'Please contact your site manager or administrator.'),
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.invalidOtp:
        return UserFriendlyMessage(
          title: isGerman ? 'Ungültiger Code' : 'Invalid OTP Code',
          message: isGerman
              ? 'Der eingegebene 6-stellige Code ist ungültig.'
              : 'The 6-digit verification code is incorrect.',
          directive:
              customDirective ??
              (isGerman
                  ? 'Bitte prüfen Sie den Code oder fordern Sie einen neuen an.'
                  : 'Please check the code or request a new one.'),
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.otpExpired:
        return UserFriendlyMessage(
          title: isGerman ? 'Code abgelaufen' : 'OTP Expired',
          message: isGerman
              ? 'Ihr Bestätigungscode ist abgelaufen.'
              : 'Your verification code has expired.',
          directive:
              customDirective ??
              (isGerman
                  ? 'Bitte fordern Sie einen neuen Code an.'
                  : 'Please tap Resend Code to get a new one.'),
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.duplicateData:
      case ApiErrorType.emailAlreadyExists:
        return UserFriendlyMessage(
          title: isGerman ? 'Konto existiert bereits' : 'Account Already Exists',
          message: isGerman
              ? 'Ein Benutzer mit dieser E-Mail-Adresse existiert bereits.'
              : 'A user with this email address already exists.',
          directive:
              customDirective ??
              (isGerman
                  ? 'Bitte melden Sie sich an oder verwenden Sie eine andere E-Mail.'
                  : 'Please sign in or use a different email address.'),
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.phoneAlreadyExists:
        return UserFriendlyMessage(
          title: isGerman ? 'Telefonnummer vergeben' : 'Phone Already Exists',
          message: isGerman
              ? 'Diese Telefonnummer wird bereits verwendet.'
              : 'This phone number is already registered.',
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.tokenInvalid:
      case ApiErrorType.tokenExpired:
      case ApiErrorType.tokenBlacklisted:
      case ApiErrorType.sessionExpired:
      case ApiErrorType.sessionRevoked:
      case ApiErrorType.deviceNotFound:
      case ApiErrorType.deviceNotOwned:
      case ApiErrorType.unauthorized:
        return UserFriendlyMessage(
          title: isGerman ? 'Sitzung abgelaufen' : 'Session Expired',
          message: isGerman
              ? 'Ihre Sitzung ist abgelaufen oder ungültig.'
              : 'Your session has expired or is no longer valid.',
          directive:
              customDirective ??
              (isGerman
                  ? 'Bitte melden Sie sich erneut an.'
                  : 'Please sign in again to continue.'),
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.forbidden:
      case ApiErrorType.accessDenied:
        return UserFriendlyMessage(
          title: isGerman ? 'Zugriff verweigert' : 'Access Denied',
          message: customMessage ??
              (isGerman
                  ? 'Sie haben keine Berechtigung für diese Aktion.'
                  : 'You do not have permission to perform this action.'),
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.activeTimerExists:
        return UserFriendlyMessage(
          title: isGerman ? 'Timer bereits aktiv' : 'Active Timer Exists',
          message: customMessage ??
              (isGerman
                  ? 'Es läuft bereits ein Timer. Bitte stoppen Sie ihn zuerst.'
                  : 'Another timer is already running. Please stop it first.'),
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.timelogNotFound:
      case ApiErrorType.notFound:
        return UserFriendlyMessage(
          title: isGerman ? 'Nicht gefunden' : 'Not Found',
          message: customMessage ??
              (isGerman
                  ? 'Die angeforderte Ressource wurde nicht gefunden.'
                  : 'The requested resource was not found.'),
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.badRequest:
      case ApiErrorType.invalidJson:
      case ApiErrorType.validationError:
        return UserFriendlyMessage(
          title: isGerman ? 'Validierungsfehler' : 'Validation Error',
          message: isGerman
              ? 'Einige Pflichtfelder fehlen oder sind ungültig.'
              : 'Some required fields are missing or contain invalid values.',
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.fileTooLarge:
        return UserFriendlyMessage(
          title: isGerman ? 'Datei zu groß' : 'File Too Large',
          message: isGerman
              ? 'Die ausgewählte Datei überschreitet das Limit von 50 MB.'
              : 'The selected file exceeds the 50 MB limit.',
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.invalidFileType:
        return UserFriendlyMessage(
          title: isGerman ? 'Ungültiger Dateityp' : 'Invalid File Type',
          message: isGerman
              ? 'Dieses Dateiformat wird nicht unterstützt.'
              : 'This file format is not supported.',
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.rateLimitExceeded:
        return UserFriendlyMessage(
          title: isGerman ? 'Zu viele Anfragen' : 'Too Many Requests',
          message: isGerman
              ? 'Sie haben zu viele Anfragen gesendet. Bitte warten Sie einen Moment.'
              : 'Too many requests. Please wait a moment before trying again.',
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.networkError:
        return UserFriendlyMessage(
          title: isGerman ? 'Verbindungsfehler' : 'Connection Error',
          message: isGerman
              ? 'Keine Verbindung zum Server möglich. Bitte prüfen Sie Ihre Internetverbindung.'
              : 'Unable to reach the server. Please check your internet connection.',
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.serverError:
        return UserFriendlyMessage(
          title: isGerman ? 'Serverfehler' : 'Server Error',
          message: ApiException.getFriendlyServerError(isGerman ? 'de' : 'en'),
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
      case ApiErrorType.unknown:
        return UserFriendlyMessage(
          title: isGerman ? 'Fehler' : 'Error',
          message: customMessage ??
              (isGerman
                  ? 'Ein unerwarteter Fehler ist aufgetreten.'
                  : 'An unexpected error occurred.'),
          directive: customDirective,
          errorType: type,
          traceId: traceId,
        );
    }
  }
}
