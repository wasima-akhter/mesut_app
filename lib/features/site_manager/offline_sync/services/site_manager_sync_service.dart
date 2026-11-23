import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../media/domain/repositories/media_repository.dart';
import '../models/site_manager_sync_action.dart';
import 'site_manager_sync_queue.dart';

class SiteManagerSyncResult {
  const SiteManagerSyncResult({
    required this.syncedCount,
    required this.failedCount,
    required this.remainingCount,
  });

  final int syncedCount;
  final int failedCount;
  final int remainingCount;
}

class SiteManagerSyncService {
  SiteManagerSyncService({
    required this.queue,
    required this.apiClient,
    required this.storageService,
    this.mediaRepository,
  });

  final SiteManagerSyncQueue queue;
  final ApiClient apiClient;
  final StorageService storageService;
  final MediaRepository? mediaRepository;

  Future<SiteManagerSyncResult> processQueue() async {
    final actions = queue.loadQueue();
    if (actions.isEmpty) {
      await storageService.saveLastSyncTime(DateTime.now());
      return const SiteManagerSyncResult(
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
        final friendlyError = AppErrorResolver.resolve(e).displayMessage;
        final updated = action.copyWith(
          attempts: action.attempts + 1,
          lastError: friendlyError,
        );
        await queue.update(updated);

        // If it's an unrecoverable client error (e.g. 403 Forbidden), discard it from queue.
        if (e is DioException) {
          final statusCode = e.response?.statusCode ?? 0;
          if (statusCode >= 400 && statusCode < 500 && statusCode != 408) {
            await queue.remove(action.id);
            continue;
          }

          // If it's a connectivity issue or timeout, stop further attempts this cycle.
          final isNetworkIssue = e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.unknown;
          if (isNetworkIssue) {
            break;
          }
        }
      }
    }

    await storageService.saveLastSyncTime(DateTime.now());
    final remaining = queue.loadQueue().length;
    return SiteManagerSyncResult(
      syncedCount: synced,
      failedCount: failed,
      remainingCount: remaining,
    );
  }

  Future<void> _executeAction(SiteManagerSyncAction action) async {
    if (action.actionType == SiteManagerSyncActionType.uploadAttachment &&
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
      requestData = action.payload;
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
          // If already deleted on server (404), consider success
          if (dioErr.response?.statusCode != 404) rethrow;
        }
        break;
      default:
        await apiClient.post(action.endpoint, data: requestData);
        break;
    }
  }
}
