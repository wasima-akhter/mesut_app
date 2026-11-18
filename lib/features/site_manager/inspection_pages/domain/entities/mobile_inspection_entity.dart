import 'package:construction_app/core/localization/localization_meta.dart';

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
    this.localization,
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
  final LocalizationMeta? localization;

  bool get isPending => status.trim().toUpperCase() == 'PENDING';
  bool get isSurveyDone => status.trim().toUpperCase() == 'SURVEY_DONE';

  MobileInspectionEntity copyWith({
    String? id,
    String? siteTitle,
    String? address,
    String? postalCode,
    String? city,
    DateTime? appointmentDate,
    double? scaffoldArea,
    double? scaffoldHeight,
    String? scaffoldType,
    String? status,
    MobileInspectionCustomerEntity? customer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MobileInspectionEntity(
      id: id ?? this.id,
      siteTitle: siteTitle ?? this.siteTitle,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      scaffoldArea: scaffoldArea ?? this.scaffoldArea,
      scaffoldHeight: scaffoldHeight ?? this.scaffoldHeight,
      scaffoldType: scaffoldType ?? this.scaffoldType,
      status: status ?? this.status,
      customer: customer ?? this.customer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
