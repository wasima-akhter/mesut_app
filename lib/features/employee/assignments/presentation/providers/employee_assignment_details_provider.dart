import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/helper/employee_models.dart';

class AssignmentTaskItem {
  final String id;
  final String title;
  final bool isCompleted;

  const AssignmentTaskItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  AssignmentTaskItem copyWith({bool? isCompleted}) {
    return AssignmentTaskItem(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class AssignmentDetailsState {
  final EmployeeAssignmentModel assignment;
  final List<AssignmentTaskItem> tasks;
  final bool isInstructionsExpanded;

  const AssignmentDetailsState({
    required this.assignment,
    required this.tasks,
    this.isInstructionsExpanded = true,
  });

  AssignmentDetailsState copyWith({
    EmployeeAssignmentModel? assignment,
    List<AssignmentTaskItem>? tasks,
    bool? isInstructionsExpanded,
  }) {
    return AssignmentDetailsState(
      assignment: assignment ?? this.assignment,
      tasks: tasks ?? this.tasks,
      isInstructionsExpanded:
          isInstructionsExpanded ?? this.isInstructionsExpanded,
    );
  }
}

class AssignmentDetailsNotifier extends Notifier<AssignmentDetailsState> {
  @override
  AssignmentDetailsState build() {
    return AssignmentDetailsState(
      assignment: fakeAssignments.first,
      tasks: const [
        AssignmentTaskItem(
          id: 'task-1',
          title: 'Assemble base jacks and ground frame',
          isCompleted: false,
        ),
        AssignmentTaskItem(
          id: 'task-2',
          title: 'Secure diagonal bracing on level 1',
          isCompleted: false,
        ),
        AssignmentTaskItem(
          id: 'task-3',
          title: 'Install safety netting and toe boards',
          isCompleted: false,
        ),
      ],
    );
  }

  void setAssignment(EmployeeAssignmentModel assignment) {
    state = state.copyWith(assignment: assignment);
  }

  void toggleTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks.map((task) {
        if (task.id == taskId) {
          return task.copyWith(isCompleted: !task.isCompleted);
        }
        return task;
      }).toList(),
    );
  }

  void toggleInstructions() {
    state = state.copyWith(
      isInstructionsExpanded: !state.isInstructionsExpanded,
    );
  }
}

final assignmentDetailsProvider =
    NotifierProvider<AssignmentDetailsNotifier, AssignmentDetailsState>(
      AssignmentDetailsNotifier.new,
    );
