import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeProfileState {
  final bool notificationsEnabled;
  final String name;
  final String email;
  final String phone;
  final String roleTitle;

  const EmployeeProfileState({
    required this.notificationsEnabled,
    required this.name,
    required this.email,
    required this.phone,
    required this.roleTitle,
  });

  EmployeeProfileState copyWith({
    bool? notificationsEnabled,
    String? name,
    String? email,
    String? phone,
    String? roleTitle,
  }) {
    return EmployeeProfileState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      roleTitle: roleTitle ?? this.roleTitle,
    );
  }
}

final employeeProfileProvider =
    NotifierProvider<EmployeeProfileNotifier, EmployeeProfileState>(
  EmployeeProfileNotifier.new,
);

class EmployeeProfileNotifier extends Notifier<EmployeeProfileState> {
  @override
  EmployeeProfileState build() {
    return const EmployeeProfileState(
      notificationsEnabled: true,
      name: 'Tim Muler',
      email: 'tim.muler@gmail.com',
      phone: '+49 170 1234567',
      roleTitle: 'Scaffolder / Gerüstbauer',
    );
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void updateProfile({required String name, required String phone}) {
    state = state.copyWith(name: name, phone: phone);
  }
}
