import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Prevents duplicate concurrent HTTP requests to the same endpoint & locale.
class InFlightRequestInterceptor extends Interceptor {
  final Map<String, Completer<Response>> _inFlightRequests = {};

  bool isInFlight(String pathOrUrl, {String? method}) {
    final prefix = method != null ? '${method.toUpperCase()}:' : '';
    return _inFlightRequests.keys.any(
      (k) => (prefix.isEmpty || k.startsWith(prefix)) && k.contains(pathOrUrl),
    );
  }

  int get inFlightCount => _inFlightRequests.length;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipDedup'] == true) {
      handler.next(options);
      return;
    }

    final key = _generateRequestKey(options);

    final existing = _inFlightRequests[key];
    if (existing != null) {
      debugPrint(
        '[InFlightRequestInterceptor] Joining active request: ${options.method} ${options.uri}',
      );

      final cancelToken = options.cancelToken;
      void onCancel() {
        if (!handler.isCompleted) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              message:
                  'Request was cancelled while waiting for in-flight request',
            ),
          );
        }
      }

      cancelToken?.whenCancel.then((_) => onCancel());

      try {
        final response = await existing.future;
        if (cancelToken?.isCancelled == true) return;
        handler.resolve(
          Response(
            requestOptions: options,
            data: response.data,
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            headers: response.headers,
            isRedirect: response.isRedirect,
            redirects: response.redirects,
            extra: response.extra,
          ),
        );
      } on DioException catch (dioErr) {
        if (cancelToken?.isCancelled == true) return;
        handler.reject(
          DioException(
            requestOptions: options,
            response: dioErr.response,
            type: dioErr.type,
            error: dioErr.error,
            message: dioErr.message,
          ),
        );
      } catch (e) {
        if (cancelToken?.isCancelled == true) return;
        handler.reject(
          DioException(
            requestOptions: options,
            error: e,
            message: e.toString(),
          ),
        );
      }
      return;
    }

    _inFlightRequests[key] = Completer<Response>();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final key = _generateRequestKey(response.requestOptions);
    final completer = _inFlightRequests.remove(key);
    if (completer != null && !completer.isCompleted) {
      completer.complete(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final key = _generateRequestKey(err.requestOptions);
    final completer = _inFlightRequests.remove(key);
    if (completer != null && !completer.isCompleted) {
      completer.completeError(err);
    }
    handler.next(err);
  }

  String _generateRequestKey(RequestOptions options) {
    final locale = options.headers['x-locale'] ?? '';
    return '${options.method.toUpperCase()}:${options.uri}:$locale';
  }
}

