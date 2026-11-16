import '../../../../../core/services/address_resolver_service.dart';

class ProjectCoordinates {
  final double lat;
  final double lng;

  const ProjectCoordinates({required this.lat, required this.lng});

  bool get isEmpty => lat == 0 && lng == 0;
}

class ProjectScaffoldSpec {
  final double area;
  final double height;
  final String type;

  const ProjectScaffoldSpec({
    required this.area,
    required this.height,
    required this.type,
  });

  bool get isEmpty => area == 0 && height == 0 && type.isEmpty;
}

class ProjectScheduleData {
  final String id;
  final String type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int durationDays;

  const ProjectScheduleData({
    required this.id,
    required this.type,
    this.startDate,
    this.endDate,
    required this.durationDays,
  });
}

class NextSafetyInspection {
  final String id;
  final DateTime? appointmentDate;
  final String siteTitle;
  final String address;
  final String city;

  const NextSafetyInspection({
    required this.id,
    this.appointmentDate,
    required this.siteTitle,
    required this.address,
    required this.city,
  });

  bool get isEmpty => id.isEmpty && appointmentDate == null && siteTitle.isEmpty;
}

class ProjectPhaseItem {
  final String id;
  final String projectId;
  final String type;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final int durationDays;
  final bool safetyInspectionComplete;

  const ProjectPhaseItem({
    required this.id,
    required this.projectId,
    required this.type,
    required this.status,
    required this.priority,
    this.startDate,
    this.endDate,
    required this.durationDays,
    required this.safetyInspectionComplete,
  });
}

class CustomerPrimaryContact {
  final String name;
  final String phone;
  final String email;

  const CustomerPrimaryContact({
    required this.name,
    required this.phone,
    required this.email,
  });

  bool get isEmpty => name.isEmpty && phone.isEmpty && email.isEmpty;
}

class ProjectCustomerDetail {
  final String id;
  final String name;
  final String category;
  final CustomerPrimaryContact primaryContact;

  const ProjectCustomerDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.primaryContact,
  });

  bool get isEmpty => id.isEmpty && name.isEmpty;
}

class LaborHoursByActivity {
  final String activityType;
  final double hours;

  const LaborHoursByActivity({
    required this.activityType,
    required this.hours,
  });
}

class CrewUser {
  final String id;
  final String firstName;
  final String lastName;

  const CrewUser({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName'.trim();
}

class CrewBreakdownItem {
  final CrewUser user;
  final double totalHours;
  final bool synced;

  const CrewBreakdownItem({
    required this.user,
    required this.totalHours,
    required this.synced,
  });
}

class AttachmentCounts {
  final int photos;
  final int pdfPlans;

  const AttachmentCounts({
    required this.photos,
    required this.pdfPlans,
  });
}

class ProjectDetailsEntity {
  final String id;
  final String name;
  final ProjectCoordinates coordinates;
  final String siteAccessCode;
  final String siteAccessNotes;
  final ProjectScaffoldSpec scaffoldSpecification;
  final List<ProjectScheduleData> scheduleData;
  final NextSafetyInspection nextSafetyInspection;
  final double budgetedHours;
  final double totalLoggedHours;
  final bool isProfitable;
  final List<ProjectPhaseItem> phases;
  final ProjectCustomerDetail customer;
  final List<LaborHoursByActivity> hoursByActivity;
  final List<CrewBreakdownItem> crewBreakdown;
  final AttachmentCounts attachmentCounts;

  const ProjectDetailsEntity({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.siteAccessCode,
    required this.siteAccessNotes,
    required this.scaffoldSpecification,
    required this.scheduleData,
    required this.nextSafetyInspection,
    required this.budgetedHours,
    required this.totalLoggedHours,
    required this.isProfitable,
    required this.phases,
    required this.customer,
    required this.hoursByActivity,
    required this.crewBreakdown,
    required this.attachmentCounts,
  });

  String get formattedAddress => AddressResolverService.resolveSync(
        coordinates.lat,
        coordinates.lng,
      );

  String get formattedTotalHours => totalLoggedHours.toStringAsFixed(1);
  String get formattedBudgetHours => budgetedHours.toStringAsFixed(1);
  double get remainingHours => (budgetedHours - totalLoggedHours);
  double get budgetProgress => budgetedHours > 0
      ? (totalLoggedHours / budgetedHours).clamp(0.0, 1.0)
      : 0.0;

  ProjectPhaseItem? get primaryPhase => phases.isNotEmpty ? phases.first : null;
}
