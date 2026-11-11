import '../../../../core/enums/backend_enums.dart';
import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phone,
    required super.role,
    super.status,
    super.isProfileSetup,
    super.avatarUrl,
    super.language,
  });

  factory AuthUserModel.fromEntity(AuthUser user) {
    return AuthUserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      role: user.role,
      status: user.status,
      isProfileSetup: user.isProfileSetup,
      avatarUrl: user.avatarUrl,
      language: user.language,
    );
  }

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final backendRole = BackendRole.fromString(json['role']?.toString());
    final statusStr =
        json['status']?.toString() ?? json['accountStatus']?.toString();
    final userStatus = UserStatus.fromString(
      statusStr,
      fallback: UserStatus.active,
    );

    return AuthUserModel(
      id: json['userId']?.toString() ??
          json['id']?.toString() ??
          json['code']?.toString() ??
          '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: backendRole.toUserRole(),
      status: userStatus,
      isProfileSetup: json['isProfileSetup'] as bool? ?? false,
      avatarUrl: json['avatarUrl']?.toString(),
      language: json['language']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': BackendRole.fromUserRole(role).serializedName,
      'status': status.serializedName,
      'isProfileSetup': isProfileSetup,
      'avatarUrl': avatarUrl,
      'language': language,
    };
  }
}
