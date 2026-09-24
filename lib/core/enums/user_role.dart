enum UserRole {
  employee,
  siteManager;

  String get label {
    switch (this) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.siteManager:
        return 'Site Manager';
    }
  }
}
