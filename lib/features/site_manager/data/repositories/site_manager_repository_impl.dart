import '../../domain/entities/site_manager_entities.dart';
import '../../domain/repositories/site_manager_repository.dart';
import '../../helper/site_manager_models.dart';
import '../../projects/enums.dart';
import '../datasources/site_manager_datasource.dart';

class SiteManagerRepositoryImpl implements SiteManagerRepository {
  final SiteManagerDataSource _dataSource;

  const SiteManagerRepositoryImpl(this._dataSource);

  @override
  Future<DashboardStats> getDashboardStats() {
    return _dataSource.getDashboardStats();
  }

  @override
  Future<List<SiteProject>> getProjects() {
    return _dataSource.getProjects();
  }

  @override
  Future<SiteProject?> getProjectById(String id) {
    return _dataSource.getProjectById(id);
  }

  @override
  Future<void> createProject(SiteProject project) {
    return _dataSource.createProject(project);
  }

  @override
  Future<void> updateProjectPhase(String id, ProjectPhase newPhase) {
    return _dataSource.updateProjectPhase(id, newPhase);
  }

  @override
  Future<List<SiteInspection>> getInspections() {
    return _dataSource.getInspections();
  }

  @override
  Future<List<TimeEntryModel>> getTimeEntries() {
    return _dataSource.getTimeEntries();
  }

  @override
  Future<List<CrewMemberModel>> getCrewMembers() {
    return _dataSource.getCrewMembers();
  }

  @override
  Future<void> addTimeEntry(TimeEntryModel entry) {
    return _dataSource.addTimeEntry(entry);
  }
}
