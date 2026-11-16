import '../../domain/entities/customer_entity.dart';

class CustomerContactModel extends CustomerContactEntity {
  const CustomerContactModel({
    required super.id,
    required super.name,
    super.role,
    super.phone,
    super.email,
  });

  factory CustomerContactModel.fromJson(Map<String, dynamic> json) {
    return CustomerContactModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    super.category,
    super.address,
    super.primaryContact,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final contactJson = json['primaryContact'];
    return CustomerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'COMMERCIAL',
      address: json['address'] as String? ?? '',
      primaryContact: contactJson is Map<String, dynamic>
          ? CustomerContactModel.fromJson(contactJson)
          : null,
    );
  }
}

class CustomerMetaModel extends CustomerMetaEntity {
  const CustomerMetaModel({
    required super.total,
    required super.totalPages,
    required super.currentPage,
  });

  factory CustomerMetaModel.fromJson(Map<String, dynamic> json, int fallbackPage) {
    int parsedPage = fallbackPage;
    final links = json['links'];
    if (links is Map<String, dynamic>) {
      final currentLink = links['currentPage'] as String?;
      if (currentLink != null) {
        final uri = Uri.tryParse(currentLink);
        final pageParam = uri?.queryParameters['page'];
        if (pageParam != null) {
          parsedPage = int.tryParse(pageParam) ?? fallbackPage;
        }
      }
    }

    return CustomerMetaModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      currentPage: parsedPage,
    );
  }
}
