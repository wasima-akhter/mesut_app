import 'package:dio/dio.dart';

import '../enums/backend_enums.dart';
import '../network/api_exception.dart';
import 'app_error_resolver.dart';
import 'app_exception.dart';
import 'app_failure.dart';

abstract final class FailureMapper {
  static AppFailure fromException(Object exception) {
    if (exception is AppFailure) {
      return exception;
    }

    if (exception is DioException || exception is ApiException) {
      final userMsg = AppErrorResolver.resolve(exception);
      return _fromUserFriendlyMessage(userMsg);
    }

    if (exception is AppException) {
      return _fromAppException(exception);
    }

    final userMsg = AppErrorResolver.resolve(exception);
    return _fromUserFriendlyMessage(userMsg);
  }

  static AppFailure _fromUserFriendlyMessage(UserFriendlyMessage msg) {
    switch (msg.errorType) {
      case ApiErrorType.invalidCredentials:
      case ApiErrorType.userNotFound:
      case ApiErrorType.userInactive:
      case ApiErrorType.accountInactive:
      case ApiErrorType.userSuspended:
      case ApiErrorType.invalidOtp:
      case ApiErrorType.otpExpired:
        return AuthenticationFailure(
          title: msg.title,
          message: msg.message,
          directive: msg.directive,
          code: msg.errorType.serializedName,
        );
      case ApiErrorType.unauthorized:
      case ApiErrorType.tokenInvalid:
      case ApiErrorType.tokenExpired:
      case ApiErrorType.tokenBlacklisted:
      case ApiErrorType.sessionExpired:
      case ApiErrorType.sessionRevoked:
      case ApiErrorType.deviceNotFound:
      case ApiErrorType.deviceNotOwned:
        return UnauthorizedFailure(
          title: msg.title,
          message: msg.message,
          directive: msg.directive,
          code: msg.errorType.serializedName,
        );
      case ApiErrorType.forbidden:
      case ApiErrorType.accessDenied:
        return ForbiddenFailure(
          title: msg.title,
          message: msg.message,
          directive: msg.directive,
          code: msg.errorType.serializedName,
        );
      case ApiErrorType.notFound:
      case ApiErrorType.timelogNotFound:
        return NotFoundFailure(
          title: msg.title,
          message: msg.message,
          directive: msg.directive,
          code: msg.errorType.serializedName,
        );
      case ApiErrorType.invalidJson:
      case ApiErrorType.badRequest:
      case ApiErrorType.activeTimerExists:
      case ApiErrorType.validationError:
      case ApiErrorType.duplicateData:
      case ApiErrorType.emailAlreadyExists:
      case ApiErrorType.phoneAlreadyExists:
      case ApiErrorType.fileTooLarge:
      case ApiErrorType.invalidFileType:
        return BadRequestFailure(
          title: msg.title,
          message: msg.message,
          directive: msg.directive,
          code: msg.errorType.serializedName,
        );
      case ApiErrorType.networkError:
        return NetworkFailure(
          title: msg.title,
          message: msg.message,
          directive: msg.directive,
          code: msg.errorType.serializedName,
        );
      case ApiErrorType.serverError:
        return ServerFailure(
          title: msg.title,
          message: msg.message,
          directive: msg.directive,
          code: msg.errorType.serializedName,
        );
      case ApiErrorType.rateLimitExceeded:
      case ApiErrorType.unknown:
        return UnknownFailure(
          title: msg.title,
          message: msg.message,
          directive: msg.directive,
          code: msg.errorType.serializedName,
        );
    }
  }

  static AppFailure _fromAppException(AppException exception) {
    if (exception is CacheException) {
      return CacheFailure(message: exception.message, code: exception.code);
    }
    if (exception is DatabaseException) {
      return DatabaseFailure(message: exception.message, code: exception.code);
    }
    if (exception is StorageException) {
      return StorageFailure(message: exception.message, code: exception.code);
    }
    if (exception is SerializationException) {
      return UnknownFailure(
        title: 'Data Error',
        message: 'Unable to process the server response.',
        code: exception.code,
      );
    }

    final userMsg = AppErrorResolver.resolve(exception);
    return _fromUserFriendlyMessage(userMsg);
  }
}
