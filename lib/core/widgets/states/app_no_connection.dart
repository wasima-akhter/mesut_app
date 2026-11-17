import 'package:flutter/material.dart';

import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_spacing.dart';
import '../../localization/context_extensions.dart';
import 'app_error_widget.dart';

class AppNoConnection extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData icon;

  const AppNoConnection({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.retryText,
    this.icon = Icons.wifi_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If a raw technical or connection error string was passed as message,
    // fallback cleanly to localized checkInternetConnection string.
    final effectiveMessage = (message != null &&
            !AppErrorWidget.isTechnicalError(message) &&
            !AppErrorWidget.isConnectionError(message))
        ? message!
        : context.loc.checkInternetConnection;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.emptyIconSize,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              title ?? context.loc.noInternetConnection,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              effectiveMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: onRetry,
                child: Text(retryText ?? context.loc.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
