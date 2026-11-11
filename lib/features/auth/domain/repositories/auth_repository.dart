import '../../../../core/enums/app_enum.dart';
import '../../data/dtos/recovery_dtos.dart';
import '../entities/auth_session.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<String> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });

  Future<AuthSession> verifyOtp({
    required String otp,
    required String deviceIdentifier,
    String? fcmToken,
    double? lat,
    double? lng,
    String? otpPageToken,
  });

  Future<void> resendOtp({String? otpPageToken});

  Future<AuthSession> login({
    required String email,
    required String password,
    required UserRole role,
    required String deviceIdentifier,
    bool rememberMe = false,
    String? fcmToken,
    double? lat,
    double? lng,
  });

  Future<AuthUser?> checkSession({
    required String deviceIdentifier,
    String? fcmToken,
    double? lat,
    double? lng,
  });

  Future<void> logout();

  AuthUser? getCurrentUser();

  Future<RecoverUserData> findUserForRecovery({required String email});

  Future<String> resendRecoveryOtp({String? recoveryToken});

  Future<bool> verifyRecoveryOtp({
    required String otp,
    String? recoveryToken,
  });

  Future<void> resetPasswordWithRecoveryToken({
    required String password,
    required String confirmPassword,
    String? recoveryToken,
  });
}
