import '../entities/site_manager_entities.dart';
import '../../helper/site_manager_models.dart';
import '../../projects/enums.dart';

abstract class SiteManagerRepository {
  Future<DashboardStats> getDashboardStats();

  Future<List<SiteProject>> getProjects();

  Future<SiteProject?> getProjectById(String id);

  Future<void> createProject(SiteProject project);

  Future<void> updateProjectPhase(String id, ProjectPhase newPhase);

  Future<List<SiteInspection>> getInspections();

  Future<List<TimeEntryModel>> getTimeEntries();

  Future<List<CrewMemberModel>> getCrewMembers();

  Future<void> addTimeEntry(TimeEntryModel entry);
}
