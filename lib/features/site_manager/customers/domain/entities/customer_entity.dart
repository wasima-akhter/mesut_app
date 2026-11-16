class CustomerContactEntity {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String email;

  const CustomerContactEntity({
    required this.id,
    required this.name,
    this.role = '',
    this.phone = '',
    this.email = '',
  });
}

class CustomerEntity {
  final String id;
  final String name;
  final String category;
  final String address;
  final CustomerContactEntity? primaryContact;

  const CustomerEntity({
    required this.id,
    required this.name,
    this.category = 'COMMERCIAL',
    this.address = '',
    this.primaryContact,
  });
}

class CustomerMetaEntity {
  final int total;
  final int totalPages;
  final int currentPage;

  const CustomerMetaEntity({
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  bool get hasNextPage => currentPage < totalPages;
}

class CustomerListResult {
  final List<CustomerEntity> items;
  final CustomerMetaEntity meta;

  const CustomerListResult({
    required this.items,
    required this.meta,
  });
}
