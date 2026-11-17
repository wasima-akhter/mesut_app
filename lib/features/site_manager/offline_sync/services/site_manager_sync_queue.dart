import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../models/site_manager_sync_action.dart';

abstract class SiteManagerSyncQueue {
  List<SiteManagerSyncAction> loadQueue();
  Future<void> enqueue(SiteManagerSyncAction action);
  Future<void> remove(String actionId);
  Future<void> removeMany(Set<String> actionIds);
  Future<void> update(SiteManagerSyncAction action);
  Future<void> clear();
}

class SiteManagerSyncQueueImpl implements SiteManagerSyncQueue {
  SiteManagerSyncQueueImpl(this._localStorage);

  final LocalStorage _localStorage;
  static const String _queueKey = 'sm_offline_mutation_queue';

  @override
  List<SiteManagerSyncAction> loadQueue() {
    final raw = _localStorage.getString(_queueKey);
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final list = <SiteManagerSyncAction>[];
      for (final item in decoded) {
        if (item is Map) {
          try {
            list.add(
              SiteManagerSyncAction.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          } catch (_) {
            // Skip malformed item
          }
        }
      }
      return list;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _save(List<SiteManagerSyncAction> actions) async {
    final encoded = jsonEncode(actions.map((e) => e.toJson()).toList());
    await _localStorage.setString(_queueKey, encoded);
  }

  @override
  Future<void> enqueue(SiteManagerSyncAction action) async {
    final current = List<SiteManagerSyncAction>.from(loadQueue());
    final index = current.indexWhere((e) => e.id == action.id);
    if (index >= 0) {
      current[index] = action;
    } else {
      current.add(action);
    }
    await _save(current);
  }

  @override
  Future<void> remove(String actionId) async {
    final current = loadQueue().where((e) => e.id != actionId).toList();
    await _save(current);
  }

  @override
  Future<void> removeMany(Set<String> actionIds) async {
    if (actionIds.isEmpty) return;
    final current =
        loadQueue().where((e) => !actionIds.contains(e.id)).toList();
    await _save(current);
  }

  @override
  Future<void> update(SiteManagerSyncAction action) async {
    final current = List<SiteManagerSyncAction>.from(loadQueue());
    final index = current.indexWhere((e) => e.id == action.id);
    if (index >= 0) {
      current[index] = action;
      await _save(current);
    }
  }

  @override
  Future<void> clear() async {
    await _localStorage.remove(_queueKey);
  }
}
