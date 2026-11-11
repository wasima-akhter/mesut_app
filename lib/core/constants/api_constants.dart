abstract final class ApiConstants {
  // ==============================
  // System & Health
  // ==============================
  static const String health = '/health';

  // ==============================
  // Authentication Endpoints
  // ==============================
  static const String signup = '/auth/signup';
  static const String verify = '/auth/verify';
  static const String resend = '/auth/resend';
  static const String login = '/auth/login';
  static const String check = '/auth/check';
  static const String logout = '/auth/logout';

  // ==============================
  // Password Recovery Endpoints
  // ==============================
  static const String recoverFind = '/recover/find';
  static const String recoverResend = '/recover/resend';
  static const String recoverVerify = '/recover/verify';
  static const String recoverReset = '/recover/reset';

  // Admin Password Recovery Endpoints
  static const String adminRecoverFind = '/admin/recover/find';
  static const String adminRecoverResend = '/admin/recover/resend';
  static const String adminRecoverVerify = '/admin/recover/verify';
  static const String adminRecoverReset = '/admin/recover/reset';

  // ==============================
  // Media Endpoints
  // ==============================
  static const String media = '/media';
}
