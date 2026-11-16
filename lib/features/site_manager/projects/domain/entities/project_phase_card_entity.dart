import '../../../../../core/services/address_resolver_service.dart';

class ProjectPhaseCoordinates {
  final double lat;
  final double lng;

  const ProjectPhaseCoordinates({required this.lat, required this.lng});

  bool get isEmpty => lat == 0 && lng == 0;
}

class ProjectPhaseCustomer {
  final String id;
  final String name;
  final String category;

  const ProjectPhaseCustomer({
    required this.id,
    required this.name,
    required this.category,
  });

  bool get isEmpty => id.isEmpty && name.isEmpty;
}

class ProjectPhaseCardEntity {
  final String phaseId;
  final String type;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final int durationDays;
  final String projectId;
  final String projectName;
  final ProjectPhaseCoordinates coordinates;
  final ProjectPhaseCustomer customer;
  final String assigneeName;
  final double budgetedHours;
  final double totalLoggedHours;
  final bool isProfitable;

  const ProjectPhaseCardEntity({
    required this.phaseId,
    required this.type,
    required this.status,
    required this.priority,
    this.startDate,
    this.endDate,
    required this.durationDays,
    required this.projectId,
    required this.projectName,
    required this.coordinates,
    required this.customer,
    required this.assigneeName,
    required this.budgetedHours,
    required this.totalLoggedHours,
    required this.isProfitable,
  });

  /// Centrally extracts and formats the address from latitude/longitude coordinates.
  String get formattedAddress => AddressResolverService.resolveSync(
        coordinates.lat,
        coordinates.lng,
      );

  String get formattedLoggedHours => totalLoggedHours.toStringAsFixed(1);
  String get formattedBudgetHours => budgetedHours.toStringAsFixed(1);

  bool get hasHoursLogged => totalLoggedHours > 0;
  bool get hasBudget => budgetedHours > 0;
}
