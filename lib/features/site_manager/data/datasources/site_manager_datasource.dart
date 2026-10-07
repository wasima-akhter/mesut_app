import '../../helper/site_manager_enums.dart';
import '../../helper/site_manager_models.dart';
import '../../domain/entities/site_manager_entities.dart';
import '../../projects/enums.dart';

abstract class SiteManagerDataSource {
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

class SiteManagerMockDataSourceImpl implements SiteManagerDataSource {
  final List<SiteProject> _projects = [
    const SiteProject(
      id: 'Prj-0842',
      name: 'Goldstein Complex',
      customer: 'Goldstein Immo GmbH',
      address: 'Goltsteinstraße 12',
      city: '50968 Köln',
      phase: ProjectPhase.erection,
      status: ProjectStatus.inProgress,
      priority: ProjectPriority.high,
      startDate: '12 Sep 2026',
      endDate: '28 Oct 2026',
      scaffoldArea: '1,450 m²',
      contactPerson: 'Herr Meyer',
      phone: '+49 221 987654',
      email: 'meyer@goldstein.de',
    ),
    const SiteProject(
      id: 'Prj-0843',
      name: 'Rheinauhafen Office',
      customer: 'Hafen Development AG',
      address: 'Agrippinawerft 22',
      city: '50678 Köln',
      phase: ProjectPhase.dismantling,
      status: ProjectStatus.inProgress,
      priority: ProjectPriority.medium,
      startDate: '01 Aug 2026',
      endDate: '15 Oct 2026',
      scaffoldArea: '850 m²',
      contactPerson: 'Frau Schmidt',
      phone: '+49 221 554433',
      email: 'schmidt@hafen-dev.de',
    ),
    const SiteProject(
      id: 'Prj-0844',
      name: 'Severin Residenz',
      customer: 'Severin Wohnbau',
      address: 'Severinstraße 44',
      city: '50678 Köln',
      phase: ProjectPhase.standingScaffold,
      status: ProjectStatus.inProgress,
      priority: ProjectPriority.low,
      startDate: '20 Jul 2026',
      endDate: '30 Nov 2026',
      scaffoldArea: '2,100 m²',
      contactPerson: 'Herr Becker',
      phone: '+49 221 112233',
      email: 'becker@severin.de',
    ),
    const SiteProject(
      id: 'Prj-0845',
      name: 'Ehrenfeld Lofts',
      customer: 'Urban Living KG',
      address: 'Venloer Str. 120',
      city: '50823 Köln',
      phase: ProjectPhase.erection,
      status: ProjectStatus.inProgress,
      priority: ProjectPriority.medium,
      startDate: '01 Nov 2026',
      endDate: '15 Dec 2026',
      scaffoldArea: '620 m²',
    ),
  ];

  final List<TimeEntryModel> _timeEntries = [
    TimeEntryModel(
      id: 'te-1',
      project: 'Goldstein Complex',
      activity: ActivityType.erection,
      date: DateTime.now(),
      startTime: '07:30',
      endTime: '16:00',
      breakTime: '00:45',
      employee: 'Alex Becker',
      isSynced: true,
    ),
    TimeEntryModel(
      id: 'te-2',
      project: 'Rheinauhafen Office',
      activity: ActivityType.dismantling,
      date: DateTime.now().subtract(const Duration(days: 1)),
      startTime: '08:00',
      endTime: '16:30',
      breakTime: '00:30',
      employee: 'Tim Müller',
      isSynced: true,
    ),
  ];

  final List<CrewMemberModel> _crewMembers = const [
    CrewMemberModel(
      name: 'Alex Becker',
      activity: ActivityType.erection,
      startTime: '07:30',
      endTime: '16:00',
      breakTime: '45m',
      totalHours: '7.75h',
      isSynced: true,
    ),
    CrewMemberModel(
      name: 'Lukas Weber',
      activity: ActivityType.erection,
      startTime: '07:30',
      endTime: '16:00',
      breakTime: '45m',
      totalHours: '7.75h',
      isSynced: true,
    ),
    CrewMemberModel(
      name: 'Stefan Klein',
      activity: ActivityType.dismantling,
      startTime: '08:00',
      endTime: '16:30',
      breakTime: '30m',
      totalHours: '8.0h',
      isSynced: true,
    ),
  ];

  @override
  Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const DashboardStats(
      activeSites: 8,
      completedProjects: 34,
      totalWorkHours: 38.5,
      erectionsPlanned: 14,
      erectionsRunning: 5,
      dismantlingsPlanned: 14,
      dismantlingsRunning: 5,
      inspectionsDue: 3,
    );
  }

  @override
  Future<List<SiteProject>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_projects);
  }

  @override
  Future<SiteProject?> getProjectById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _projects.firstWhere(
      (p) => p.id.toLowerCase() == id.toLowerCase() || p.name.toLowerCase() == id.toLowerCase(),
      orElse: () => _projects.first,
    );
  }

  @override
  Future<void> createProject(SiteProject project) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _projects.insert(0, project);
  }

  @override
  Future<void> updateProjectPhase(String id, ProjectPhase newPhase) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _projects.indexWhere((p) => p.id == id);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(phase: newPhase);
    }
  }

  @override
  Future<List<SiteInspection>> getInspections() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      SiteInspection(
        id: 'insp-1',
        projectId: 'Prj-0842',
        projectName: 'Goldstein Complex',
        scaffoldType: 'Front Scaffold (Façade)',
        inspectionDate: DateTime.now(),
        isPassed: true,
        inspectorName: 'Mesut Yilmaz',
        notes: 'All anchors, base plates, and safety netting fully compliant with DIN EN 12811.',
      ),
      SiteInspection(
        id: 'insp-2',
        projectId: 'Prj-0843',
        projectName: 'Rheinauhafen Office',
        scaffoldType: 'Side Scaffold',
        inspectionDate: DateTime.now().subtract(const Duration(days: 3)),
        isPassed: true,
        inspectorName: 'Mesut Yilmaz',
        notes: 'Guard rails inspected. Clearance valid for 4 weeks.',
      ),
    ];
  }

  @override
  Future<List<TimeEntryModel>> getTimeEntries() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_timeEntries);
  }

  @override
  Future<List<CrewMemberModel>> getCrewMembers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_crewMembers);
  }

  @override
  Future<void> addTimeEntry(TimeEntryModel entry) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _timeEntries.insert(0, entry);
  }
}
