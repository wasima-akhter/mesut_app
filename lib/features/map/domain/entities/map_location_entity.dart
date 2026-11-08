import 'map_coordinate_entity.dart';

/// Strongly-typed map location entity representing a work site, project, or inspection point.
class MapLocationEntity {
  final String id;
  final String title;
  final String address;
  final MapCoordinate coordinate;
  final String? subtitle;
  final String? company;
  final String? type; // 'Erection', 'Dismantling', 'Standing', 'Inspection', etc.
  final String? priority; // 'High', 'Medium', 'Low'
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? imageUrl;
  final String? date;

  const MapLocationEntity({
    required this.id,
    required this.title,
    required this.address,
    required this.coordinate,
    this.subtitle,
    this.company,
    this.type,
    this.priority,
    this.contactPerson,
    this.phone,
    this.email,
    this.imageUrl,
    this.date,
  });

  double get latitude => coordinate.latitude;
  double get longitude => coordinate.longitude;

  bool get hasValidCoordinates => coordinate.isValid;

  MapLocationEntity copyWith({
    String? id,
    String? title,
    String? address,
    MapCoordinate? coordinate,
    String? subtitle,
    String? company,
    String? type,
    String? priority,
    String? contactPerson,
    String? phone,
    String? email,
    String? imageUrl,
    String? date,
  }) {
    return MapLocationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      coordinate: coordinate ?? this.coordinate,
      subtitle: subtitle ?? this.subtitle,
      company: company ?? this.company,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'address': address,
        'coordinate': coordinate.toJson(),
        if (subtitle != null) 'subtitle': subtitle,
        if (company != null) 'company': company,
        if (type != null) 'type': type,
        if (priority != null) 'priority': priority,
        if (contactPerson != null) 'contactPerson': contactPerson,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (date != null) 'date': date,
      };

  factory MapLocationEntity.fromJson(Map<String, dynamic> json) {
    return MapLocationEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      address: json['address'] as String,
      coordinate:
          MapCoordinate.fromJson(json['coordinate'] as Map<String, dynamic>),
      subtitle: json['subtitle'] as String?,
      company: json['company'] as String?,
      type: json['type'] as String?,
      priority: json['priority'] as String?,
      contactPerson: json['contactPerson'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      imageUrl: json['imageUrl'] as String?,
      date: json['date'] as String?,
    );
  }
}

