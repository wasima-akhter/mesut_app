abstract final class StorageKeys {
  // ==============================
  // Authentication Tokens
  // ==============================
  static const String accessToken = 'access_token';
  static const String otpPageToken = 'otp_page_token';
  static const String passwordResetToken = 'password_reset_token';
  static const String refreshToken = 'refresh_token';

  // ==============================
  // User & Session
  // ==============================
  static const String currentUser = 'current_user';
  static const String userRole = 'user_role';
  static const String userEmail = 'user_email';
  static const String deviceIdentifier = 'device_identifier';
  static const String fcmToken = 'fcm_token';

  // ==============================
  // Flags & Preferences
  // ==============================
  static const String rememberMe = 'remember_me';
  static const String rememberedEmail = 'remembered_email';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String selectedLanguage = 'selected_language_code';
  static const String hasUserSelectedLanguage = 'has_user_selected_language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String lastSyncTime = 'last_sync_time';
  static const String mobileConfigCache = 'mobile_config_cache';
  static const String offlineTimeLogsQueue = 'offline_time_logs_queue';
}
