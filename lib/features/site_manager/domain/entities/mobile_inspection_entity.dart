class MobileInspectionCustomerEntity {
  const MobileInspectionCustomerEntity({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class MobileInspectionEntity {
  const MobileInspectionEntity({
    required this.id,
    required this.siteTitle,
    required this.address,
    required this.postalCode,
    required this.city,
    this.appointmentDate,
    this.scaffoldArea = 0,
    this.scaffoldHeight = 0,
    this.scaffoldType = '',
    this.status = 'PENDING',
    this.customer = const MobileInspectionCustomerEntity(id: '', name: ''),
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String siteTitle;
  final String address;
  final String postalCode;
  final String city;
  final DateTime? appointmentDate;
  final double scaffoldArea;
  final double scaffoldHeight;
  final String scaffoldType;
  final String status;
  final MobileInspectionCustomerEntity customer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPending => status.trim().toUpperCase() == 'PENDING';
  bool get isSurveyDone => status.trim().toUpperCase() == 'SURVEY_DONE';
}
