import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../network/network_providers.dart';

enum SocketConnectionStatus { disconnected, connecting, connected, error }

/// Socket.IO realtime notification client (`<serverBaseUrl>/api/v1/notification`).
class NotificationSocketService {
  NotificationSocketService({required this.config});

  final AppConfig config;

  io.Socket? _socket;
  String? _activeToken;
  SocketConnectionStatus _status = SocketConnectionStatus.disconnected;

  ValueSetter<int>? onUnreadCount;
  ValueSetter<Map<String, dynamic>>? onNewNotification;
  ValueSetter<String?>? onNotificationRead;
  VoidCallback? onAllRead;
  ValueSetter<SocketConnectionStatus>? onStatusChanged;
  ValueSetter<String>? onServerError;

  SocketConnectionStatus get status => _status;
  bool get isConnected => _socket?.connected == true;

  void _setStatus(SocketConnectionStatus next) {
    _status = next;
    onStatusChanged?.call(next);
  }

  /// Connects to the `/api/v1/notification` namespace with Bearer JWT.
  void connect(String accessToken) {
    final trimmed = accessToken.trim();
    if (trimmed.isEmpty) return;

    if (_socket != null && _activeToken == trimmed) {
      if (!(_socket!.connected)) {
        _setStatus(SocketConnectionStatus.connecting);
        _socket!.connect();
      }
      return;
    }

    disconnect();

    _activeToken = trimmed;
    _setStatus(SocketConnectionStatus.connecting);

    final socketUrl =
        '${config.serverBaseUrl}${ApiConstants.notificationSocketNamespace}';

    final socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': trimmed})
          .setExtraHeaders({'Authorization': 'Bearer $trimmed'})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .build(),
    );

    socket.onConnect((_) {
      _setStatus(SocketConnectionStatus.connected);
      socket.emit('notification:count');
    });

    socket.onDisconnect((_) {
      _setStatus(SocketConnectionStatus.disconnected);
    });

    socket.onConnectError((err) {
      _setStatus(SocketConnectionStatus.error);
      if (kDebugMode) {
        debugPrint('Socket.IO connect error: $err');
      }
    });

    socket.onError((err) {
      _setStatus(SocketConnectionStatus.error);
      if (kDebugMode) {
        debugPrint('Socket.IO error: $err');
      }
    });

    socket.on('notification:count-response', (data) {
      final count = _extractCount(data);
      if (count != null) {
        onUnreadCount?.call(count);
      }
    });

    socket.on('notification:new', (data) {
      if (data is Map) {
        onNewNotification?.call(Map<String, dynamic>.from(data));
      }
    });

    socket.on('notification:read', (data) {
      String? id;
      if (data is Map) {
        id = (data['notificationId'] ?? data['id'])?.toString();
      } else if (data != null) {
        id = data.toString();
      }
      onNotificationRead?.call(id);
    });

    socket.on('notification:all-read', (_) {
      onAllRead?.call();
    });

    socket.on('error:server', (err) {
      final msg = err is Map
          ? (err['message']?.toString() ?? err.toString())
          : err?.toString() ?? 'Socket server error';
      onServerError?.call(msg);
      if (kDebugMode) {
        debugPrint('Socket.IO server error: $msg');
      }
    });

    _socket = socket;
    socket.connect();
  }

  void requestCount() {
    if (isConnected) {
      _socket?.emit('notification:count');
    }
  }

  void emitMarkRead(String notificationId) {
    if (isConnected && notificationId.isNotEmpty) {
      _socket?.emit('notification:mark-read', {
        'notificationId': notificationId,
      });
    }
  }

  void emitMarkAllRead() {
    if (isConnected) {
      _socket?.emit('notification:mark-all-read');
    }
  }

  void disconnect() {
    final socket = _socket;
    _socket = null;
    _activeToken = null;
    if (socket != null) {
      socket.clearListeners();
      socket.disconnect();
      socket.dispose();
    }
    _setStatus(SocketConnectionStatus.disconnected);
  }

  static int? _extractCount(dynamic data) {
    if (data is int) return data;
    if (data is Map) {
      final raw = data['count'] ?? data['unreadCount'];
      if (raw is int) return raw;
      if (raw != null) return int.tryParse(raw.toString());
    }
    return null;
  }
}

final notificationSocketServiceProvider = Provider<NotificationSocketService>((
  ref,
) {
  final config = ref.watch(appConfigProvider);
  final service = NotificationSocketService(config: config);
  ref.onDispose(service.disconnect);
  return service;
});
