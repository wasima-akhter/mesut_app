import '../../../../core/enums/app_enum.dart';
import '../../../../core/enums/backend_enums.dart';

class AuthUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final UserStatus status;
  final bool isProfileSetup;
  final String? avatarUrl;
  final String? language;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.status = UserStatus.active,
    this.isProfileSetup = false,
    this.avatarUrl,
    this.language,
  });

  String get name => fullName;

  bool get isInactive => status == UserStatus.inactive;
  bool get isSuspended => status == UserStatus.suspended;
  bool get isActive => status == UserStatus.active;

  AuthUser copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    UserStatus? status,
    bool? isProfileSetup,
    String? avatarUrl,
    String? language,
  }) {
    return AuthUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      isProfileSetup: isProfileSetup ?? this.isProfileSetup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
    );
  }
}
