import 'dart:convert';

import 'package:construction_app/core/storage/storage_service.dart';
import '../../domain/entities/offline_time_log.dart';

abstract class OfflineSyncLocalDataSource {
  List<OfflineTimeLog> loadQueue();
  Future<void> saveQueue(List<OfflineTimeLog> logs);
  Future<void> enqueue(OfflineTimeLog log);
  Future<void> removeBySyncIds(Set<String> syncIds);
}

class OfflineSyncLocalDataSourceImpl implements OfflineSyncLocalDataSource {
  OfflineSyncLocalDataSourceImpl({required this.storageService});

  final StorageService storageService;

  @override
  List<OfflineTimeLog> loadQueue() {
    final raw = storageService.getOfflineTimeLogsJson();
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final logs = <OfflineTimeLog>[];
      for (final item in decoded) {
        if (item is Map) {
          try {
            logs.add(
              OfflineTimeLog.fromStorageJson(Map<String, dynamic>.from(item)),
            );
          } catch (_) {
            // Skip malformed entry rather than regenerating a new clientSyncId.
          }
        }
      }
      return logs;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveQueue(List<OfflineTimeLog> logs) async {
    final encoded = jsonEncode(logs.map((e) => e.toStorageJson()).toList());
    await storageService.saveOfflineTimeLogsJson(encoded);
  }

  @override
  Future<void> enqueue(OfflineTimeLog log) async {
    final current = List<OfflineTimeLog>.from(loadQueue());
    final alreadyQueued = current.any(
      (item) => item.clientSyncId == log.clientSyncId,
    );
    if (!alreadyQueued) {
      current.add(log);
      await saveQueue(current);
    }
  }

  @override
  Future<void> removeBySyncIds(Set<String> syncIds) async {
    if (syncIds.isEmpty) return;
    final remaining = loadQueue()
        .where((item) => !syncIds.contains(item.clientSyncId))
        .toList();
    await saveQueue(remaining);
  }
}
