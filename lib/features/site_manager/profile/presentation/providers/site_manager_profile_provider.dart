import 'package:flutter_riverpod/flutter_riverpod.dart';

class SiteManagerProfileState {
  final String name;
  final String email;
  final String phone;

  const SiteManagerProfileState({
    required this.name,
    required this.email,
    required this.phone,
  });

  SiteManagerProfileState copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return SiteManagerProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

final siteManagerProfileProvider =
    NotifierProvider<SiteManagerProfileNotifier, SiteManagerProfileState>(
      SiteManagerProfileNotifier.new,
    );

class SiteManagerProfileNotifier extends Notifier<SiteManagerProfileState> {
  @override
  SiteManagerProfileState build() {
    return const SiteManagerProfileState(
      name: '',
      email: '',
      phone: '',
    );
  }

  void updateProfile({required String name, required String phone}) {
    state = state.copyWith(name: name, phone: phone);
  }
}
