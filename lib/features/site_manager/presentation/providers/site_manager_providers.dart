import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/site_manager_datasource.dart';
import '../../data/repositories/site_manager_repository_impl.dart';
import '../../domain/entities/site_manager_entities.dart';
import '../../domain/repositories/site_manager_repository.dart';
import '../../helper/site_manager_models.dart';
import '../../projects/enums.dart';

// DI Providers
final siteManagerDataSourceProvider = Provider<SiteManagerDataSource>((ref) {
  return SiteManagerMockDataSourceImpl();
});

final siteManagerRepositoryProvider = Provider<SiteManagerRepository>((ref) {
  final dataSource = ref.watch(siteManagerDataSourceProvider);
  return SiteManagerRepositoryImpl(dataSource);
});

// Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  return ref.watch(siteManagerRepositoryProvider).getDashboardStats();
});

// Projects Notifier
class SiteProjectsNotifier extends AsyncNotifier<List<SiteProject>> {
  @override
  Future<List<SiteProject>> build() {
    return ref.watch(siteManagerRepositoryProvider).getProjects();
  }

  Future<void> addProject(SiteProject project) async {
    await ref.read(siteManagerRepositoryProvider).createProject(project);
    state = await AsyncValue.guard(() => ref.read(siteManagerRepositoryProvider).getProjects());
  }

  Future<void> moveProjectPhase(String id, ProjectPhase newPhase) async {
    await ref.read(siteManagerRepositoryProvider).updateProjectPhase(id, newPhase);
    state = await AsyncValue.guard(() => ref.read(siteManagerRepositoryProvider).getProjects());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(siteManagerRepositoryProvider).getProjects());
  }
}

final siteProjectsProvider =
    AsyncNotifierProvider<SiteProjectsNotifier, List<SiteProject>>(
  SiteProjectsNotifier.new,
);

// Single Project Details Family Provider
final projectDetailProvider =
    FutureProvider.family<SiteProject?, String>((ref, id) {
  return ref.watch(siteManagerRepositoryProvider).getProjectById(id);
});

// Inspections Provider
final siteInspectionsProvider = FutureProvider<List<SiteInspection>>((ref) {
  return ref.watch(siteManagerRepositoryProvider).getInspections();
});

// Time Entries Notifier
class SiteTimeEntriesNotifier extends AsyncNotifier<List<TimeEntryModel>> {
  @override
  Future<List<TimeEntryModel>> build() {
    return ref.watch(siteManagerRepositoryProvider).getTimeEntries();
  }

  Future<void> addEntry(TimeEntryModel entry) async {
    await ref.read(siteManagerRepositoryProvider).addTimeEntry(entry);
    state = await AsyncValue.guard(() => ref.read(siteManagerRepositoryProvider).getTimeEntries());
  }
}

final siteTimeEntriesProvider =
    AsyncNotifierProvider<SiteTimeEntriesNotifier, List<TimeEntryModel>>(
  SiteTimeEntriesNotifier.new,
);

// Crew Members Provider
final siteCrewMembersProvider = FutureProvider<List<CrewMemberModel>>((ref) {
  return ref.watch(siteManagerRepositoryProvider).getCrewMembers();
});
