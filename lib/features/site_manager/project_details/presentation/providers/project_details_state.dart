import '../../../../../core/widgets/states/app_data_state.dart';
import '../../../projects/enums.dart';
import '../../domain/entities/project_details_entity.dart';

class ProjectDetailsState {
  final String projectId;
  final AppDataStatus overviewStatus;
  final ProjectDetailsTab selectedTab;
  final ProjectDetailsEntity? details;
  final String? errorMessage;
  final Object? errorObject;

  const ProjectDetailsState({
    this.projectId = '',
    this.overviewStatus = AppDataStatus.initial,
    this.selectedTab = ProjectDetailsTab.overview,
    this.details,
    this.errorMessage,
    this.errorObject,
  });

  AppDataStatus get status => overviewStatus;
  bool get isEmpty => details == null;
  bool get isLoading => overviewStatus == AppDataStatus.loading;
  bool get isRefreshing => overviewStatus == AppDataStatus.refreshing;
  bool get isSuccess => overviewStatus == AppDataStatus.success;
  bool get hasError => overviewStatus == AppDataStatus.error;

  bool hasDetailsFor(String id) => details != null && details!.id == id;

  ProjectDetailsState copyWith({
    String? projectId,
    AppDataStatus? overviewStatus,
    AppDataStatus? status,
    ProjectDetailsTab? selectedTab,
    ProjectDetailsEntity? details,
    String? errorMessage,
    Object? errorObject,
    bool clearError = false,
    bool clearDetails = false,
  }) {
    return ProjectDetailsState(
      projectId: projectId ?? this.projectId,
      overviewStatus: overviewStatus ?? status ?? this.overviewStatus,
      selectedTab: selectedTab ?? this.selectedTab,
      details: clearDetails ? null : (details ?? this.details),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorObject: clearError ? null : (errorObject ?? this.errorObject),
    );
  }
}
