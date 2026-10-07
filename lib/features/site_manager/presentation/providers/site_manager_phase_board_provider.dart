import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../phase_board/site_manager_phase_board.dart';

class PhaseBoardState {
  final ProjectPhase selectedPhase;
  final List<ProjectBoardModel> projects;

  const PhaseBoardState({
    this.selectedPhase = ProjectPhase.erection,
    this.projects = const [
      ProjectBoardModel(
        id: 'PRJ-0842',
        title: 'Goldsteins.Complex',
        company: 'HochTief AG',
        type: 'Commercial',
        address: 'Goldsteinstraße 12, 50968 Köln',
        assignee: 'Mesut Yilmaz',
        priority: 'High',
        days: '2.5 days',
      ),
      ProjectBoardModel(
        id: 'PRJ-0842',
        title: 'Goldsteins.Complex',
        company: 'HochTief AG',
        type: 'Commercial',
        address: 'Goldsteinstraße 12, 50968 Köln',
        assignee: 'Mesut Yilmaz',
        priority: 'Medium',
        days: '2.5 days',
      ),
      ProjectBoardModel(
        id: 'PRJ-0842',
        title: 'Goldsteins.Complex',
        company: 'HochTief AG',
        type: 'Commercial',
        address: 'Goldsteinstraße 12, 50968 Köln',
        assignee: 'Mesut Yilmaz',
        priority: 'Low',
        days: '2.5 days',
      ),
      ProjectBoardModel(
        id: 'PRJ-0843',
        title: 'Goldsteins.Complex',
        company: 'HochTief AG',
        type: 'Commercial',
        address: 'Goldsteinstraße 12, 50968 Köln',
        assignee: 'Mesut Yilmaz',
        priority: 'Low',
        days: '2.5 days',
      ),
      ProjectBoardModel(
        id: 'PRJ-0844',
        title: 'Goldsteins.Complex',
        company: 'HochTief AG',
        type: 'Commercial',
        address: 'Goldsteinstraße 12, 50968 Köln',
        assignee: 'Mesut Yilmaz',
        priority: 'Low',
        days: '2.5 days',
      ),
    ],
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

  void setPhase(ProjectPhase phase) {
    state = state.copyWith(selectedPhase: phase);
  }

  void removeProject(String id) {
    state = state.copyWith(
      projects: state.projects.where((p) => p.id != id).toList(),
    );
  }
}

final phaseBoardProvider =
    NotifierProvider<PhaseBoardNotifier, PhaseBoardState>(
  PhaseBoardNotifier.new,
);
