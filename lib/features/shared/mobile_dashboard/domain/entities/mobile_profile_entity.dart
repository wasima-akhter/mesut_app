class MobileProfileEntity {
  const MobileProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.language = 'DE',
    this.weeklyHoursTarget = 0,
    this.hoursThisWeek = 0,
    this.assignedProjectsCount = 0,
    this.completedProjectsCount = 0,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String language;
  final double weeklyHoursTarget;
  final double hoursThisWeek;
  final int assignedProjectsCount;
  final int completedProjectsCount;

  String get fullName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? email : full;
  }

  MobileProfileEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? role,
    String? email,
    String? phone,
    String? avatarUrl,
    String? language,
    double? weeklyHoursTarget,
    double? hoursThisWeek,
    int? assignedProjectsCount,
    int? completedProjectsCount,
  }) {
    return MobileProfileEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      weeklyHoursTarget: weeklyHoursTarget ?? this.weeklyHoursTarget,
      hoursThisWeek: hoursThisWeek ?? this.hoursThisWeek,
      assignedProjectsCount:
          assignedProjectsCount ?? this.assignedProjectsCount,
      completedProjectsCount:
          completedProjectsCount ?? this.completedProjectsCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'language': language,
        'weeklyHoursTarget': weeklyHoursTarget,
        'hoursThisWeek': hoursThisWeek,
        'assignedProjectsCount': assignedProjectsCount,
        'completedProjectsCount': completedProjectsCount,
      };
}
