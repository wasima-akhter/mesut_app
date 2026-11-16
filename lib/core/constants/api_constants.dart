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

  // ==============================
  // Mobile Endpoints (§4)
  // ==============================
  static const String mobileConfig = '/mobile/config';
  static const String mobileDashboard = '/mobile/dashboard';
  static const String mobileProjects = '/mobile/projects';
  static String mobileProjectById(String id) => '/mobile/projects/$id';
  static String mobileProjectTasks(String id) => '/mobile/projects/$id/tasks';
  static String mobileTaskToggle(String taskId) => '/mobile/tasks/$taskId/toggle';
  static String mobileTaskDelete(String taskId) => '/mobile/tasks/$taskId';
  static const String mobileProfile = '/mobile/profile';
  static const String mobileSchedule = '/mobile/schedule';
  static const String mobileMap = '/mobile/map';
  static const String mobileCustomers = '/mobile/customers';
  static const String mobileInspections = '/mobile/inspections';
  static String mobileInspectionById(String id) => '/mobile/inspections/$id';
  static String mobileInspectionComplete(String id) =>
      '/mobile/inspections/$id/complete';
  static const String mobilePhases = '/mobile/phases';
  static String mobilePhaseStatus(String id) => '/mobile/phases/$id/status';
  static const String mobileTimerStart = '/mobile/timer/start';
  static const String mobileTimerStop = '/mobile/timer/stop';
  static const String mobileTimerManual = '/mobile/timer/manual';
  static const String mobileTimeLogs = '/mobile/time-logs';
  static const String mobileCrewTime = '/mobile/crew-time';
  static const String mobileSync = '/mobile/sync';
  static const String mobileNotifications = '/mobile/notifications';
  static const String mobileNotificationsReadAll =
      '/mobile/notifications/read-all';

  static String mobileNotificationRead(String id) =>
      '/mobile/notifications/$id/read';

  // ==============================
  // Socket.IO Namespaces (§5)
  // ==============================
  static const String notificationSocketNamespace = '/api/v1/notification';
}
