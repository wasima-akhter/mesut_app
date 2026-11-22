import 'dart:async';
import 'package:construction_app/core/helpers/device_location_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/employee_time_tracking_datasource.dart';
import '../../domain/entities/employee_time_tracking_entities.dart';
import 'employee_timer_helpers.dart';
import 'employee_time_tracking_state.dart';

export 'employee_time_tracking_state.dart';

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

  String _toFriendlyError(Object error) {
    final str = error.toString().toLowerCase();
    if (error is DioException) {
      final t = error.type;
      final isConn = t == DioExceptionType.connectionTimeout ||
          t == DioExceptionType.sendTimeout ||
          t == DioExceptionType.receiveTimeout ||
          t == DioExceptionType.connectionError ||
          str.contains('failed host lookup') ||
          str.contains('socketexception') ||
          str.contains('no address associated');
      if (isConn) return 'No internet connection. Please check your network and try again.';
      final code = error.response?.statusCode;
      if (code != null) {
        if (code >= 500) return 'Server is temporarily unavailable. Please try again shortly.';
        if (code == 401 || code == 403) return 'Session expired. Please sign in again.';
        if (code == 404) return 'No time logs found for this period.';
      }
    }
    if (str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('connection') ||
        str.contains('network') ||
        str.contains('timeout')) {
      return 'No internet connection. Please check your network and try again.';
    }
    return 'Unable to load time tracking data. Please try again.';
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      EmployeeTimeSummaryEntity summary = const EmployeeTimeSummaryEntity();
      List<EmployeeAssignedProjectEntity> projects = const [];
      List<EmployeeRecentLogEntity> logs = const [];
      Object? loadError;

      try { summary = await _datasource.getSummary(); } catch (e) { loadError = e; }
      try { projects = await _datasource.getProjects(); } catch (e) { loadError ??= e; }
      try {
        logs = await _datasource.getTimeLogs(period: state.selectedPeriod);
      } catch (e) {
        loadError ??= e;
      }

      _syncActiveTimerTicker(summary.activeTimer);

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        projects: projects,
        recentLogs: logs,
        logsPage: 1,
        hasMoreLogs: logs.length >= 20,
        errorMessage: (logs.isEmpty && loadError != null) ? _toFriendlyError(loadError) : null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _toFriendlyError(e));
    }
  }

  Future<void> refresh() async => loadInitial();

  void _syncActiveTimerTicker(EmployeeActiveTimerEntity? timer) {
    _ticker?.cancel();
    if (timer == null) {
      state = state.copyWith(activeElapsed: Duration.zero, isOnBreak: false);
      return;
    }

    final initialElapsed = DateTime.now().difference(timer.startTime);
    state = state.copyWith(activeElapsed: initialElapsed);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isOnBreak || !state.isTimerRunning) return;
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
      state = state.copyWith(isActionLoading: false, errorMessage: _toFriendlyError(e));
      return false;
    }
  }

  void _clearLocalActiveTimer() {
    final cur = state.summary;
    state = state.copyWith(
      summary: EmployeeTimeSummaryEntity(
        todayHours: cur.todayHours,
        weekHours: cur.weekHours,
        weeklyHoursTarget: cur.weeklyHoursTarget,
        weekNumber: cur.weekNumber,
        weekStartDate: cur.weekStartDate,
        weekEndDate: cur.weekEndDate,
        activeTimer: null,
      ),
      activeElapsed: Duration.zero,
      isOnBreak: false,
    );
  }

  Future<bool> stopTimer({double? lat, double? lng}) async {
    _ticker?.cancel();
    _ticker = null;
    final activeId = state.summary.activeTimer?.id ??
        await EmployeeTimerHelpers.resolveActiveTimeLogId(ref: ref);
    _clearLocalActiveTimer();
    if (activeId == null || activeId.isEmpty) return false;

    state = state.copyWith(isActionLoading: true);
    try {
      final coords = (lat != null && lng != null)
          ? null
          : await DeviceLocationHelper.tryGetCoordinates();
      await _datasource.stopTimer(
        timeLogId: activeId,
        gpsEndLat: lat ?? coords?.lat,
        gpsEndLng: lng ?? coords?.lng,
      );
      await refresh();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: _toFriendlyError(e));
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
      state = state.copyWith(isActionLoading: false, errorMessage: _toFriendlyError(e));
      return false;
    }
  }
}

final employeeTimeTrackingProvider =
    NotifierProvider<EmployeeTimeTrackingNotifier, EmployeeTimeTrackingState>(
  EmployeeTimeTrackingNotifier.new,
);
