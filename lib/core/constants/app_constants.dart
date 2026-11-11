abstract final class AppConstants {
  // ==============================
  // Application
  // ==============================
  static const String appName = 'Gerüstbau';

  // ==============================
  // API Timeouts
  // ==============================
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ==============================
  // Pagination & Cache
  // ==============================
  static const int defaultPage = 1;
  static const int defaultPageSize = 20;
  static const Duration cacheDuration = Duration(minutes: 15);

  // ==============================
  // Validation & Auth
  // ==============================
  static const int otpLength = 6;
  static const int passwordMinLength = 8;

  // ==============================
  // Debounce
  // ==============================
  static const Duration searchDebounce = Duration(milliseconds: 500);
}
