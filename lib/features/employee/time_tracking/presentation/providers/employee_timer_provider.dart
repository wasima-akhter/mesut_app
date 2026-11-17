import 'dart:async';

import 'package:construction_app/core/enums/backend_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';
import 'offline_sync_provider.dart';

class EmployeeTimerState {
  final bool isTimerRunning;
  final bool isOnBreak;
  final bool showThisMonth;
  final Duration elapsed;
  final EmployeeProjectModel currentProject;
  final EmployeeActivityType currentActivity;
  final List<EmployeeTimeLogModel> logs;

  const EmployeeTimerState({
    required this.isTimerRunning,
    required this.isOnBreak,
    required this.showThisMonth,
    required this.elapsed,
    required this.currentProject,
    required this.currentActivity,
    required this.logs,
  });

  EmployeeTimerState copyWith({
    bool? isTimerRunning,
    bool? isOnBreak,
    bool? showThisMonth,
    Duration? elapsed,
    EmployeeProjectModel? currentProject,
    EmployeeActivityType? currentActivity,
    List<EmployeeTimeLogModel>? logs,
  }) {
    return EmployeeTimerState(
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      showThisMonth: showThisMonth ?? this.showThisMonth,
      elapsed: elapsed ?? this.elapsed,
      currentProject: currentProject ?? this.currentProject,
      currentActivity: currentActivity ?? this.currentActivity,
      logs: logs ?? this.logs,
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
}

final employeeTimerProvider =
    NotifierProvider<EmployeeTimerNotifier, EmployeeTimerState>(
      EmployeeTimerNotifier.new,
    );

class EmployeeTimerNotifier extends Notifier<EmployeeTimerState> {
  Timer? _ticker;
  Duration _accumulatedBeforeRun = const Duration(
    hours: 2,
    minutes: 45,
    seconds: 20,
  );
  DateTime? _runStartedAt;
  DateTime? _sessionStartedAt;
  DateTime? _breakStartedAt;
  Duration _totalBreakDuration = Duration.zero;

  @override
  EmployeeTimerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _ticker = null;
    });

    const defaultProject = EmployeeProjectModel(
      id: 'PRJ-0842',
      name: 'Goltstein.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.erection,
      startTime: '07:30 am',
      endTime: '04:15 pm',
      startTimeOfDay: TimeOfDay(hour: 7, minute: 30),
      endTimeOfDay: TimeOfDay(hour: 16, minute: 15),
      siteManager: 'Mesut Rahaman',
    );

    final now = DateTime.now();
    final defaultLogs = [
      EmployeeTimeLogModel(
        timestamp: now.toUtc(),
        project: defaultProject,
        duration: '8.0',
        durationHours: 8.0,
        breakTime: '45m',
        breakDuration: const Duration(minutes: 45),
        synced: true,
      ),
      EmployeeTimeLogModel(
        timestamp: now.subtract(const Duration(days: 1)).toUtc(),
        project: const EmployeeProjectModel(
          id: 'PRJ-0842',
          name: 'Goltstein.Complex',
          address: 'Goltsteinstraße 12, 50968 Köln',
          activity: EmployeeActivityType.dismantling,
          startTime: '07:30 am',
          endTime: '04:15 pm',
          startTimeOfDay: TimeOfDay(hour: 7, minute: 30),
          endTimeOfDay: TimeOfDay(hour: 16, minute: 15),
          siteManager: 'Mesut Rahaman',
        ),
        duration: '8.0',
        durationHours: 8.0,
        breakTime: '45m',
        breakDuration: const Duration(minutes: 45),
        synced: true,
      ),
    ];

    return EmployeeTimerState(
      isTimerRunning: false,
      isOnBreak: false,
      showThisMonth: false,
      elapsed: _accumulatedBeforeRun,
      currentProject: defaultProject,
      currentActivity: EmployeeActivityType.erection,
      logs: defaultLogs,
    );
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
      state = state.copyWith(elapsed: currentElapsed);
    });
  }

  void startTimer({
    EmployeeProjectModel? project,
    EmployeeActivityType? activity,
  }) {
    _accumulatedBeforeRun = state.elapsed;
    _sessionStartedAt ??= DateTime.now().toUtc();
    _totalBreakDuration = Duration.zero;
    _breakStartedAt = null;
    state = state.copyWith(
      isTimerRunning: true,
      isOnBreak: false,
      currentProject: project ?? state.currentProject,
      currentActivity: activity ?? state.currentActivity,
    );
    _startTicker();
  }

  void pauseTimer() {
    if (_runStartedAt != null) {
      _accumulatedBeforeRun += DateTime.now().difference(_runStartedAt!);
      _runStartedAt = null;
    }
    _breakStartedAt = DateTime.now().toUtc();
    _ticker?.cancel();
    _ticker = null;
    state = state.copyWith(isOnBreak: true, elapsed: _accumulatedBeforeRun);
  }

  void resumeTimer() {
    if (!state.isTimerRunning) return;
    if (_breakStartedAt != null) {
      _totalBreakDuration += DateTime.now().toUtc().difference(
        _breakStartedAt!,
      );
      _breakStartedAt = null;
    }
    state = state.copyWith(isOnBreak: false);
    _startTicker();
  }

  void toggleBreak() {
    if (state.isOnBreak) {
      resumeTimer();
    } else {
      pauseTimer();
    }
  }

  void finishTimer() {
    final endTime = DateTime.now().toUtc();
    if (_breakStartedAt != null) {
      _totalBreakDuration += endTime.difference(_breakStartedAt!);
      _breakStartedAt = null;
    }

    final startTime = _sessionStartedAt;
    final phaseId = state.currentProject.id;
    final projectName = state.currentProject.fullName;
    final activity = _mapActivity(state.currentActivity);
    final breakMinutes = _totalBreakDuration.inMinutes;

    final elapsedMinutes = state.elapsed.inMinutes;
    final durationHours = double.parse(
      (elapsedMinutes / 60).toStringAsFixed(1),
    );
    final newLog = EmployeeTimeLogModel(
      timestamp: endTime,
      project: state.currentProject,
      duration: durationHours > 0 ? durationHours.toString() : '0.1',
      durationHours: durationHours > 0 ? durationHours : 0.1,
      breakTime: '${_totalBreakDuration.inMinutes}m',
      breakDuration: _totalBreakDuration,
      synced: false,
    );

    _ticker?.cancel();
    _ticker = null;
    _runStartedAt = null;
    _sessionStartedAt = null;
    _totalBreakDuration = Duration.zero;
    _accumulatedBeforeRun = Duration.zero;

    state = state.copyWith(
      isTimerRunning: false,
      isOnBreak: false,
      elapsed: Duration.zero,
      logs: [newLog, ...state.logs],
    );

    if (startTime != null) {
      try {
        unawaited(
          ref
              .read(offlineSyncProvider.notifier)
              .enqueueCompletedSegment(
                phaseId: phaseId,
                activityType: activity,
                startTime: startTime,
                endTime: endTime,
                breakMinutes: breakMinutes,
                projectName: projectName,
              ),
        );
      } catch (_) {
        // Ignore in unit test environments where SharedPreferences is not overridden.
      }
    }
  }

  static BackendActivityType _mapActivity(EmployeeActivityType activity) {
    switch (activity) {
      case EmployeeActivityType.erection:
        return BackendActivityType.erection;
      case EmployeeActivityType.dismantling:
        return BackendActivityType.dismantling;
      case EmployeeActivityType.others:
        return BackendActivityType.other;
    }
  }

  void toggleShowThisMonth() {
    state = state.copyWith(showThisMonth: !state.showThisMonth);
  }
}
