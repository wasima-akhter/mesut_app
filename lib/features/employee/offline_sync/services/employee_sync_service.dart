import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../media/domain/repositories/media_repository.dart';
import '../models/employee_sync_action.dart';
import 'employee_sync_queue.dart';

class EmployeeSyncResult {
  const EmployeeSyncResult({
    required this.syncedCount,
    required this.failedCount,
    required this.remainingCount,
  });

  final int syncedCount;
  final int failedCount;
  final int remainingCount;
}

class EmployeeSyncService {
  EmployeeSyncService({
    required this.queue,
    required this.apiClient,
    required this.storageService,
    this.mediaRepository,
  });

  final EmployeeSyncQueue queue;
  final ApiClient apiClient;
  final StorageService storageService;
  final MediaRepository? mediaRepository;

  Future<EmployeeSyncResult> processQueue() async {
    final actions = queue.loadQueue();
    if (actions.isEmpty) {
      await storageService.saveLastSyncTime(DateTime.now());
      return const EmployeeSyncResult(
        syncedCount: 0,
        failedCount: 0,
        remainingCount: 0,
      );
    }

    int synced = 0;
    int failed = 0;

    for (final action in actions) {
      try {
        await _executeAction(action);
        await queue.remove(action.id);
        synced++;
      } catch (e) {
        failed++;
        final friendlyError = toFriendlyError(e);
        final updated = action.copyWith(
          attempts: action.attempts + 1,
          lastError: friendlyError,
        );
        await queue.update(updated);

        // If network issue, stop further attempts this cycle
        if (e is DioException) {
          final isNetworkIssue = e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.unknown;
          if (isNetworkIssue) {
            break;
          }
        }
      }
    }

    await storageService.saveLastSyncTime(DateTime.now());
    final remaining = queue.loadQueue().length;
    return EmployeeSyncResult(
      syncedCount: synced,
      failedCount: failed,
      remainingCount: remaining,
    );
  }

  Future<void> _executeAction(EmployeeSyncAction action) async {
    if (action.actionType == EmployeeSyncActionType.uploadAssignmentPhoto &&
        action.filePath != null &&
        action.filePath!.isNotEmpty &&
        mediaRepository != null) {
      final file = File(action.filePath!);
      if (await file.exists()) {
        final urls = await mediaRepository!.uploadMedia(files: [file]);
        final remoteUrl = urls.isNotEmpty ? urls.first : action.filePath!;
        final payload = Map<String, dynamic>.from(action.payload ?? {});
        payload['url'] = remoteUrl;
        await apiClient.post(action.endpoint, data: payload);
        return;
      }
    }

    dynamic requestData;
    if (action.filePath != null && action.filePath!.isNotEmpty) {
      final formMap = <String, dynamic>{
        'file': await MultipartFile.fromFile(action.filePath!),
      };
      if (action.payload != null) {
        formMap.addAll(action.payload!);
      }
      requestData = FormData.fromMap(formMap);
    } else {
      requestData = sanitizePayload(action);
    }

    switch (action.httpMethod.toUpperCase()) {
      case 'POST':
        await apiClient.post(action.endpoint, data: requestData);
        break;
      case 'PUT':
        await apiClient.put(action.endpoint, data: requestData);
        break;
      case 'PATCH':
        await apiClient.patch(action.endpoint, data: requestData);
        break;
      case 'DELETE':
        try {
          await apiClient.delete(action.endpoint, data: requestData);
        } on DioException catch (dioErr) {
          if (dioErr.response?.statusCode != 404) rethrow;
        }
        break;
      default:
        await apiClient.post(action.endpoint, data: requestData);
        break;
    }
  }

