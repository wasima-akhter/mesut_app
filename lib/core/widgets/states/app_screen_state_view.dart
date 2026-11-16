import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'app_data_state.dart';
import 'app_empty_widget.dart';
import 'app_error_widget.dart';
import 'app_no_connection.dart';

class AppScreenStateView extends StatelessWidget {
  const AppScreenStateView({
    super.key,
    required this.status,
    required this.child,
    this.onRetry,
    this.loadingShimmer,
    this.emptyPlaceholder,
    this.errorMessage,
    this.errorObject,
  });

  final AppDataStatus status;
  final Widget child;
  final VoidCallback? onRetry;
  final Widget? loadingShimmer;
  final Widget? emptyPlaceholder;
  final String? errorMessage;
  final Object? errorObject;

  static bool isConnectionError(Object? err) {
    if (err is DioException) {
      return err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.sendTimeout ||
          err.type == DioExceptionType.receiveTimeout ||
          err.type == DioExceptionType.connectionError;
    }
    final str = err?.toString().toLowerCase() ?? '';
    return str.contains('socket') ||
        str.contains('network') ||
        str.contains('connection') ||
        str.contains('offline');
  }

  @override
  Widget build(BuildContext context) {
    if (status == AppDataStatus.noConnection || isConnectionError(errorObject)) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AppNoConnection(onRetry: onRetry),
        ),
      );
    }

    switch (status) {
      case AppDataStatus.initial:
      case AppDataStatus.loading:
        return loadingShimmer ??
            const Center(child: CircularProgressIndicator());

      case AppDataStatus.noConnection:
        return Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: AppNoConnection(onRetry: onRetry),
          ),
        );

      case AppDataStatus.error:
        return Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: AppErrorWidget(
              message: errorMessage,
              onRetry: onRetry,
            ),
          ),
        );

      case AppDataStatus.empty:
        return Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: emptyPlaceholder ?? AppEmptyWidget(onRetry: onRetry),
          ),
        );

      case AppDataStatus.refreshing:
      case AppDataStatus.loadingMore:
      case AppDataStatus.success:
        return child;
    }
  }
}
