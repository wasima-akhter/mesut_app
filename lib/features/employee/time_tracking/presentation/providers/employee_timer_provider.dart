import 'dart:async';

import 'package:construction_app/core/helpers/device_location_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';
import 'employee_timer_helpers.dart';
import 'employee_timer_state.dart';
import 'offline_sync_provider.dart';

export 'employee_timer_state.dart';

final employeeTimerProvider =
    NotifierProvider<EmployeeTimerNotifier, EmployeeTimerState>(
      EmployeeTimerNotifier.new,
    );

class EmployeeTimerNotifier extends Notifier<EmployeeTimerState>
    with WidgetsBindingObserver {
  Timer? _ticker;
  Duration _accumulatedBeforeRun = Duration.zero;
  DateTime? _runStartedAt;
  DateTime? _sessionStartedAt;
  DateTime? _breakStartedAt;
  Duration _totalBreakDuration = Duration.zero;
  bool _isDispatchedStart = false;

  @override
  EmployeeTimerState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _ticker?.cancel();
      _ticker = null;
    });

    return EmployeeTimerState(
      isTimerRunning: false,
      isOnBreak: false,
      showThisMonth: false,
      elapsed: Duration.zero,
      currentProject: EmployeeTimerHelpers.defaultProject,
      currentActivity: EmployeeActivityType.erection,
      logs: EmployeeTimerHelpers.defaultLogs,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isLeaving = state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached;
    if (isLeaving && this.state.isTimerRunning && !this.state.canCancel && this.state.graceSecondsRemaining == 0) {
      finishTimer();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _runStartedAt = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isTimerRunning || state.isOnBreak || _runStartedAt == null) {
        return;
      }
      final currentElapsed =
          _accumulatedBeforeRun + DateTime.now().difference(_runStartedAt!);
      final remainingGrace = state.graceSecondsRemaining > 0
          ? state.graceSecondsRemaining - 1
          : 0;

      state = state.copyWith(
        elapsed: currentElapsed,
        graceSecondsRemaining: remainingGrace,
      );

      if (remainingGrace == 0 && !_isDispatchedStart) {
        _isDispatchedStart = true;
        _dispatchStartApi();
      }
    });
  }

  Future<bool> startTimer({
    EmployeeProjectModel? project,
    EmployeeActivityType? activity,
  }) async {
    final activeProject = project ?? state.currentProject;
    final activeActivity = activity ?? state.currentActivity;

    _ticker?.cancel();
    _isDispatchedStart = false;
    _accumulatedBeforeRun = _totalBreakDuration = Duration.zero;
    _breakStartedAt = null;
    final now = DateTime.now().toUtc();
    _sessionStartedAt = now;
    _runStartedAt = DateTime.now();

    state = state.copyWith(
      isTimerRunning: true,
      isOnBreak: false,
      elapsed: Duration.zero,
      breakDuration: Duration.zero,
      sessionStartedAt: now,
      currentProject: activeProject,
      currentActivity: activeActivity,
      isActionLoading: false,
      clearError: true,
      graceSecondsRemaining: 5,
      clearActiveTimeLogId: true,
    );
    _startTicker();
    return true;
  }

  Future<void> _dispatchStartApi() async {
    final activeProject = state.currentProject;
    final activeActivity = state.currentActivity;
    try {
      final resolvedPhase = await EmployeeTimerHelpers.resolvePhaseId(
        ref: ref,
        rawId: activeProject.effectivePhaseId,
        activity: activeActivity,
        directPhaseId: activeProject.phaseId,
      );
      final backendActivity = EmployeeTimerHelpers.mapActivity(activeActivity);
      final coords = await DeviceLocationHelper.tryGetCoordinates();
      final remoteDs = ref.read(mobileTimerRemoteDataSourceProvider);
      final response = await remoteDs.startTimer(
        phaseId: resolvedPhase,
        activityType: backendActivity,
        lat: coords?.lat,
        lng: coords?.lng,
      );

      final timeLogId = EmployeeTimerHelpers.extractTimeLogId(response);
      state = state.copyWith(
        activeTimeLogId: timeLogId,
        isActionLoading: false,
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        final existingId = await EmployeeTimerHelpers.resolveActiveTimeLogId(
          ref: ref,
        );
        state = state.copyWith(
          activeTimeLogId: existingId,
          isActionLoading: false,
        );
      }
    }
  }

  void pauseTimer() {
    if (_runStartedAt != null) {
      _accumulatedBeforeRun += DateTime.now().difference(_runStartedAt!);
      _runStartedAt = null;
    }
    _breakStartedAt = DateTime.now().toUtc();
    _ticker?.cancel();
    _ticker = null;
    state = state.copyWith(
      isOnBreak: true,
      elapsed: _accumulatedBeforeRun,
      breakDuration: _totalBreakDuration,
    );
  }

  void resumeTimer() {
    if (!state.isTimerRunning) return;
    if (_breakStartedAt != null) {
      _totalBreakDuration += DateTime.now().toUtc().difference(_breakStartedAt!);
      _breakStartedAt = null;
    }
    state = state.copyWith(
      isOnBreak: false,
      breakDuration: _totalBreakDuration,
    );
    _startTicker();
  }

  void toggleBreak() {
    if (state.isOnBreak) {
      resumeTimer();
    } else {
      pauseTimer();
    }
  }

  Future<bool> finishTimer() async {
    final endTime = DateTime.now().toUtc();
    if (_breakStartedAt != null) {
      _totalBreakDuration += endTime.difference(_breakStartedAt!);
      _breakStartedAt = null;
    }

    final startTime = _sessionStartedAt ?? endTime.subtract(state.elapsed);
    final phaseId = state.currentProject.effectivePhaseId;
    final projectName = state.currentProject.fullName;
    final activity = EmployeeTimerHelpers.mapActivity(state.currentActivity);
    final breakMinutes = _totalBreakDuration.inMinutes;

    final elapsedMinutes = state.elapsed.inMinutes;
    final durationHours =
        double.parse((elapsedMinutes / 60).toStringAsFixed(1));

    final activeId = await EmployeeTimerHelpers.stopActiveTimer(
      ref: ref,
      currentId: state.activeTimeLogId,
      phaseId: phaseId,
      activity: activity,
      directPhaseId: state.currentProject.phaseId,
    );

    if (activeId == null || activeId.isEmpty) {
      EmployeeTimerHelpers.enqueueOfflineLog(
        ref: ref,
        phaseId: phaseId,
        activity: activity,
        startTime: startTime,
        endTime: endTime,
        breakMinutes: breakMinutes,
        projectName: projectName,
      );
    }

    final newLog = EmployeeTimeLogModel(
      timestamp: endTime,
      project: state.currentProject,
      duration: durationHours > 0 ? durationHours.toString() : '0.1',
      durationHours: durationHours > 0 ? durationHours : 0.1,
      breakTime: '${breakMinutes}m',
      breakDuration: _totalBreakDuration,
      synced: activeId != null && activeId.isNotEmpty,
    );

    _ticker?.cancel();
    _ticker = null;
    _runStartedAt = _sessionStartedAt = null;
    _totalBreakDuration = _accumulatedBeforeRun = Duration.zero;

    state = state.copyWith(
      isTimerRunning: false,
      isOnBreak: false,
      elapsed: Duration.zero,
      breakDuration: Duration.zero,
      clearActiveTimeLogId: true,
      clearSessionStartedAt: true,
      isActionLoading: false,
      logs: [newLog, ...state.logs],
    );

    return true;
  }

  Future<void> cancelTimer() async {
    final wasInGrace = state.isGracePeriod || state.graceSecondsRemaining > 0;
    final currentActiveId = state.activeTimeLogId;
    final phaseId = state.currentProject.effectivePhaseId;
    final activity = EmployeeTimerHelpers.mapActivity(state.currentActivity);
    final directPhase = state.currentProject.phaseId;

    _ticker?.cancel();
    _ticker = null;
    _runStartedAt = _sessionStartedAt = null;
    _totalBreakDuration = _accumulatedBeforeRun = Duration.zero;
    _isDispatchedStart = false;

    state = state.copyWith(
      isTimerRunning: false,
      isOnBreak: false,
      elapsed: Duration.zero,
      breakDuration: Duration.zero,
      graceSecondsRemaining: 0,
      clearActiveTimeLogId: true,
      clearSessionStartedAt: true,
      isActionLoading: false,
    );

    // Cancelled within 5 seconds: backend start was never called. Clean local cancel.
    if (wasInGrace) return;

    if (currentActiveId != null && currentActiveId.isNotEmpty) {
      await EmployeeTimerHelpers.stopActiveTimer(
        ref: ref,
        currentId: currentActiveId,
        phaseId: phaseId,
        activity: activity,
        directPhaseId: directPhase,
      );
    }
  }

  void toggleShowThisMonth() {
    state = state.copyWith(showThisMonth: !state.showThisMonth);
  }
}
