import '../../projects/enums.dart';

class SiteProject {
  final String id;
  final String name;
  final String customer;
  final String address;
  final String city;
  final ProjectPhase phase;
  final ProjectStatus status;
  final ProjectPriority priority;
  final String? startDate;
  final String? endDate;
  final String? scaffoldArea;
  final String? contactPerson;
  final String? phone;
  final String? email;

  const SiteProject({
    required this.id,
    required this.name,
    required this.customer,
    required this.address,
    required this.city,
    required this.phase,
    required this.status,
    required this.priority,
    this.startDate,
    this.endDate,
    this.scaffoldArea,
    this.contactPerson,
    this.phone,
    this.email,
  });

  SiteProject copyWith({
    String? id,
    String? name,
    String? customer,
    String? address,
    String? city,
    ProjectPhase? phase,
    ProjectStatus? status,
    ProjectPriority? priority,
    String? startDate,
    String? endDate,
    String? scaffoldArea,
    String? contactPerson,
    String? phone,
    String? email,
  }) {
    return SiteProject(
      id: id ?? this.id,
      name: name ?? this.name,
      customer: customer ?? this.customer,
      address: address ?? this.address,
      city: city ?? this.city,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      scaffoldArea: scaffoldArea ?? this.scaffoldArea,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}

class SiteInspection {
  final String id;
  final String projectId;
  final String projectName;
  final String scaffoldType;
  final DateTime inspectionDate;
  final bool isPassed;
  final String inspectorName;
  final String notes;

  const SiteInspection({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.scaffoldType,
    required this.inspectionDate,
    required this.isPassed,
    required this.inspectorName,
    required this.notes,
  });
}

class DashboardStats {
  final int activeSites;
  final int completedProjects;
  final double totalWorkHours;
  final int erectionsPlanned;
  final int erectionsRunning;
  final int dismantlingsPlanned;
  final int dismantlingsRunning;
  final int inspectionsDue;

  const DashboardStats({
    required this.activeSites,
    required this.completedProjects,
    required this.totalWorkHours,
    required this.erectionsPlanned,
    required this.erectionsRunning,
    required this.dismantlingsPlanned,
    required this.dismantlingsRunning,
    required this.inspectionsDue,
  });
}
