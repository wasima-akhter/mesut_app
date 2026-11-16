import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/route_constants.dart';
import '../storage/storage_provider.dart';
import '../storage/storage_service.dart';
import '../widgets/snack/app_snackbar.dart';

/// Top-level background FCM handler invoked in its own isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('FCM background init skipped: $e');
  }

  if (kDebugMode) {
    debugPrint(
      'FCM background message received: ${message.messageId} data=${message.data}',
    );
  }
}

/// Manages Firebase Cloud Messaging (FCM), local foreground banners,
/// token rotation syncing, and notification-tap deep navigation.
class PushNotificationService {
  PushNotificationService({required this.storageService});

  final StorageService storageService;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String androidChannelId = 'allround_notifications_channel';
  static const String androidChannelName = 'Allround Notifications';
  static const String androidChannelDescription =
      'Notifications for site assignments, inspections, and approvals.';

  bool _isInitialized = false;
  bool _firebaseAvailable = false;
  bool _pendingInitialOpen = false;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;

  Future<void> Function(String token)? onTokenRotated;
  void Function()? onNotificationOpened;
  void Function(Map<String, dynamic> data)? onForegroundPushReceived;

  bool get isFirebaseAvailable => _firebaseAvailable;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _initLocalNotifications();
    await _initFirebaseMessaging();
  }

  Future<void> _initLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onLocalNotificationTapped,
      );

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        await androidPlugin?.createNotificationChannel(
          const AndroidNotificationChannel(
            androidChannelId,
            androidChannelName,
            description: androidChannelDescription,
            importance: Importance.high,
          ),
        );
      }
    } catch (e) {
      debugPrint('Local notifications init warning: $e');
    }
  }

  Future<void> _initFirebaseMessaging() async {
    final isMobilePlatform =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!isMobilePlatform) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseAvailable = true;

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await storageService.saveFcmToken(token);
      }

      _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) async {
        if (newToken.isEmpty) return;
        await storageService.saveFcmToken(newToken);
        final callback = onTokenRotated;
        if (callback != null) {
          await callback(newToken);
        }
      });

      _onMessageSub = FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );

      _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleMessageOpened,
      );

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _pendingInitialOpen = true;
        _scheduleOpenNotifications();
      }
    } catch (e) {
      _firebaseAvailable = false;
      debugPrint(
        'FCM init skipped (verify Firebase configuration files): $e',
      );
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final data = Map<String, dynamic>.from(message.data);
    final title =
        message.notification?.title ??
        data['title']?.toString() ??
        'Allround';
    final body =
        message.notification?.body ??
        data['body']?.toString() ??
        data['message']?.toString() ??
        '';

    onForegroundPushReceived?.call(data);

    if (title.isNotEmpty || body.isNotEmpty) {
      await showLocalNotification(
        title: title,
        body: body,
        payload: jsonEncode(data),
      );
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    _navigateToNotifications();
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    _navigateToNotifications();
  }

  void consumePendingInitialNavigation() {
    if (_pendingInitialOpen) {
      _pendingInitialOpen = false;
      _navigateToNotifications();
    }
  }

  void _scheduleOpenNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingInitialOpen) {
        _pendingInitialOpen = false;
        _navigateToNotifications();
      }
    });
  }

  void _navigateToNotifications() {
    onNotificationOpened?.call();

    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    try {
      final router = GoRouter.of(context);
      final currentPath = router.routerDelegate.currentConfiguration.uri.path;
      if (currentPath != RouteConstants.notifications &&
          currentPath != RouteConstants.signIn &&
          currentPath != RouteConstants.splash) {
        router.push(RouteConstants.notifications);
      }
    } catch (e) {
      debugPrint('PushNotificationService navigation error: $e');
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            androidChannelId,
            androidChannelName,
            channelDescription: androidChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('showLocalNotification error: $e');
    }
  }

  Future<String?> refreshAndPersistToken() async {
    if (!_firebaseAvailable) {
      return storageService.getFcmToken();
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await storageService.saveFcmToken(token);
      }
      return token;
    } catch (e) {
      debugPrint('FCM getToken error: $e');
      return storageService.getFcmToken();
    }
  }

  Future<void> clearTokenOnLogout() async {
    try {
      if (_firebaseAvailable) {
        await FirebaseMessaging.instance.deleteToken();
      }
    } catch (e) {
      debugPrint('FCM deleteToken warning: $e');
    } finally {
      await storageService.clearFcmToken();
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _onMessageSub?.cancel();
    _onOpenedSub?.cancel();
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final storage = ref.watch(storageServiceProvider);
  final service = PushNotificationService(storageService: storage);
  ref.onDispose(service.dispose);
  return service;
});

