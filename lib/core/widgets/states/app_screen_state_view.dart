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

  static bool isConnectionError(Object? err) =>
      AppErrorWidget.isConnectionError(err);

  @override
  Widget build(BuildContext context) {
    final hasConnError = status == AppDataStatus.noConnection ||
        AppErrorWidget.isConnectionError(errorObject) ||
        AppErrorWidget.isConnectionError(errorMessage);

    if (hasConnError) {
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
              error: errorObject,
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