  static Map<String, dynamic> sanitizePayload(EmployeeSyncAction action) {
    final raw = Map<String, dynamic>.from(action.payload ?? {});
    final isStartTimer =
        action.actionType == EmployeeSyncActionType.startTimer ||
        action.endpoint == '/mobile/timer/start';
    if (isStartTimer) {
      final phase =
          raw['phaseId'] ?? raw['projectId'] ?? action.projectId ?? '';
      final clean = <String, dynamic>{
        'phaseId': phase,
        'activityType': raw['activityType'] ?? 'ERECTION',
      };
      if (raw['gpsStartLat'] != null) clean['gpsStartLat'] = raw['gpsStartLat'];
      if (raw['gpsStartLng'] != null) clean['gpsStartLng'] = raw['gpsStartLng'];
      return clean;
    }

    final isStopTimer =
        action.actionType == EmployeeSyncActionType.stopTimer ||
        action.endpoint == '/mobile/timer/stop';
    if (isStopTimer) {
      final clean = <String, dynamic>{
        'timeLogId': raw['timeLogId'] ?? '',
      };
      if (raw['gpsEndLat'] != null) clean['gpsEndLat'] = raw['gpsEndLat'];
      if (raw['gpsEndLng'] != null) clean['gpsEndLng'] = raw['gpsEndLng'];
      return clean;
    }

    final isManual =
        action.actionType == EmployeeSyncActionType.manualTimeLog ||
        action.endpoint.contains('/timer/manual');
    if (isManual) {
      final phase =
          raw['phaseId'] ?? raw['projectId'] ?? action.projectId ?? '';
      final clean = <String, dynamic>{
        'phaseId': phase,
        'activityType': raw['activityType'] ?? 'ERECTION',
        'startTime': raw['startTime'],
        'endTime': raw['endTime'],
        'breakMinutes': raw['breakMinutes'] ?? 0,
      };
      if (action.endpoint.contains('/employee/timer/manual')) {
        clean['projectId'] = phase;
      }
      return clean;
    }

    return raw;
  }

  /// Converts any sync or network exception into a clean, human-readable error.
  /// Never exposes technical dev details (like DioException, HTTP codes, or endpoints).
  String toFriendlyError(Object error) {
    if (error is DioException) {
      final type = error.type;
      if (type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.sendTimeout ||
          type == DioExceptionType.receiveTimeout ||
          type == DioExceptionType.connectionError) {
        return 'No internet connection. Changes will sync automatically when back online.';
      }

      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        if (statusCode >= 500) {
          return 'Server temporarily unavailable. Will retry shortly.';
        }
        if (statusCode == 401 || statusCode == 403) {
          return 'Session expired. Please sign in again.';
        }
        if (statusCode == 404) {
          return 'Requested item or project was not found.';
        }
        if (statusCode == 409) {
          return 'Sync conflict detected. Changes will update on next refresh.';
        }
        if (statusCode == 422 || statusCode == 400) {
          final data = error.response?.data;
          if (data is Map) {
            final errors = data['errors'];
            if (errors is List && errors.isNotEmpty) {
              final first = errors.first;
              if (first is Map && first['message'] != null) {
                final m = first['message'].toString();
                if (m.contains('Unrecognized key')) {
                  return 'Format updated for server • Ready to sync.';
                }
              }
            }
            if (data['message'] != null) {
              final msg = data['message'].toString().trim();
              if (msg.toLowerCase().contains('validation failed')) {
                return 'Format updated for server • Ready to sync.';
              }
              final isTechnical = msg.contains('Exception') ||
                  msg.contains('Dio') ||
                  msg.contains('/') ||
                  msg.contains('status code') ||
                  msg.contains('Route') ||
                  msg.contains('POST') ||
                  msg.contains('GET') ||
                  msg.contains('ObjectId') ||
                  msg.contains('Mongo') ||
                  msg.contains('SyntaxError');
              if (!isTechnical && msg.isNotEmpty && msg.length <= 80) {
                return msg;
              }
            }
          }
          return 'Format updated • Ready to sync.';
        }
      }

      final resolved = AppErrorResolver.resolve(error);
      final msg = resolved.displayMessage.trim();
      final isDevMessage = msg.toLowerCase().contains('dioexception') ||
          msg.toLowerCase().contains('bad response') ||
          msg.toLowerCase().contains('status code') ||
          msg.toLowerCase().contains('exception:') ||
          msg.contains('StackTrace');
      if (!isDevMessage && msg.isNotEmpty && msg.length <= 100) {
        return msg;
      }
      return 'Unable to sync with server. Will retry automatically.';
    }

    return 'Unable to sync changes. Will retry automatically.';
  }
}
