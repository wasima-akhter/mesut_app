import 'package:construction_app/core/localization/localization_meta.dart';
import '../../domain/entities/employee_dashboard_entity.dart';

Map<String, dynamic> _asMap(dynamic val) {
  if (val is Map<String, dynamic>) return val;
  if (val is Map) return Map<String, dynamic>.from(val);
  return const <String, dynamic>{};
}

class EmployeeDashboardUserModel extends EmployeeDashboardUserEntity {
  const EmployeeDashboardUserModel({
    super.id,
    super.firstName,
    super.lastName,
    super.role,
    super.avatarUrl,
    super.localization,
  });

  factory EmployeeDashboardUserModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardUserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      role: json['role']?.toString() ?? 'EMPLOYEE',
      avatarUrl: json['avatarUrl']?.toString(),
      localization: LocalizationMeta.tryParse(json),
    );
  }
}

class EmployeeDashboardProjectModel extends EmployeeDashboardProjectEntity {
  const EmployeeDashboardProjectModel({
    super.id,
    super.name,
    super.address,
    super.latitude,
    super.longitude,
    super.localization,
  });

  factory EmployeeDashboardProjectModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] is Map ? _asMap(json['coordinates']) : null;
    final lat = coords?['lat'] ?? json['latitude'] ?? json['lat'];
    final lng = coords?['lng'] ?? json['longitude'] ?? json['lng'];

    return EmployeeDashboardProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: _toDouble(lat),
      longitude: _toDouble(lng),
      localization: LocalizationMeta.tryParse(json),
    );
  }

  static double _toDouble(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}

class EmployeeDashboardSiteManagerModel extends EmployeeDashboardSiteManagerEntity {
  const EmployeeDashboardSiteManagerModel({
    super.id,
    super.name,
    super.phone,
    super.email,
    super.localization,
  });

  factory EmployeeDashboardSiteManagerModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardSiteManagerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      localization: LocalizationMeta.tryParse(json),
    );
  }
}

class EmployeeDashboardTaskModel extends EmployeeDashboardTaskEntity {
  const EmployeeDashboardTaskModel({
    super.phaseId,
    super.type,
    super.status,
    super.priority,
    super.startDate,
    super.endDate,
    super.project,
    super.siteManager,
    super.workingHours,
    super.localization,
  });

  factory EmployeeDashboardTaskModel.fromJson(Map<String, dynamic> json) {
    final projectMap = _asMap(json['project']);
    final siteManagerMap = _asMap(json['siteManager']);
    final project = EmployeeDashboardProjectModel.fromJson(projectMap);
    final siteManager = EmployeeDashboardSiteManagerModel.fromJson(siteManagerMap);

    return EmployeeDashboardTaskModel(
      phaseId: json['phaseId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'ERECTION',
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'HIGH',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      project: project,
      siteManager: siteManager,
      workingHours: json['workingHours']?.toString() ?? '',
      localization: LocalizationMeta.tryParse(json) ??
          project.localization ??
          siteManager.localization,
    );
  }
}

class EmployeeDashboardModel extends EmployeeDashboardEntity {
  const EmployeeDashboardModel({
    super.user,
    super.date,
    super.formattedDate,
    super.totalUpcomingTasks,
    super.upcomingTasks,
    super.localization,
  });

  factory EmployeeDashboardModel.fromJson(Map<String, dynamic> json) {
    final userJson = _asMap(json['user']);
    final tasksList = json['upcomingTasks'] as List<dynamic>? ?? [];
    final tasks = <EmployeeDashboardTaskEntity>[];
    for (final item in tasksList) {
      final map = _asMap(item);
      if (map.isNotEmpty) {
        tasks.add(EmployeeDashboardTaskModel.fromJson(map));
      }
    }

    final user = EmployeeDashboardUserModel.fromJson(userJson);

    return EmployeeDashboardModel(
      user: user,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
      formattedDate: json['formattedDate']?.toString() ?? '',
      totalUpcomingTasks: _toInt(json['totalUpcomingTasks']),
      upcomingTasks: tasks,
      localization: LocalizationMeta.tryParse(json) ??
          user.localization ??
          (tasks.isNotEmpty ? tasks.first.localization : null),
    );
  }

  static int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}
