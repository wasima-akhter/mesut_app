import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';

class EmployeeTimerState {
  final bool isTimerRunning;
  final bool isOnBreak;
  final bool showThisMonth;
  final Duration elapsed;
  final EmployeeProjectModel currentProject;
  final EmployeeActivityType currentActivity;
  final List<EmployeeTimeLogModel> logs;
  final String? activeTimeLogId;
  final DateTime? sessionStartedAt;
  final Duration breakDuration;
  final bool isActionLoading;
  final String? errorMessage;
  final int graceSecondsRemaining;

  const EmployeeTimerState({
    required this.isTimerRunning,
    required this.isOnBreak,
    required this.showThisMonth,
    required this.elapsed,
    required this.currentProject,
    required this.currentActivity,
    required this.logs,
    this.activeTimeLogId,
    this.sessionStartedAt,
    this.breakDuration = Duration.zero,
    this.isActionLoading = false,
    this.errorMessage,
    this.graceSecondsRemaining = 0,
  });

  EmployeeTimerState copyWith({
    bool? isTimerRunning,
    bool? isOnBreak,
    bool? showThisMonth,
    Duration? elapsed,
    EmployeeProjectModel? currentProject,
    EmployeeActivityType? currentActivity,
    List<EmployeeTimeLogModel>? logs,
    String? activeTimeLogId,
    bool clearActiveTimeLogId = false,
    DateTime? sessionStartedAt,
    bool clearSessionStartedAt = false,
    Duration? breakDuration,
    bool? isActionLoading,
    String? errorMessage,
    bool clearError = false,
    int? graceSecondsRemaining,
  }) {
    return EmployeeTimerState(
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      showThisMonth: showThisMonth ?? this.showThisMonth,
      elapsed: elapsed ?? this.elapsed,
      currentProject: currentProject ?? this.currentProject,
      currentActivity: currentActivity ?? this.currentActivity,
      logs: logs ?? this.logs,
      activeTimeLogId: clearActiveTimeLogId
          ? null
          : (activeTimeLogId ?? this.activeTimeLogId),
      sessionStartedAt: clearSessionStartedAt
          ? null
          : (sessionStartedAt ?? this.sessionStartedAt),
      breakDuration: breakDuration ?? this.breakDuration,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      graceSecondsRemaining:
          graceSecondsRemaining ?? this.graceSecondsRemaining,
    );
  }

  List<EmployeeTimeLogModel> get visibleLogs {
    if (!showThisMonth) return logs;
    return [...logs, ...logs];
  }

  String get formattedElapsed {
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String get formattedBreak {
    final minutes = breakDuration.inMinutes;
    return '${minutes}m';
  }

  bool get hasActiveRemoteTimer =>
      activeTimeLogId != null && activeTimeLogId!.isNotEmpty;

  bool get isGracePeriod => isTimerRunning && graceSecondsRemaining > 0;

  bool get canCancel => isTimerRunning && graceSecondsRemaining > 0;
}
