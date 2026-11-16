import '../../domain/entities/project_measurement_entity.dart';

class ProjectMeasurementsState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isMutating;
  final String? errorMessage;
  final List<ProjectMeasurementEntity> items;
  final double totalArea;
  final int page;
  final bool hasMore;
  final String projectId;

  const ProjectMeasurementsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMutating = false,
    this.errorMessage,
    this.items = const [],
    this.totalArea = 0.0,
    this.page = 1,
    this.hasMore = true,
    this.projectId = '',
  });

  bool get isEmpty => !isLoading && items.isEmpty;

  double get displayTotalArea {
    if (totalArea > 0) return totalArea;
    return items.fold<double>(0.0, (sum, item) => sum + item.calculatedArea);
  }

  ProjectMeasurementsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
    List<ProjectMeasurementEntity>? items,
    double? totalArea,
    int? page,
    bool? hasMore,
    String? projectId,
  }) {
    return ProjectMeasurementsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      totalArea: totalArea ?? this.totalArea,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      projectId: projectId ?? this.projectId,
    );
  }
}
