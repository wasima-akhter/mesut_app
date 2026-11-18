import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_spacing.dart';
import '../../errors/app_error_resolver.dart';
import '../../localization/context_extensions.dart';
import 'app_no_connection.dart';

/// Central error presentation widget that shields users from raw technical traces
/// and automatically presents clean, localized connection/offline or error states.
class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final Object? error;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData icon;
  final VoidCallback? onBack;
  final bool showBackButton;

  const AppErrorWidget({
    super.key,
    this.title,
    this.message,
    this.error,
    this.onRetry,
    this.retryText,
    this.icon = Icons.error_outline,
    this.onBack,
    this.showBackButton = false,
  });

  /// Central detector for network, offline, and connection errors.
  static bool isConnectionError(Object? err) {
    if (err == null) return false;
    if (err is DioException) {
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.sendTimeout ||
          err.type == DioExceptionType.receiveTimeout ||
          err.type == DioExceptionType.connectionError) {
        return true;
      }
      if (err.error != null && isConnectionError(err.error)) {
        return true;
      }
    }
    final str = err.toString().toLowerCase();
    return str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('no address associated with hostname') ||
        str.contains('network is unreachable') ||
        str.contains('connection error') ||
        str.contains('connection refused') ||
        str.contains('connection closed') ||
        str.contains('connection reset') ||
        str.contains('connection timed out') ||
        str.contains('connection timeout') ||
        str.contains('handshake failed') ||
        str.contains('network failure') ||
        str.contains('network_error') ||
        str.contains('offline') ||
        (str.contains('dioexception') && str.contains('connection'));
  }

  /// Central detector for unhandled technical error messages/stack traces.
  static bool isTechnicalError(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    final lower = text.toLowerCase();
    return lower.contains('dioexception') ||
        lower.contains('socketexception') ||
        lower.contains('httpexception') ||
        lower.contains('formatexception') ||
        lower.contains('stacktrace') ||
        lower.contains('requestoptions') ||
        lower.contains('validatestatus') ||
        lower.contains('client error') ||
        lower.contains('bad response') ||
        lower.contains('instance of') ||
        lower.contains('failed host lookup') ||
        text.startsWith('Exception: ') ||
        text.startsWith('Error: ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetError = error ?? message;

    // 1. Connection / Offline Error fallback:
    if (isConnectionError(error) || isConnectionError(message)) {
      return AppNoConnection(
        title: title,
        onRetry: onRetry,
        retryText: retryText,
        onBack: onBack,
        showBackButton: showBackButton,
      );
    }

    // 2. Resolve friendly, localized message maintaining dynamic language changes:
    final currentLang = Localizations.localeOf(context).languageCode;
    String displayTitle = title ?? context.loc.somethingWentWrong;
    String? displayMessage = message;

    if (error != null || isTechnicalError(message)) {
      final resolved = AppErrorResolver.resolve(
        targetError,
        languageCode: currentLang,
      );
      displayTitle = title ?? resolved.title;
      displayMessage = isTechnicalError(resolved.message)
          ? context.loc.somethingWentWrong
          : resolved.message;
    }

    final canNavigateBack = showBackButton || onBack != null || Navigator.of(context).canPop();

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.errorIconSize,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              displayTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (displayMessage != null && displayMessage.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (onRetry != null || canNavigateBack) ...[
              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canNavigateBack) ...[
                    OutlinedButton.icon(
                      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text(context.loc.back),
                    ),
                    if (onRetry != null) SizedBox(width: AppSpacing.sm),
                  ],
                  if (onRetry != null)
                    FilledButton(
                      onPressed: onRetry,
                      child: Text(retryText ?? context.loc.retry),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
