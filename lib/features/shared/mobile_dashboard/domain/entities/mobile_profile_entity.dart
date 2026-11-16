class MobileProfileEntity {
  const MobileProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.email,
    required this.phone,
    this.avatarUrl,
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
  final double weeklyHoursTarget;
  final double hoursThisWeek;
  final int assignedProjectsCount;
  final int completedProjectsCount;

  String get fullName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? email : full;
  }
}
