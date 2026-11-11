import 'dart:math';

import '../constants/storage_keys.dart';
import '../utils/jwt_helper.dart';
import 'local_storage.dart';
import 'secure_storage.dart';

class StorageService {
  StorageService({
    required this.secureStorage,
    required this.localStorage,
  });

  final SecureStorage secureStorage;
  final LocalStorage localStorage;

  // ==============================
  // Authentication & Tokens
  // ==============================

  Future<void> saveAccessToken(String token) async {
    await secureStorage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() {
    return secureStorage.read(key: StorageKeys.accessToken);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.trim().isNotEmpty;
  }

  Future<bool> hasValidAccessToken() async {
    final token = await getAccessToken();
    if (token == null || token.trim().isEmpty) return false;
    return !JwtHelper.isExpired(token);
  }

  Future<void> saveOtpPageToken(String token) async {
    await secureStorage.write(key: StorageKeys.otpPageToken, value: token);
  }

  Future<String?> getOtpPageToken() {
    return secureStorage.read(key: StorageKeys.otpPageToken);
  }

  Future<void> clearOtpPageToken() async {
    await secureStorage.delete(key: StorageKeys.otpPageToken);
  }

  Future<void> savePasswordResetToken(String token) async {
    await secureStorage.write(
      key: StorageKeys.passwordResetToken,
      value: token,
    );
  }

  Future<String?> getPasswordResetToken() {
    return secureStorage.read(key: StorageKeys.passwordResetToken);
  }

  Future<void> clearPasswordResetToken() async {
    await secureStorage.delete(key: StorageKeys.passwordResetToken);
  }

  Future<void> saveFcmToken(String token) async {
    await secureStorage.write(key: StorageKeys.fcmToken, value: token);
  }

  Future<String?> getFcmToken() {
    return secureStorage.read(key: StorageKeys.fcmToken);
  }

  Future<void> clearFcmToken() async {
    await secureStorage.delete(key: StorageKeys.fcmToken);
  }

  // ==============================
  // User & Role Persistence
  // ==============================

  Future<void> saveCurrentUserJson(String userJson) async {
    await localStorage.setString(StorageKeys.currentUser, userJson);
  }

  String? getCurrentUserJson() =>
      localStorage.getString(StorageKeys.currentUser);

  Future<void> saveUserRole(String role) async {
    await localStorage.setString(StorageKeys.userRole, role);
  }

  String? getUserRole() => localStorage.getString(StorageKeys.userRole);

  Future<void> saveUserEmail(String email) async {
    if (email.trim().isNotEmpty) {
      await localStorage.setString(StorageKeys.userEmail, email.trim());
    }
  }

  String? getUserEmail() => localStorage.getString(StorageKeys.userEmail);

  // ==============================
  // Preferences & Flags
  // ==============================

  Future<void> setRememberMe(bool value) async {
    await localStorage.setBool(StorageKeys.rememberMe, value);
    if (!value) {
      await localStorage.remove(StorageKeys.rememberedEmail);
    }
  }

  bool get rememberMe => localStorage.getBool(StorageKeys.rememberMe) ?? false;

  Future<void> setRememberedEmail(String email) async {
    await localStorage.setString(StorageKeys.rememberedEmail, email.trim());
  }

  String? get rememberedEmail =>
      localStorage.getString(StorageKeys.rememberedEmail);

  Future<void> setOnboardingCompleted(bool value) async {
    await localStorage.setBool(StorageKeys.onboardingCompleted, value);
  }

  bool get onboardingCompleted =>
      localStorage.getBool(StorageKeys.onboardingCompleted) ?? false;

  String? get selectedLanguage =>
      localStorage.getString(StorageKeys.selectedLanguage);

  // ==============================
  // Device Identifier
  // ==============================

  Future<String> getOrCreateDeviceIdentifier() async {
    var deviceId = localStorage.getString(StorageKeys.deviceIdentifier);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = await secureStorage.read(key: StorageKeys.deviceIdentifier);
    }

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _generateUuidV4();
      await localStorage.setString(StorageKeys.deviceIdentifier, deviceId);
      await secureStorage.write(
        key: StorageKeys.deviceIdentifier,
        value: deviceId,
      );
    }

    return deviceId;
  }

  static String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final parts = bytes.map(hex).join();
    return '${parts.substring(0, 8)}-'
        '${parts.substring(8, 12)}-'
        '${parts.substring(12, 16)}-'
        '${parts.substring(16, 20)}-'
        '${parts.substring(20, 32)}';
  }

  // ==============================
  // Clear / Logout
  // ==============================

  Future<void> clearAuthentication() async {
    await secureStorage.delete(key: StorageKeys.accessToken);
    await secureStorage.delete(key: StorageKeys.otpPageToken);
    await secureStorage.delete(key: StorageKeys.passwordResetToken);
    await secureStorage.delete(key: StorageKeys.refreshToken);
    await localStorage.remove(StorageKeys.currentUser);
    await localStorage.remove(StorageKeys.userRole);
    await localStorage.remove(StorageKeys.userEmail);
  }

  Future<void> logout() async {
    await clearAuthentication();
    if (!rememberMe) {
      await localStorage.remove(StorageKeys.rememberedEmail);
    }
  }
}
