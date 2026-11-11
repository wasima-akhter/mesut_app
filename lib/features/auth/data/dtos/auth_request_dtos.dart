import 'dart:io';

import '../../../../core/enums/app_enum.dart';
import '../../../../core/enums/backend_enums.dart';

class SignupRequestDto {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final UserRole role;
  final String password;

  const SignupRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'role': BackendRole.fromUserRole(role).serializedName,
      'password': password,
    };
  }
}

class VerifyOtpRequestDto {
  final String otp;
  final String deviceIdentifier;
  final String? fcmToken;
  final String platform;
  final double? lat;
  final double? lng;

  VerifyOtpRequestDto({
    required this.otp,
    required this.deviceIdentifier,
    this.fcmToken,
    String? platform,
    this.lat,
    this.lng,
  }) : platform = platform ?? (Platform.isIOS ? 'IOS' : 'ANDROID');

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'otp': otp.trim(),
      'deviceIdentifier': deviceIdentifier,
      'platform': platform,
      'lat': lat ?? 0.0,
      'lng': lng ?? 0.0,
    };
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      map['fcmToken'] = fcmToken;
    }
    return map;
  }
}

class LoginRequestDto {
  final String email;
  final String password;
  final UserRole role;
  final String deviceIdentifier;
  final String? fcmToken;
  final String platform;
  final double? lat;
  final double? lng;
  final bool rememberMe;

  LoginRequestDto({
    required this.email,
    required this.password,
    required this.role,
    required this.deviceIdentifier,
    this.fcmToken,
    String? platform,
    this.lat,
    this.lng,
    this.rememberMe = false,
  }) : platform = platform ?? (Platform.isIOS ? 'IOS' : 'ANDROID');

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': BackendRole.fromUserRole(role).serializedName,
      'deviceIdentifier': deviceIdentifier,
      'platform': platform,
      'lat': lat ?? 0.0,
      'lng': lng ?? 0.0,
      'rememberMe': rememberMe,
    };
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      map['fcmToken'] = fcmToken;
    }
    return map;
  }
}

class CheckSessionRequestDto {
  final String deviceIdentifier;
  final String platform;
  final String? fcmToken;
  final double? lat;
  final double? lng;

  CheckSessionRequestDto({
    required this.deviceIdentifier,
    String? platform,
    this.fcmToken,
    this.lat,
    this.lng,
  }) : platform = platform ?? (Platform.isIOS ? 'IOS' : 'ANDROID');

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'deviceIdentifier': deviceIdentifier,
      'platform': platform,
      'lat': lat ?? 0.0,
      'lng': lng ?? 0.0,
    };
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      map['fcmToken'] = fcmToken;
    }
    return map;
  }
}
