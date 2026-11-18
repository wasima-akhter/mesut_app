import 'dart:convert';

import '../../../../core/storage/local_storage.dart';

class EmployeeCacheService {
  EmployeeCacheService(this._localStorage);

  final LocalStorage _localStorage;

  static const String _prefix = 'emp_cache_';

  // -------------------------------------------------------------
  // Generic cache utilities
  // -------------------------------------------------------------
  Future<void> save(String key, dynamic data) async {
    final encoded = jsonEncode(data);
    await _localStorage.setString('$_prefix$key', encoded);
  }

  dynamic get(String key) {
    final raw = _localStorage.getString('$_prefix$key');
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? getMap(String key) {
    final data = get(key);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  List<dynamic>? getList(String key) {
    final data = get(key);
    if (data is List) return data;
    return null;
  }

  Future<void> remove(String key) async {
    await _localStorage.remove('$_prefix$key');
  }

  // -------------------------------------------------------------
  // Specific feature helpers
  // -------------------------------------------------------------
  Future<void> cacheDashboard(Map<String, dynamic> data) =>
      save('dashboard', data);
  Map<String, dynamic>? getCachedDashboard() => getMap('dashboard');

  Future<void> cacheSchedule(dynamic data) => save('schedule', data);
  dynamic getCachedSchedule() => get('schedule');

  Future<void> cacheTimeSummary(Map<String, dynamic> data) =>
      save('time_summary', data);
  Map<String, dynamic>? getCachedTimeSummary() => getMap('time_summary');

  Future<void> cacheProjects(dynamic data) => save('time_projects', data);
  dynamic getCachedProjects() => get('time_projects');

  Future<void> cacheTimeLogs(String period, dynamic data) =>
      save('time_logs_$period', data);
  dynamic getCachedTimeLogs(String period) => get('time_logs_$period');

  Future<void> cacheAssignments(dynamic data) => save('assignments', data);
  dynamic getCachedAssignments() => get('assignments');
}
