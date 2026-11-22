import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/helper/employee_models.dart';
import 'employee_assignment_details_state.dart';
import 'employee_project_details_di.dart';

class AssignmentDetailsNotifier
    extends Notifier<EmployeeAssignmentDetailsState> {
  @override
  EmployeeAssignmentDetailsState build() {
    return const EmployeeAssignmentDetailsState();
  }

  void setAssignment(EmployeeAssignmentModel assignment) {
    state = state.copyWith(
      fallbackAssignment: assignment,
      currentProjectId: assignment.projectId,
    );
    final pid = assignment.projectId;
    if (pid != null && pid.isNotEmpty) {
      loadProject(pid);
    }
  }

  Future<void> loadProject(String projectId, {bool isRefresh = false}) async {
    if (projectId.isEmpty) return;

    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, clearError: true);
    } else {
      state = state.copyWith(
        isLoading: state.project == null,
        currentProjectId: projectId,
        clearError: true,
      );
    }

    try {
      final repo = ref.read(employeeProjectDetailsRepositoryProvider);
      final project = await repo.getProjectDetail(projectId);
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        project: project,
        tasks: project.tasks,
        currentProjectId: projectId,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    final pid = state.currentProjectId;
    if (pid != null && pid.isNotEmpty) {
      await loadProject(pid, isRefresh: true);
    }
  }

  Future<void> toggleTask(String taskId) async {
    final previousTasks = state.tasks;
    final updatedTasks = previousTasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(isCompleted: !t.isCompleted);
      }
      return t;
    }).toList();

    state = state.copyWith(tasks: updatedTasks);

    try {
      final repo = ref.read(employeeProjectDetailsRepositoryProvider);
      final success = await repo.toggleTask(taskId);
      if (!success) {
        state = state.copyWith(tasks: previousTasks);
      }
    } catch (_) {
      state = state.copyWith(tasks: previousTasks);
    }
  }

  void toggleInstructions() {
    state = state.copyWith(
      isInstructionsExpanded: !state.isInstructionsExpanded,
    );
  }
}

final assignmentDetailsProvider =
    NotifierProvider<AssignmentDetailsNotifier, EmployeeAssignmentDetailsState>(
      AssignmentDetailsNotifier.new,
    );
