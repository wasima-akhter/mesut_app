import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

abstract final class DialogHelper {
  static Future<T?> showAppDialog<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: child),
        );
      },
    );
  }

  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(cancelText),
            ),
            FilledButton(
              onPressed: () => context.pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}
