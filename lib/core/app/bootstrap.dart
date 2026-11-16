import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/shared/notifications/presentation/providers/notifications_provider.dart';
import '../constants/storage_keys.dart';
import '../localization/app_language.dart';
import '../localization/app_localization.dart';
import '../localization/localization_provider.dart';
import '../services/notification_service.dart';
import '../services/notification_socket_service.dart';
import '../session/session_manager.dart';
import '../storage/storage_provider.dart';
import '../utils/performance_monitor.dart';

Future<void> bootstrap({required Widget app}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bounded in-memory image cache to prevent OOM on lower-end (2GB-3GB RAM) devices
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50 MB

  PerformanceMonitor.start();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('Flutter error: ${details.exception}');
      debugPrintStack(stackTrace: details.stack);
    }
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Uncaught application error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return true;
  };

  // Initialize SharedPreferences & preload saved localization before ProviderScope.
  final sharedPreferences = await SharedPreferences.getInstance();
  final savedLangCode = sharedPreferences.getString(StorageKeys.selectedLanguage);
  final initialLanguage = AppLanguage.fromCode(savedLangCode);
  AppLanguageNotifier.activeLanguageCode = initialLanguage.code;
  await AppLocalization.load(initialLanguage);

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );

  final pushService = container.read(pushNotificationServiceProvider);
  final socketService = container.read(notificationSocketServiceProvider);
  final sessionManager = container.read(sessionManagerProvider);

  pushService.onTokenRotated = (_) async {
    if (container.read(authProvider).isAuthenticated) {
      await container.read(authProvider.notifier).heartbeatCheck(throttle: false);
    }
  };
  pushService.onNotificationOpened = () {
    if (container.read(authProvider).isAuthenticated) {
      container.read(notificationsProvider.notifier).refresh();
    }
  };

  sessionManager.registerAsyncCleanupCallback(() async {
    socketService.disconnect();
    await pushService.clearTokenOnLogout();
  });

  // Launch the application first (Stage 1 bootstrap) to minimize cold start time
  try {
    runApp(UncontrolledProviderScope(container: container, child: app));
  } catch (error, stackTrace) {
    debugPrint('Bootstrap error: $error');
    debugPrintStack(stackTrace: stackTrace);
    container.dispose();
    rethrow;
  }

  // Defer non-critical push notifications initialization after initial frame paint (Stage 2)
  Future.microtask(() async {
    try {
      await pushService.initialize().timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('PushNotificationService deferred bootstrap warning: $e');
    }
  });
}
