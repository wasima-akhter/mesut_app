import '../../domain/entities/employee_time_tracking_entities.dart';

class EmployeeTimeTrackingState {
  const EmployeeTimeTrackingState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.isLoadingMoreLogs = false,
    this.summary = const EmployeeTimeSummaryEntity(),
    this.projects = const [],
    this.recentLogs = const [],
    this.selectedPeriod = 'WEEK',
    this.logsPage = 1,
    this.hasMoreLogs = false,
    this.activeElapsed = Duration.zero,
    this.isOnBreak = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isActionLoading;
  final bool isLoadingMoreLogs;
  final EmployeeTimeSummaryEntity summary;
  final List<EmployeeAssignedProjectEntity> projects;
  final List<EmployeeRecentLogEntity> recentLogs;
  final String selectedPeriod;
  final int logsPage;
  final bool hasMoreLogs;
  final Duration activeElapsed;
  final bool isOnBreak;
  final String? errorMessage;

  bool get isTimerRunning => summary.hasActiveTimer;
  bool get showThisMonth => selectedPeriod == 'MONTH';

  String get formattedElapsed {
    final h = activeElapsed.inHours.toString().padLeft(2, '0');
    final m = activeElapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = activeElapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  EmployeeTimeTrackingState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    bool? isLoadingMoreLogs,
    EmployeeTimeSummaryEntity? summary,
    List<EmployeeAssignedProjectEntity>? projects,
    List<EmployeeRecentLogEntity>? recentLogs,
    String? selectedPeriod,
    int? logsPage,
    bool? hasMoreLogs,
    Duration? activeElapsed,
    bool? isOnBreak,
    String? errorMessage,
  }) => EmployeeTimeTrackingState(
    isLoading: isLoading ?? this.isLoading,
    isActionLoading: isActionLoading ?? this.isActionLoading,
    isLoadingMoreLogs: isLoadingMoreLogs ?? this.isLoadingMoreLogs,
    summary: summary ?? this.summary,
    projects: projects ?? this.projects,
    recentLogs: recentLogs ?? this.recentLogs,
    selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    logsPage: logsPage ?? this.logsPage,
    hasMoreLogs: hasMoreLogs ?? this.hasMoreLogs,
    activeElapsed: activeElapsed ?? this.activeElapsed,
    isOnBreak: isOnBreak ?? this.isOnBreak,
    errorMessage: errorMessage,
  );
}
