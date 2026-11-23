class ScaffoldSpecification {
  final double area;
  final double height;
  final String type;

  const ScaffoldSpecification({
    required this.area,
    required this.height,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'area': area,
        'height': height,
        'type': type,
      };
}

class CustomerPayload {
  final String mode;
  final String? customerId;
  final String? name;
  final String? category;

  const CustomerPayload({
    required this.mode,
    this.customerId,
    this.name,
    this.category,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'mode': mode};
    if (mode == 'EXISTING' && customerId != null && customerId!.isNotEmpty) {
      map['customerId'] = customerId;
    }
    if (mode == 'NEW') {
      if (name != null && name!.isNotEmpty) map['name'] = name;
      if (category != null && category!.isNotEmpty) map['category'] = category;
    }
    return map;
  }
}

class ContactPayload {
  final String name;
  final String phone;
  final String email;
  final String role;

  const ContactPayload({
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
      };
}

class CreateScheduleItem {
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final double durationDays;

  const CreateScheduleItem({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
  });

  CreateScheduleItem copyWith({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    double? durationDays,
  }) {
    return CreateScheduleItem(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.toLowerCase(),
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
        'durationDays': durationDays.round(),
      };
}

class NotePayload {
  final String category;
  final String content;

  const NotePayload({
    required this.category,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'category': category.toUpperCase(),
        'content': content,
      };
}

class PhotoPayload {
  final String url;
  final String fileType;
  final String fileName;
  final int fileSize;
  final bool isCover;

  const PhotoPayload({
    required this.url,
    required this.fileType,
    required this.fileName,
    required this.fileSize,
    this.isCover = false,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'fileType': fileType,
        'fileName': fileName,
        'fileSize': fileSize,
        'isCover': isCover,
      };
}

class CreateProjectPayload {
  final String name;
  final double lat;
  final double lng;
  final String? placeLabel;
  final ScaffoldSpecification scaffoldSpecification;
  final String priority;
  final String phaseType;
  final String status;
  final String? siteManagerId;
  final CustomerPayload customer;
  final ContactPayload contact;
  final List<CreateScheduleItem> scheduleData;
  final NotePayload? note;
  final List<PhotoPayload> photos;

  const CreateProjectPayload({
    required this.name,
    required this.lat,
    required this.lng,
    this.placeLabel,
    required this.scaffoldSpecification,
    required this.priority,
    required this.phaseType,
    required this.status,
    this.siteManagerId,
    required this.customer,
    required this.contact,
    required this.scheduleData,
    this.note,
    this.photos = const [],
  });

  static String normalizeStatus(String raw) {
    final upper = raw.trim().toUpperCase();
    switch (upper) {
      case 'ENQUIRY':
      case 'QUOTATION':
      case 'ORDER_CONFIRMED':
      case 'IN_PROGRESS':
      case 'COMPLETED':
      case 'POSTPONED':
        return upper;
      case 'PLANNED':
      case 'NOT_STARTED':
      default:
        return 'ENQUIRY';
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'coordinates': {
        'lat': lat,
        'lng': lng,
      },
      'scaffoldSpecification': scaffoldSpecification.toJson(),
      'priority': priority.toUpperCase(),
      'phaseType': phaseType.toUpperCase(),
      'status': normalizeStatus(status),
      'customer': customer.toJson(),
      'contact': contact.toJson(),
      'scheduleData': scheduleData.map((s) => s.toJson()).toList(),
      'photos': photos.map((p) => p.toJson()).toList(),
    };

    if (placeLabel != null && placeLabel!.trim().isNotEmpty) {
      map['placeLabel'] = placeLabel!.trim();
    }
    if (siteManagerId != null && siteManagerId!.trim().isNotEmpty) {
      map['siteManagerId'] = siteManagerId!.trim();
    }
    if (note != null && note!.content.trim().isNotEmpty) {
      map['note'] = note!.toJson();
    }

    return map;
  }
}
