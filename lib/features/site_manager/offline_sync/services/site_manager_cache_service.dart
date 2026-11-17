import 'dart:convert';

import '../../../../core/storage/local_storage.dart';

class SiteManagerCacheService {
  SiteManagerCacheService(this._localStorage);

  final LocalStorage _localStorage;

  static const String _prefix = 'sm_cache_';

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

  Future<void> cacheProjects(String tab, Map<String, dynamic> data) =>
      save('projects_$tab', data);
  Map<String, dynamic>? getCachedProjects(String tab) =>
      getMap('projects_$tab');

  Future<void> cacheProjectDetails(String id, Map<String, dynamic> data) =>
      save('project_detail_$id', data);
  Map<String, dynamic>? getCachedProjectDetails(String id) =>
      getMap('project_detail_$id');

  Future<void> cacheProjectTasks(String projectId, dynamic data) =>
      save('tasks_$projectId', data);
  dynamic getCachedProjectTasks(String projectId) =>
      get('tasks_$projectId');

  Future<void> cacheMeasurements(String projectId, dynamic data) =>
      save('measurements_$projectId', data);
  dynamic getCachedMeasurements(String projectId) =>
      get('measurements_$projectId');

  Future<void> cacheNotes(String projectId, dynamic data) =>
      save('notes_$projectId', data);
  dynamic getCachedNotes(String projectId) => get('notes_$projectId');

  Future<void> cacheDates(String projectId, dynamic data) =>
      save('dates_$projectId', data);
  dynamic getCachedDates(String projectId) => get('dates_$projectId');

  Future<void> cacheAttachments(String projectId, dynamic data) =>
      save('attachments_$projectId', data);
  dynamic getCachedAttachments(String projectId) =>
      get('attachments_$projectId');

  Future<void> cacheHistory(String projectId, dynamic data) =>
      save('history_$projectId', data);
  dynamic getCachedHistory(String projectId) => get('history_$projectId');

  Future<void> cachePhases(String column, dynamic data) =>
      save('phases_$column', data);
  dynamic getCachedPhases(String column) => get('phases_$column');

  Future<void> cacheInspections(dynamic data) => save('inspections', data);
  dynamic getCachedInspections() => get('inspections');

  Future<void> cacheCrewTime(String projectId, dynamic data) =>
      save('crew_time_$projectId', data);
  dynamic getCachedCrewTime(String projectId) =>
      get('crew_time_$projectId');

  Future<void> cacheCustomers(dynamic data) => save('customers', data);
  dynamic getCachedCustomers() => get('customers');

  Future<void> cacheProfile(dynamic data) => save('profile', data);
  dynamic getCachedProfile() => get('profile');
}
