import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/employee_time_tracking_datasource.dart';
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
    final hours = activeElapsed.inHours.toString().padLeft(2, '0');
    final minutes = activeElapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = activeElapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
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
  }) {
    return EmployeeTimeTrackingState(
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
}

class EmployeeTimeTrackingNotifier extends Notifier<EmployeeTimeTrackingState> {
  Timer? _ticker;

  @override
  EmployeeTimeTrackingState build() {
    ref.onDispose(() {
      _ticker?.cancel();
    });
    Future.microtask(loadInitial);
    return const EmployeeTimeTrackingState(isLoading: true);
  }

  EmployeeTimeTrackingDatasource get _datasource =>
      ref.read(employeeTimeTrackingDatasourceProvider);

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        _datasource.getSummary(),
        _datasource.getProjects(),
        _datasource.getTimeLogs(period: state.selectedPeriod),
      ]);

      final summary = results[0] as EmployeeTimeSummaryEntity;
      final projects = results[1] as List<EmployeeAssignedProjectEntity>;
      final logs = results[2] as List<EmployeeRecentLogEntity>;

      _syncActiveTimerTicker(summary.activeTimer);

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        projects: projects,
        recentLogs: logs,
        logsPage: 1,
        hasMoreLogs: logs.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _datasource.getSummary(),
        _datasource.getTimeLogs(period: state.selectedPeriod, page: 1, limit: 20),
      ]);
      final summary = results[0] as EmployeeTimeSummaryEntity;
      final logs = results[1] as List<EmployeeRecentLogEntity>;

      _syncActiveTimerTicker(summary.activeTimer);

      state = state.copyWith(
        summary: summary,
        recentLogs: logs,
        logsPage: 1,
        hasMoreLogs: logs.length >= 20,
      );
    } catch (_) {}
  }

  void _syncActiveTimerTicker(EmployeeActiveTimerEntity? timer) {
    _ticker?.cancel();
    if (timer == null) {
      state = state.copyWith(activeElapsed: Duration.zero, isOnBreak: false);
      return;
    }

    final initialElapsed = DateTime.now().difference(timer.startTime);
    state = state.copyWith(activeElapsed: initialElapsed);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isOnBreak) return;
      state = state.copyWith(activeElapsed: state.activeElapsed + const Duration(seconds: 1));
    });
  }

  void toggleBreak() {
    state = state.copyWith(isOnBreak: !state.isOnBreak);
  }

  Future<void> togglePeriod() async {
    final newPeriod = state.selectedPeriod == 'WEEK' ? 'MONTH' : 'WEEK';
    state = state.copyWith(selectedPeriod: newPeriod, isLoading: true, logsPage: 1);
    try {
      final logs = await _datasource.getTimeLogs(period: newPeriod, page: 1, limit: 20);
      state = state.copyWith(
        isLoading: false,
        recentLogs: logs,
        logsPage: 1,
        hasMoreLogs: logs.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMoreLogs() async {
    if (state.isLoading || state.isLoadingMoreLogs || !state.hasMoreLogs) return;
    final nextPage = state.logsPage + 1;
    state = state.copyWith(isLoadingMoreLogs: true);
    try {
      final more = await _datasource.getTimeLogs(
        period: state.selectedPeriod,
        page: nextPage,
        limit: 20,
      );
      state = state.copyWith(
        isLoadingMoreLogs: false,
        recentLogs: [...state.recentLogs, ...more],
        logsPage: nextPage,
        hasMoreLogs: more.length >= 20,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMoreLogs: false);
    }
  }

  Future<bool> startTimer({
    required String projectId,
    required String activityType,
  }) async {
    state = state.copyWith(isActionLoading: true);
    try {
      final timer = await _datasource.startTimer(
        projectId: projectId,
        activityType: activityType,
      );
      if (timer != null) {
        _syncActiveTimerTicker(timer);
        final newSummary = EmployeeTimeSummaryEntity(
          todayHours: state.summary.todayHours,
          weekHours: state.summary.weekHours,
          weeklyHoursTarget: state.summary.weeklyHoursTarget,
          weekNumber: state.summary.weekNumber,
          weekStartDate: state.summary.weekStartDate,
          weekEndDate: state.summary.weekEndDate,
          activeTimer: timer,
        );
        state = state.copyWith(isActionLoading: false, summary: newSummary);
        return true;
      }
      await refresh();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> stopTimer({double? lat, double? lng}) async {
    final activeId = state.summary.activeTimer?.id;
    if (activeId == null) return false;

    state = state.copyWith(isActionLoading: true);
    try {
      await _datasource.stopTimer(timeLogId: activeId, gpsEndLat: lat, gpsEndLng: lng);
      _ticker?.cancel();
      await refresh();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> addManualTime({
    required String projectId,
    required String activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  }) async {
    state = state.copyWith(isActionLoading: true);
    try {
      await _datasource.addManualTime(
        projectId: projectId,
        activityType: activityType,
        startTime: startTime,
        endTime: endTime,
        breakMinutes: breakMinutes,
      );
      await refresh();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final employeeTimeTrackingProvider =
    NotifierProvider<EmployeeTimeTrackingNotifier, EmployeeTimeTrackingState>(
  EmployeeTimeTrackingNotifier.new,
);
