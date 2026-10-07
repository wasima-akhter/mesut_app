enum UserRole {
  employee,
  siteManager,
  admin,
}

class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.avatarUrl,
  });

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    String? avatarUrl,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
