import '../../domain/entities/employee_dashboard_entity.dart';

class EmployeeDashboardUserModel extends EmployeeDashboardUserEntity {
  const EmployeeDashboardUserModel({
    super.id,
    super.firstName,
    super.lastName,
    super.role,
    super.avatarUrl,
  });

  factory EmployeeDashboardUserModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardUserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      role: json['role']?.toString() ?? 'EMPLOYEE',
      avatarUrl: json['avatarUrl']?.toString(),
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
  });

  factory EmployeeDashboardProjectModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>?;
    final lat = coords?['lat'] ?? json['latitude'] ?? json['lat'];
    final lng = coords?['lng'] ?? json['longitude'] ?? json['lng'];

    return EmployeeDashboardProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: _toDouble(lat),
      longitude: _toDouble(lng),
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
  });

  factory EmployeeDashboardSiteManagerModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardSiteManagerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
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
  });

  factory EmployeeDashboardTaskModel.fromJson(Map<String, dynamic> json) {
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
      project: json['project'] is Map<String, dynamic>
          ? EmployeeDashboardProjectModel.fromJson(
              json['project'] as Map<String, dynamic>,
            )
          : const EmployeeDashboardProjectEntity(),
      siteManager: json['siteManager'] is Map<String, dynamic>
          ? EmployeeDashboardSiteManagerModel.fromJson(
              json['siteManager'] as Map<String, dynamic>,
            )
          : const EmployeeDashboardSiteManagerEntity(),
      workingHours: json['workingHours']?.toString() ?? '',
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
  });

  factory EmployeeDashboardModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    final tasksList = json['upcomingTasks'] as List<dynamic>? ?? [];

    return EmployeeDashboardModel(
      user: EmployeeDashboardUserModel.fromJson(userJson),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
      formattedDate: json['formattedDate']?.toString() ?? '',
      totalUpcomingTasks: _toInt(json['totalUpcomingTasks']),
      upcomingTasks: tasksList
          .whereType<Map<String, dynamic>>()
          .map(EmployeeDashboardTaskModel.fromJson)
          .toList(),
    );
  }

  static int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}
