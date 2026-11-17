import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/project_tasks_repository_impl.dart';
import '../../domain/entities/project_task_entity.dart';

final projectTaskEmployeesProvider = FutureProvider.autoDispose
    .family<List<ProjectTaskEmployeeEntity>, String>((ref, projectId) async {
  if (projectId.trim().isEmpty) return const [];
  final repo = ref.watch(projectTasksRepositoryProvider);
  return repo.getProjectEmployees(projectId: projectId);
});
