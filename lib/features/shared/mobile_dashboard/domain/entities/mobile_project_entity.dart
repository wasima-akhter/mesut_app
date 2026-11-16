class MobileProjectCustomerEntity {
  const MobileProjectCustomerEntity({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class MobileProjectPhaseEntity {
  const MobileProjectPhaseEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String type;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
}

class MobileProjectEntity {
  const MobileProjectEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.customer,
    this.phases = const [],
    this.budgetedHours = 0,
    this.totalLoggedHours = 0,
    this.isProfitable = true,
  });

  final String id;
  final String name;
  final String address;
  final MobileProjectCustomerEntity customer;
  final List<MobileProjectPhaseEntity> phases;
  final double budgetedHours;
  final double totalLoggedHours;
  final bool isProfitable;
}
