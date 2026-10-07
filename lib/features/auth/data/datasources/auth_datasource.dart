import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';

abstract class AuthDataSource {
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<AuthUserModel> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });

  Future<void> sendForgotPasswordOtp({required String email});

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  Future<void> logout();

  Future<AuthUserModel?> getPersistedUser();
}

class AuthLocalMockDataSourceImpl implements AuthDataSource {
  static const String _userKey = 'current_auth_user';

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final user = AuthUserModel(
      id: role == UserRole.siteManager ? 'SM-001' : 'EMP-001',
      email: email,
      name: role == UserRole.siteManager ? 'Mesut Yilmaz' : 'Alex Becker',
      phone: '+49 170 1234567',
      role: role,
      avatarUrl: role == UserRole.siteManager
          ? 'https://randomuser.me/api/portraits/men/32.jpg'
          : 'https://randomuser.me/api/portraits/men/45.jpg',
    );

    await _persistUser(user);
    return user;
  }

  @override
  Future<AuthUserModel> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final user = AuthUserModel(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: fullName,
      phone: phone,
      role: role,
    );

    await _persistUser(user);
    return user;
  }

  @override
  Future<void> sendForgotPasswordOtp({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return otp.length == 4;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<AuthUserModel?> getPersistedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_userKey);
      if (jsonStr != null) {
        return AuthUserModel.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _persistUser(AuthUserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
    } catch (_) {}
  }
}
