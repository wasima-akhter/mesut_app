import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/employee_dashboard_datasource.dart';
import '../../domain/entities/employee_dashboard_entity.dart';

class EmployeeDashboardState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final EmployeeDashboardEntity dashboard;
  final int currentPage;
  final bool hasMore;

  const EmployeeDashboardState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.dashboard = const EmployeeDashboardEntity(),
    this.currentPage = 1,
    this.hasMore = false,
  });

  EmployeeDashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    EmployeeDashboardEntity? dashboard,
    int? currentPage,
    bool? hasMore,
  }) {
    return EmployeeDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      dashboard: dashboard ?? this.dashboard,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class EmployeeDashboardNotifier extends Notifier<EmployeeDashboardState> {
  EmployeeDashboardDatasource get _datasource =>
      ref.read(employeeDashboardDatasourceProvider);

  @override
  EmployeeDashboardState build() {
    Future.microtask(loadInitial);
    return const EmployeeDashboardState(isLoading: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dashboard = await _datasource.getDashboard(page: 1, limit: 10);
      state = state.copyWith(
        isLoading: false,
        dashboard: dashboard,
        currentPage: 1,
        hasMore: dashboard.upcomingTasks.length >= 10,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    try {
      final dashboard = await _datasource.getDashboard(page: 1, limit: 10);
      state = state.copyWith(
        isRefreshing: false,
        dashboard: dashboard,
        currentPage: 1,
        hasMore: dashboard.upcomingTasks.length >= 10,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(isRefreshing: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final more = await _datasource.getDashboard(page: nextPage, limit: 10);
      final combined = [
        ...state.dashboard.upcomingTasks,
        ...more.upcomingTasks,
      ];
      final updatedDashboard = EmployeeDashboardEntity(
        user: more.user.id.isNotEmpty ? more.user : state.dashboard.user,
        date: more.date ?? state.dashboard.date,
        formattedDate: more.formattedDate.isNotEmpty
            ? more.formattedDate
            : state.dashboard.formattedDate,
        totalUpcomingTasks: more.totalUpcomingTasks > 0
            ? more.totalUpcomingTasks
            : combined.length,
        upcomingTasks: combined,
      );
      state = state.copyWith(
        isLoadingMore: false,
        dashboard: updatedDashboard,
        currentPage: nextPage,
        hasMore: more.upcomingTasks.length >= 10,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final employeeDashboardProvider =
    NotifierProvider<EmployeeDashboardNotifier, EmployeeDashboardState>(
  EmployeeDashboardNotifier.new,
);
