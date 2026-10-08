import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helper/employee_enums.dart';
import '../../helper/employee_models.dart';

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

  @override
  EmployeeTimerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
    });

    const defaultProject = EmployeeProjectModel(
      id: 'Prj-0842',
      name: 'Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.erection,
      startTime: '07:30 am',
      endTime: '04:15 pm',
      startTimeOfDay: TimeOfDay(hour: 7, minute: 30),
      endTimeOfDay: TimeOfDay(hour: 16, minute: 15),
      siteManager: 'Mesut Rahaman',
    );

    final now = DateTime.now();

    return EmployeeTimerState(
      isTimerRunning: false,
      isOnBreak: false,
      showThisMonth: false,
      elapsed: const Duration(hours: 2, minutes: 45, seconds: 20),
      currentProject: defaultProject,
      currentActivity: EmployeeActivityType.erection,
      logs: [
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
          timestamp: now.toUtc(),
          project: const EmployeeProjectModel(
            id: 'Prj-0842',
            name: 'Goltsteins.Complex',
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
      ],
    );
  }

  void startTimer({
    EmployeeProjectModel? project,
    EmployeeActivityType? activity,
  }) {
    _ticker?.cancel();

    state = state.copyWith(
      isTimerRunning: true,
      isOnBreak: false,
      currentProject: project ?? state.currentProject,
      currentActivity: activity ?? state.currentActivity,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isTimerRunning || state.isOnBreak) return;
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  void pauseTimer() {
    state = state.copyWith(isOnBreak: true);
  }

  void resumeTimer() {
    state = state.copyWith(isOnBreak: false);
  }

  void toggleBreak() {
    state = state.copyWith(isOnBreak: !state.isOnBreak);
  }

  void finishTimer() {
    _ticker?.cancel();
    state = state.copyWith(
      isTimerRunning: false,
      isOnBreak: false,
      elapsed: Duration.zero,
    );
  }

  void toggleShowThisMonth() {
    state = state.copyWith(showThisMonth: !state.showThisMonth);
  }
}
