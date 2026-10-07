import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helper/employee_enums.dart';
import '../../data/datasources/employee_datasource.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../domain/entities/employee_entities.dart';
import '../../domain/repositories/employee_repository.dart';

// DI
final employeeDataSourceProvider = Provider<EmployeeDataSource>((ref) {
  return EmployeeMockDataSourceImpl();
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final dataSource = ref.watch(employeeDataSourceProvider);
  return EmployeeRepositoryImpl(dataSource);
});

// Assignments Notifier
class EmployeeAssignmentsNotifier extends AsyncNotifier<List<EmployeeAssignment>> {
  @override
  Future<List<EmployeeAssignment>> build() {
    return ref.watch(employeeRepositoryProvider).getAssignments();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(employeeRepositoryProvider).getAssignments());
  }
}

final employeeAssignmentsProvider =
    AsyncNotifierProvider<EmployeeAssignmentsNotifier, List<EmployeeAssignment>>(
  EmployeeAssignmentsNotifier.new,
);

// Schedule Notifier
class EmployeeScheduleNotifier extends AsyncNotifier<List<EmployeeCalendarEvent>> {
  @override
  Future<List<EmployeeCalendarEvent>> build() {
    return ref.watch(employeeRepositoryProvider).getScheduleEvents();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(employeeRepositoryProvider).getScheduleEvents());
  }
}

final employeeScheduleProvider =
    AsyncNotifierProvider<EmployeeScheduleNotifier, List<EmployeeCalendarEvent>>(
  EmployeeScheduleNotifier.new,
);

// Time Logs Notifier
class EmployeeTimeLogsNotifier extends AsyncNotifier<List<EmployeeTimeLog>> {
  @override
  Future<List<EmployeeTimeLog>> build() {
    return ref.watch(employeeRepositoryProvider).getTimeLogs();
  }

  Future<void> addTimeEntry({
    required String projectId,
    required String startTime,
    required String endTime,
    required String breakTime,
  }) async {
    await ref.read(employeeRepositoryProvider).saveTimeEntry(
      projectId: projectId,
      startTime: startTime,
      endTime: endTime,
      breakTime: breakTime,
    );
    state = await AsyncValue.guard(() => ref.read(employeeRepositoryProvider).getTimeLogs());
  }
}

final employeeTimeLogsProvider =
    AsyncNotifierProvider<EmployeeTimeLogsNotifier, List<EmployeeTimeLog>>(
  EmployeeTimeLogsNotifier.new,
);

// Active Timer State & Notifier
class EmployeeTimerState {
  final bool isRunning;
  final bool isPaused;
  final int elapsedSeconds;
  final EmployeeActivityType currentActivity;
  final String? projectName;

  const EmployeeTimerState({
    this.isRunning = false,
    this.isPaused = false,
    this.elapsedSeconds = 0,
    this.currentActivity = EmployeeActivityType.erection,
    this.projectName,
  });

  String get formattedTime {
    final hours = (elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  EmployeeTimerState copyWith({
    bool? isRunning,
    bool? isPaused,
    int? elapsedSeconds,
    EmployeeActivityType? currentActivity,
    String? projectName,
  }) {
    return EmployeeTimerState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentActivity: currentActivity ?? this.currentActivity,
      projectName: projectName ?? this.projectName,
    );
  }
}

class EmployeeTimerNotifier extends Notifier<EmployeeTimerState> {
  Timer? _timer;

  @override
  EmployeeTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const EmployeeTimerState();
  }

  void startTimer({
    required EmployeeActivityType activity,
    required String projectName,
  }) {
    _timer?.cancel();
    state = EmployeeTimerState(
      isRunning: true,
      isPaused: false,
      elapsedSeconds: 0,
      currentActivity: activity,
      projectName: projectName,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused && state.isRunning) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void pauseTimer() {
    if (state.isRunning) {
      state = state.copyWith(isPaused: true);
    }
  }

  void resumeTimer() {
    if (state.isRunning) {
      state = state.copyWith(isPaused: false);
    }
  }

  void stopTimer() {
    _timer?.cancel();
    state = const EmployeeTimerState();
  }
}

final employeeTimerProvider =
    NotifierProvider<EmployeeTimerNotifier, EmployeeTimerState>(
  EmployeeTimerNotifier.new,
);
