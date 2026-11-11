import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      debugPrint('');
      debugPrint('══════════════════════════════════════════════════════');
      debugPrint('API REQUEST');
      debugPrint('══════════════════════════════════════════════════════');
      debugPrint('METHOD : ${options.method}');
      debugPrint('URL    : ${options.uri}');
      debugPrint('QUERY  : ${options.queryParameters}');
      debugPrint('HEADERS: ${_redactHeaders(options.headers)}');

      if (!_isSensitiveEndpoint(options.path) && options.data != null) {
        debugPrint('BODY   : ${options.data}');
      }

      final callerStackTrace = options.extra['callerStackTrace'] as StackTrace?;
      if (callerStackTrace != null) {
        debugPrint('──────────── REQUEST STACK TRACE ────────────');
        debugPrint(callerStackTrace.toString());
      }
      debugPrint('══════════════════════════════════════════════════════');

      return true;
    }());

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    assert(() {
      debugPrint('');
      debugPrint('══════════════════════════════════════════════════════');
      debugPrint('API RESPONSE');
      debugPrint('══════════════════════════════════════════════════════');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('METHOD : ${response.requestOptions.method}');
      debugPrint('URL    : ${response.requestOptions.uri}');
      debugPrint('BODY   : ${response.data}');
      debugPrint('══════════════════════════════════════════════════════');

      return true;
    }());

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      final statusCode = err.response?.statusCode;
      final url = err.requestOptions.uri.toString();
      final method = err.requestOptions.method;
      final callerStackTrace =
          err.requestOptions.extra['callerStackTrace'] as StackTrace?;

      String errorOrigin;
      String diagnosis;

      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.sendTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        errorOrigin = 'NETWORK / TIMEOUT';
        diagnosis =
            'Connection timed out. Check network connection or server availability.';
      } else if (err.type == DioExceptionType.connectionError) {
        errorOrigin = 'NETWORK / OFFLINE';
        diagnosis =
            'Failed to connect to host. Server may be unreachable or device is offline.';
      } else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        errorOrigin = 'FRONTEND / CLIENT ISSUE (HTTP $statusCode)';
        if (statusCode == 422) {
          final resData = err.response?.data;
          final errorsList = resData is Map ? resData['errors'] : null;
          if (errorsList is List && errorsList.isNotEmpty) {
            final buffer = StringBuffer(
              'Request validation failed on specific fields:\n',
            );
            for (final e in errorsList) {
              if (e is Map) {
                buffer.writeln('    • Field "${e['field']}": ${e['message']}');
              }
            }
            diagnosis = buffer.toString().trimRight();
          } else {
            diagnosis = 'Validation failed (422).';
          }
        } else if (statusCode == 400) {
          final resData = err.response?.data;
          final msg = resData is Map ? resData['message'] : null;
          diagnosis = 'Bad Request (400): ${msg ?? 'Invalid request'}.';
        } else if (statusCode == 401) {
          diagnosis =
              'Authentication Error (401). Token missing, expired, or invalid.';
        } else if (statusCode == 403) {
          diagnosis = 'Forbidden (403). Role or account status restricted.';
        } else if (statusCode == 404) {
          diagnosis = 'Not Found (404). Resource not found.';
        } else {
          diagnosis = 'Client error: HTTP $statusCode';
        }
      } else if (statusCode != null && statusCode >= 500) {
        errorOrigin = 'BACKEND / SERVER FAILURE (HTTP $statusCode)';
        diagnosis =
            'Internal server error on backend. Inspect backend logs using traceId.';
      } else {
        errorOrigin = 'UNKNOWN / CLIENT EXCEPTION';
        diagnosis = err.message ?? 'Unknown error';
      }

      String callerLocation = 'Unknown call site';
      if (callerStackTrace != null) {
        final frames = callerStackTrace.toString().split('\n');
        for (final frame in frames) {
          if (frame.contains('package:construction_app/') &&
              !frame.contains('api_client.dart') &&
              !frame.contains('logging_interceptor.dart') &&
              !frame.contains('dio_client.dart')) {
            callerLocation = frame.trim();
            break;
          }
        }
      }

      String? backendTraceId;
      final resData = err.response?.data;
      if (resData is Map && resData.containsKey('traceId')) {
        backendTraceId = resData['traceId']?.toString();
      }

      debugPrint('');
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('API ERROR DIAGNOSTIC');
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('ORIGIN    : $errorOrigin');
      debugPrint('DIAGNOSIS : $diagnosis');
      debugPrint('METHOD    : $method');
      debugPrint('URL       : $url');
      debugPrint('CALL SITE : $callerLocation');
      if (backendTraceId != null) {
        debugPrint('TRACE ID  : $backendTraceId');
      }
      debugPrint('STATUS    : ${err.response?.statusCode}');
      debugPrint('BODY      : ${err.response?.data}');
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('');

      return true;
    }());

    handler.next(err);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization')) {
      copy['Authorization'] = 'Bearer ***';
    }
    return copy;
  }

  bool _isSensitiveEndpoint(String path) {
    const sensitiveEndpoints = <String>{
      '/auth/login',
      '/auth/signup',
      '/recover/reset',
      '/admin/recover/reset',
    };

    return sensitiveEndpoints.any((e) => path.endsWith(e));
  }
}
