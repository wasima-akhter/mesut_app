import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_app/core/enums/app_enum.dart';
import 'package:construction_app/core/network/network_providers.dart';
import 'package:construction_app/core/providers/common_provider.dart';
import 'package:construction_app/core/storage/storage_provider.dart';
import '../../../offline_sync/providers/employee_sync_provider.dart';
import '../../data/datasources/employee_schedule_datasource.dart';
import '../../domain/entities/employee_schedule_entity.dart';

final employeeScheduleDataSourceProvider =
    Provider<EmployeeScheduleRemoteDataSource>((ref) {
  return EmployeeScheduleRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
    cacheService: ref.watch(employeeCacheServiceProvider),
  );
});

class EmployeeScheduleState {
  const EmployeeScheduleState({
    required this.focusedDay,
    required this.selectedDay,
    this.days = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.page = 1,
    this.hasMore = false,
    this.errorMessage,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<EmployeeScheduleDayEntity> days;
  final bool isLoading;
  final bool isLoadingMore;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  EmployeeScheduleState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    List<EmployeeScheduleDayEntity>? days,
    bool? isLoading,
    bool? isLoadingMore,
    int? page,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmployeeScheduleState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      days: days ?? this.days,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  EmployeeScheduleDayEntity? get selectedDayData {
    final key = _dateKey(selectedDay);
    for (final d in days) {
      if (d.date.length >= 10 && d.date.substring(0, 10) == key) {
        return d;
      }
    }
    return null;
  }

  List<EmployeeSchedulePhaseEntity> get selectedPhases =>
      selectedDayData?.phases ?? const [];
}

class EmployeeScheduleNotifier extends Notifier<EmployeeScheduleState> {
  DateTime _rangeStart = _startOfDay(DateTime.now()).subtract(const Duration(days: 14));
  DateTime _rangeEnd = _startOfDay(DateTime.now()).add(const Duration(days: 35));

  static DateTime _startOfDay(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

  @override
  EmployeeScheduleState build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _updateRangeForFocusedDay(today);

    Future.microtask(() => loadSchedule());

    return EmployeeScheduleState(
      focusedDay: today,
      selectedDay: today,
      isLoading: true,
    );
  }

  void _updateRangeForFocusedDay(DateTime focused) {
    final firstDay = DateTime.utc(focused.year, focused.month, 1);
    final lastDay = DateTime.utc(focused.year, focused.month + 1, 0, 23, 59, 59);
    _rangeStart = firstDay.subtract(const Duration(days: 14));
    _rangeEnd = lastDay.add(const Duration(days: 14));
  }

  Future<void> loadSchedule() async {
    final hasToken = await ref.read(storageServiceProvider).hasValidAccessToken();
    final role = ref.read(userRoleProvider);
    if (!hasToken || role != UserRole.employee) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final days = await ref.read(employeeScheduleDataSourceProvider).getSchedule(
            startDate: _rangeStart,
            endDate: _rangeEnd,
            page: 1,
            limit: 50,
          );
      state = state.copyWith(
        days: days,
        isLoading: false,
        page: 1,
        hasMore: days.length >= 50,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load schedule. Please try again.',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final moreDays =
          await ref.read(employeeScheduleDataSourceProvider).getSchedule(
                startDate: _rangeStart,
                endDate: _rangeEnd,
                page: nextPage,
                limit: 50,
              );
      state = state.copyWith(
        days: [...state.days, ...moreDays],
        page: nextPage,
        hasMore: moreDays.length >= 50,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void selectDay(DateTime selected, DateTime focused) {
    final needReload = focused.month != state.focusedDay.month ||
        focused.year != state.focusedDay.year;
    state = state.copyWith(selectedDay: selected, focusedDay: focused);
    if (needReload) {
      _updateRangeForFocusedDay(focused);
      loadSchedule();
    }
  }

  void updateFocusedDay(DateTime focused) {
    final needReload = focused.month != state.focusedDay.month ||
        focused.year != state.focusedDay.year;
    state = state.copyWith(focusedDay: focused);
    if (needReload) {
      _updateRangeForFocusedDay(focused);
      loadSchedule();
    }
  }

  Future<void> refresh() async {
    await loadSchedule();
  }
}

final employeeScheduleProvider =
    NotifierProvider<EmployeeScheduleNotifier, EmployeeScheduleState>(
  EmployeeScheduleNotifier.new,
);

