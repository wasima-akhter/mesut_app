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

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  } catch (e) {
    debugPrint('FCM background init skipped: $e');
  }
}

class PushNotificationService {
  PushNotificationService({required this.storageService});

  final StorageService storageService;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

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
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _onLocalNotificationTapped,
      );

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final plugin = _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await plugin?.createNotificationChannel(
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
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!isMobile) return;

    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      _firebaseAvailable = true;

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (storageService.notificationsEnabled) {
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) await storageService.saveFcmToken(token);
      } else {
        await storageService.clearFcmToken();
      }

      _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) async {
        if (newToken.isEmpty || !storageService.notificationsEnabled) return;
        await storageService.saveFcmToken(newToken);
        await onTokenRotated?.call(newToken);
      });

      _onMessageSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

      final initial = await messaging.getInitialMessage();
      if (initial != null && storageService.notificationsEnabled) {
        _pendingInitialOpen = true;
        _scheduleOpenNotifications();
      }
    } catch (e) {
      _firebaseAvailable = false;
      debugPrint('FCM init skipped: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await storageService.setNotificationsEnabled(enabled);
    if (!enabled) {
      try {
        await _localNotifications.cancelAll();
        if (_firebaseAvailable) await FirebaseMessaging.instance.deleteToken();
      } catch (e) {
        debugPrint('Disable notifications warning: $e');
      } finally {
        await storageService.clearFcmToken();
      }
    } else {
      if (_firebaseAvailable) {
        try {
          final messaging = FirebaseMessaging.instance;
          await messaging.requestPermission(alert: true, badge: true, sound: true);
          final token = await messaging.getToken();
          if (token != null && token.isNotEmpty) {
            await storageService.saveFcmToken(token);
            await onTokenRotated?.call(token);
          }
        } catch (e) {
          debugPrint('Enable notifications warning: $e');
        }
      }
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!storageService.notificationsEnabled) return;
    final data = Map<String, dynamic>.from(message.data);
    final title = message.notification?.title ?? data['title']?.toString() ?? 'Allround';
    final body = message.notification?.body ??
        data['body']?.toString() ??
        data['message']?.toString() ??
        '';

    onForegroundPushReceived?.call(data);
    if (title.isNotEmpty || body.isNotEmpty) {
      await showLocalNotification(title: title, body: body, payload: jsonEncode(data));
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    if (storageService.notificationsEnabled) _navigateToNotifications();
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    _navigateToNotifications();
  }

  void consumePendingInitialNavigation() {
    if (_pendingInitialOpen && storageService.notificationsEnabled) {
      _pendingInitialOpen = false;
      _navigateToNotifications();
    }
  }

  void _scheduleOpenNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingInitialOpen && storageService.notificationsEnabled) {
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
      final path = router.routerDelegate.currentConfiguration.uri.path;
      if (path != RouteConstants.notifications &&
          path != RouteConstants.signIn &&
          path != RouteConstants.splash) {
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
    if (!storageService.notificationsEnabled) return;
    try {
      await _localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
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
    if (!storageService.notificationsEnabled) return null;
    if (!_firebaseAvailable) return storageService.getFcmToken();
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) await storageService.saveFcmToken(token);
      return token;
    } catch (e) {
      debugPrint('FCM getToken error: $e');
      return storageService.getFcmToken();
    }
  }

  Future<void> clearTokenOnLogout() async {
    try {
      if (_firebaseAvailable) await FirebaseMessaging.instance.deleteToken();
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

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final service = PushNotificationService(storageService: storage);
  ref.onDispose(service.dispose);
  return service;
});
