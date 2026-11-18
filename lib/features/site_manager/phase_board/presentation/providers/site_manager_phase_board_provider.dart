import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/enums.dart';

class ProjectBoardModel {
  final String id;
  final String title;
  final String company;
  final String type;
  final String address;
  final String assignee;
  final String priority;
  final String days;

  const ProjectBoardModel({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.address,
    required this.assignee,
    required this.priority,
    required this.days,
  });
}

class PhaseBoardState {
  final ProjectPhase selectedPhase;
  final List<ProjectBoardModel> projects;

  const PhaseBoardState({
    this.selectedPhase = ProjectPhase.erection,
    this.projects = const [],
  });

  PhaseBoardState copyWith({
    ProjectPhase? selectedPhase,
    List<ProjectBoardModel>? projects,
  }) {
    return PhaseBoardState(
      selectedPhase: selectedPhase ?? this.selectedPhase,
      projects: projects ?? this.projects,
    );
  }
}

class PhaseBoardNotifier extends Notifier<PhaseBoardState> {
  @override
  PhaseBoardState build() {
    return const PhaseBoardState();
  }

  void selectPhase(ProjectPhase phase) {
    state = state.copyWith(selectedPhase: phase);
  }

  void moveProject(String id, ProjectPhase newPhase) {
    // Legacy mock handler preserved for compatibility
  }
}

final phaseBoardProvider =
    NotifierProvider<PhaseBoardNotifier, PhaseBoardState>(
      PhaseBoardNotifier.new,
    );
