import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../models/employee_sync_action.dart';

abstract class EmployeeSyncQueue {
  List<EmployeeSyncAction> loadQueue();
  Future<void> enqueue(EmployeeSyncAction action);
  Future<void> remove(String actionId);
  Future<void> removeMany(Set<String> actionIds);
  Future<void> update(EmployeeSyncAction action);
  Future<void> clear();
}

class EmployeeSyncQueueImpl implements EmployeeSyncQueue {
  EmployeeSyncQueueImpl(this._localStorage);

  final LocalStorage _localStorage;
  static const String _queueKey = 'emp_offline_mutation_queue';

  @override
  List<EmployeeSyncAction> loadQueue() {
    final raw = _localStorage.getString(_queueKey);
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final list = <EmployeeSyncAction>[];
      for (final item in decoded) {
        if (item is Map) {
          try {
            var action = EmployeeSyncAction.fromJson(
              Map<String, dynamic>.from(item),
            );
            if (action.lastError != null && _isDevError(action.lastError!)) {
              action = action.copyWith(
                lastError: 'Unable to sync with server. Will retry automatically.',
              );
            }
            list.add(action);
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

  Future<void> _save(List<EmployeeSyncAction> actions) async {
    final encoded = jsonEncode(actions.map((e) => e.toJson()).toList());
    await _localStorage.setString(_queueKey, encoded);
  }

  @override
  Future<void> enqueue(EmployeeSyncAction action) async {
    final current = List<EmployeeSyncAction>.from(loadQueue());
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
  Future<void> update(EmployeeSyncAction action) async {
    final current = List<EmployeeSyncAction>.from(loadQueue());
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

  static bool _isDevError(String error) {
    final lower = error.toLowerCase();
    return lower.contains('dioexception') ||
        lower.contains('socketexception') ||
        lower.contains('status code') ||
        lower.contains('bad response') ||
        lower.contains('cannot post') ||
        lower.contains('cannot get') ||
        lower.contains('stacktrace') ||
        lower.contains('failed host lookup') ||
        lower.contains('exception:');
  }
}
