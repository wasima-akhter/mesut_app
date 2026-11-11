import 'dart:convert';

import 'package:construction_app/core/enums/app_enum.dart';
import 'package:construction_app/core/enums/backend_enums.dart';
import 'package:construction_app/core/errors/app_error_resolver.dart';
import 'package:construction_app/core/utils/jwt_helper.dart';
import 'package:construction_app/features/auth/data/dtos/auth_request_dtos.dart';
import 'package:construction_app/features/auth/data/models/auth_user_model.dart';
import 'package:construction_app/features/media/data/dtos/media_dtos.dart';
import 'package:flutter_test/flutter_test.dart';

String _buildTestJwt(Map<String, dynamic> payload) {
  final header = base64Url
      .encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})))
      .replaceAll('=', '');
  final body = base64Url
      .encode(utf8.encode(jsonEncode(payload)))
      .replaceAll('=', '');
  return '$header.$body.signature';
}

void main() {
  group('JwtHelper', () {
    test('extracts email, role, userId and checks expiry', () {
      final futureExp =
          DateTime.now().toUtc().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000;
      final token = _buildTestJwt({
        'userId': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'john.doe@example.com',
        'role': 'EMPLOYEE',
        'exp': futureExp,
      });

      expect(JwtHelper.extractEmail(token), 'john.doe@example.com');
      expect(JwtHelper.extractRole(token), 'EMPLOYEE');
      expect(
        JwtHelper.extractUserId(token),
        '123e4567-e89b-12d3-a456-426614174000',
      );
      expect(JwtHelper.isExpired(token), isFalse);
    });

    test('detects expired token', () {
      final pastExp =
          DateTime.now().toUtc().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch ~/
          1000;
      final token = _buildTestJwt({'exp': pastExp});
      expect(JwtHelper.isExpired(token), isTrue);
    });
  });

  group('Auth DTOs & Models', () {
    test('SignupRequestDto matches Auth_and_media.txt schema', () {
      const dto = SignupRequestDto(
        firstName: 'John',
        lastName: 'Doe',
        email: 'John.Doe@Example.com',
        phone: '1234567890',
        role: UserRole.employee,
        password: 'SecretP@ssw0rd',
      );

      expect(dto.toJson(), {
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john.doe@example.com',
        'phone': '1234567890',
        'role': 'EMPLOYEE',
        'password': 'SecretP@ssw0rd',
      });
    });

    test('LoginRequestDto matches Auth_and_media.txt schema', () {
      final dto = LoginRequestDto(
        email: 'john.doe@example.com',
        password: 'SecretP@ssw0rd',
        role: UserRole.siteManager,
        deviceIdentifier: 'device-123',
        fcmToken: 'fcm-xyz',
        platform: 'ANDROID',
        lat: 52.52,
        lng: 13.405,
        rememberMe: true,
      );

      expect(dto.toJson(), {
        'email': 'john.doe@example.com',
        'password': 'SecretP@ssw0rd',
        'role': 'SITE_MANAGER',
        'deviceIdentifier': 'device-123',
        'platform': 'ANDROID',
        'rememberMe': true,
        'fcmToken': 'fcm-xyz',
        'lat': 52.52,
        'lng': 13.405,
      });
    });

    test('AuthUserModel parses login user & verify response shapes', () {
      final loginUser = AuthUserModel.fromJson({
        'userId': 'u-1',
        'fullName': 'John Doe',
        'email': 'john@example.com',
        'phone': '+1234567890',
        'role': 'EMPLOYEE',
        'status': 'ACTIVE',
        'isProfileSetup': true,
        'language': 'DE',
      });

      expect(loginUser.id, 'u-1');
      expect(loginUser.fullName, 'John Doe');
      expect(loginUser.role, UserRole.employee);
      expect(loginUser.status, UserStatus.active);
      expect(loginUser.isProfileSetup, isTrue);

      final verifyUser = AuthUserModel.fromJson({
        'id': 'u-2',
        'fullName': 'Max Mustermann',
        'role': 'SITE_MANAGER',
        'accountStatus': 'INACTIVE',
        'isProfileSetup': false,
      });

      expect(verifyUser.id, 'u-2');
      expect(verifyUser.role, UserRole.siteManager);
      expect(verifyUser.status, UserStatus.inactive);
    });
  });

  group('MediaUploadResponseDto', () {
    test('parses data list of URLs', () {
      final dto = MediaUploadResponseDto.fromJson({
        'success': true,
        'message': 'Media uploads successful',
        'data': [
          'https://allround-bucket.s3.amazonaws.com/attachments/a.jpg',
        ],
        'traceId': 'trace-1',
      });

      expect(dto.success, isTrue);
      expect(dto.urls, [
        'https://allround-bucket.s3.amazonaws.com/attachments/a.jpg',
      ]);
    });
  });

  group('AppErrorResolver (EN & DE)', () {
    test('resolves INVALID_CREDENTIALS in EN and DE', () {
      final map = {
        'success': false,
        'message': 'Invalid Credential',
        'errorType': 'INVALID_CREDENTIALS',
      };

      final en = AppErrorResolver.resolve(map, languageCode: 'en');
      final de = AppErrorResolver.resolve(map, languageCode: 'de');

      expect(en.errorType, ApiErrorType.invalidCredentials);
      expect(en.title, 'Sign In Failed');
      expect(de.title, 'Anmeldung fehlgeschlagen');
    });

    test('shows top-level message instead of errors list on 422 validation', () {
      final map = {
        'success': false,
        'message': 'Request body validation failed',
        'errors': [
          {'field': 'password', 'message': 'Must include special char'},
        ],
      };

      final en = AppErrorResolver.resolve(map, languageCode: 'en');
      expect(en.errorType, ApiErrorType.validationError);
      expect(en.message, 'Request body validation failed');
    });

    test('suppresses 500 technical errors', () {
      final map = {
        'success': false,
        'statusCode': 500,
        'errorType': 'SERVER_ERROR',
        'message': 'Internal Postgres stack trace',
      };

      final de = AppErrorResolver.resolve(map, languageCode: 'de');
      expect(de.errorType, ApiErrorType.serverError);
      expect(de.message, isNot(contains('Postgres')));
    });
  });
}
