import 'package:flutter/material.dart';

import '../../../../../core/localization/app_strings.dart';
import '../../domain/entities/project_phase_card_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import 'project_search_results_view.dart';

class ProjectSearchDelegate extends SearchDelegate<ProjectPhaseCardEntity?> {
  final ProjectsRepository repository;
  final List<ProjectPhaseCardEntity> initialProjects;
  final void Function(ProjectPhaseCardEntity project)? onProjectSelected;

  ProjectSearchDelegate({
    required this.repository,
    required this.initialProjects,
    this.onProjectSelected,
  });

  @override
  String? get searchFieldLabel => AppStrings.current.searchProjectsHint;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ProjectSearchResultsView(
      query: query,
      repository: repository,
      initialProjects: initialProjects,
      onProjectSelected: (project) {
        close(context, project);
        onProjectSelected?.call(project);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
