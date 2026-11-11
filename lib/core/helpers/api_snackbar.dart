import '../errors/app_error_resolver.dart';
import '../localization/localization_provider.dart';
import '../widgets/snack/app_snackbar.dart';

abstract final class ApiSnackbar {
  static void showError(Object error, {String? directive}) {
    final resolved = AppErrorResolver.resolve(
      error,
      languageCode: AppLanguageNotifier.activeLanguageCode,
      fallbackDirective: directive,
    );
    final msg = resolved.directive != null && resolved.directive!.isNotEmpty
        ? '${resolved.message}\n${resolved.directive}'
        : resolved.message;
    AppSnackBar.error(msg, title: resolved.title);
  }

  static void showSuccess(String message, {String? title}) {
    AppSnackBar.success(message, title: title);
  }

  static void showInfo(String message, {String? title}) {
    AppSnackBar.info(message, title: title);
  }
}
