import '../../../../../core/localization/localization_meta.dart';

class EmployeeProjectPhaseEntity {
  final String id;
  final String type;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final num assignedHoursToday;

  const EmployeeProjectPhaseEntity({
    required this.id,
    required this.type,
    required this.status,
    this.startDate,
    this.endDate,
    this.assignedHoursToday = 0,
  });
}

class EmployeeProjectManagerEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;

  const EmployeeProjectManagerEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
  });

  String get fullName {
    final combined = '$firstName $lastName'.trim();
    return combined.isEmpty ? 'Site Manager' : combined;
  }
}

class EmployeeProjectPhotoEntity {
  final String id;
  final String url;
  final String? fileType;
  final String? fileName;
  final int? fileSize;
  final bool isCover;
  final String? category;
  final DateTime? createdAt;
  final LocalizationMeta? localization;

  const EmployeeProjectPhotoEntity({
    required this.id,
    required this.url,
    this.fileType,
    this.fileName,
    this.fileSize,
    this.isCover = false,
    this.category,
    this.createdAt,
    this.localization,
  });
}

class EmployeeProjectTaskEntity {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String priority;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? employeeName;
  final String? employeeAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final LocalizationMeta? localization;

  const EmployeeProjectTaskEntity({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.priority = 'MEDIUM',
    this.isCompleted = false,
    this.dueDate,
    this.employeeName,
    this.employeeAvatar,
    this.createdAt,
    this.updatedAt,
    this.localization,
  });

  EmployeeProjectTaskEntity copyWith({bool? isCompleted}) {
    return EmployeeProjectTaskEntity(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      priority: priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate,
      employeeName: employeeName,
      employeeAvatar: employeeAvatar,
      createdAt: createdAt,
      updatedAt: updatedAt,
      localization: localization,
    );
  }
}

class EmployeeProjectDetailsEntity {
  final String id;
  final String name;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? siteAccessCode;
  final String? siteAccessNotes;
  final num scaffoldArea;
  final String? scaffoldLabel;
  final EmployeeProjectPhaseEntity? phase;
  final EmployeeProjectManagerEntity? siteManager;
  final int photoCount;
  final List<EmployeeProjectPhotoEntity> photos;
  final int taskCount;
  final List<EmployeeProjectTaskEntity> tasks;
  final LocalizationMeta? localization;

  const EmployeeProjectDetailsEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.latitude,
    this.longitude,
    this.siteAccessCode,
    this.siteAccessNotes,
    this.scaffoldArea = 0,
    this.scaffoldLabel,
    this.phase,
    this.siteManager,
    this.photoCount = 0,
    this.photos = const [],
    this.taskCount = 0,
    this.tasks = const [],
    this.localization,
  });

  bool get hasLocation => latitude != null && longitude != null;

  String get fullAddress {
    if (city.isEmpty) return address;
    if (address.isEmpty) return city;
    return '$address, $city';
  }
}
