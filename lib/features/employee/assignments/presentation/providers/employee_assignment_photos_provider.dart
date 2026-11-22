import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/employee_project_details_entity.dart';
import 'employee_project_details_di.dart';

class EmployeeAssignmentPhotosState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<EmployeeProjectPhotoEntity> photos;
  final int page;
  final bool hasMore;
  final String? projectId;

  const EmployeeAssignmentPhotosState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.photos = const [],
    this.page = 1,
    this.hasMore = true,
    this.projectId,
  });

  EmployeeAssignmentPhotosState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    List<EmployeeProjectPhotoEntity>? photos,
    int? page,
    bool? hasMore,
    String? projectId,
  }) {
    return EmployeeAssignmentPhotosState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      photos: photos ?? this.photos,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      projectId: projectId ?? this.projectId,
    );
  }
}

class EmployeeAssignmentPhotosNotifier
    extends Notifier<EmployeeAssignmentPhotosState> {
  @override
  EmployeeAssignmentPhotosState build() {
    return const EmployeeAssignmentPhotosState();
  }

  Future<void> loadInitial(String projectId) async {
    state = state.copyWith(
      isLoading: true,
      projectId: projectId,
      page: 1,
      hasMore: true,
      clearError: true,
    );

    try {
      final repo = ref.read(employeeProjectDetailsRepositoryProvider);
      final items = await repo.getProjectPhotos(projectId, page: 1, limit: 12);
      state = state.copyWith(
        isLoading: false,
        photos: items,
        page: 1,
        hasMore: items.length >= 12,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final pid = state.projectId;
    if (pid == null || pid.isEmpty) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(employeeProjectDetailsRepositoryProvider);
      final items = await repo.getProjectPhotos(
        pid,
        page: nextPage,
        limit: 12,
      );
      state = state.copyWith(
        isLoadingMore: false,
        photos: [...state.photos, ...items],
        page: nextPage,
        hasMore: items.length >= 12,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    final pid = state.projectId;
    if (pid != null && pid.isNotEmpty) {
      await loadInitial(pid);
    }
  }
}

final employeeAssignmentPhotosProvider = NotifierProvider<
  EmployeeAssignmentPhotosNotifier,
  EmployeeAssignmentPhotosState
>(EmployeeAssignmentPhotosNotifier.new);
