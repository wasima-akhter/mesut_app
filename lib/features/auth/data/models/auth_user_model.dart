import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    required super.role,
    super.avatarUrl,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      role: _roleFromString(json['role'] as String?),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'avatarUrl': avatarUrl,
    };
  }

  static UserRole _roleFromString(String? roleStr) {
    switch (roleStr) {
      case 'siteManager':
      case 'site_manager':
        return UserRole.siteManager;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.employee;
    }
  }
}
