enum AppLogType { error, success, warning, defaultLog }

enum AppToastType { success, error, warning, info }

enum ApiStatus { loading, error, completed, internetError, noDataFound }

//
enum UserRole {
  siteManager,
  employee;

  bool get isSiteManager => this == UserRole.siteManager;
  bool get isEmployee => this == UserRole.employee;

  String get label {
    switch (this) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.siteManager:
        return 'Site Manager';
    }
  }
}

extension UserRoleX on UserRole {
  bool get isSiteManager => this == UserRole.siteManager;
  bool get isEmployee => this == UserRole.employee;
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.siteManager:
        return 'SITE_MANAGER';

      case UserRole.employee:
        return 'EMPLOYEE';
    }
  }

  static UserRole? fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'site_manager':
      case 'sitemanager':
      case 'site manager':
        return UserRole.siteManager;

      case 'employee':
        return UserRole.employee;

      default:
        return null;
    }
  }
}
