import '../../../shared/helper/employee_models.dart';
import '../../domain/entities/employee_project_details_entity.dart';

class EmployeeAssignmentDetailsState {
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final EmployeeProjectDetailsEntity? project;
  final List<EmployeeProjectTaskEntity> tasks;
  final bool isInstructionsExpanded;
  final String? currentProjectId;
  final EmployeeAssignmentModel? fallbackAssignment;

  const EmployeeAssignmentDetailsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.project,
    this.tasks = const [],
    this.isInstructionsExpanded = true,
    this.currentProjectId,
    this.fallbackAssignment,
  });

  bool get hasData => project != null || fallbackAssignment != null;

  bool get hasPendingTranslation {
    if (project?.localization?.isPending == true) return true;
    return tasks.any((t) => t.localization?.isPending == true);
  }

  EmployeeAssignmentDetailsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    EmployeeProjectDetailsEntity? project,
    List<EmployeeProjectTaskEntity>? tasks,
    bool? isInstructionsExpanded,
    String? currentProjectId,
    EmployeeAssignmentModel? fallbackAssignment,
  }) {
    return EmployeeAssignmentDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      project: project ?? this.project,
      tasks: tasks ?? this.tasks,
      isInstructionsExpanded:
          isInstructionsExpanded ?? this.isInstructionsExpanded,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      fallbackAssignment: fallbackAssignment ?? this.fallbackAssignment,
    );
  }
}
