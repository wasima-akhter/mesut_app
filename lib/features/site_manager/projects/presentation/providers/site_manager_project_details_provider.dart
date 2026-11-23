import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums.dart';
import '../../models.dart';

class ProjectDetailsState {
  final ProjectDetailsTab selectedTab;
  final TaskStatusTab selectedTaskTab;
  final List<ProjectTask> tasks;
  final List<MeasurementItem> measurementItems;
  final List<ProjectNote> notes;
  final List<String> voiceNotes;
  final String selectedPhotoCategory;
  final List<PhotoItem> photos;
  final double totalLoggedHours;
  final double budgetHours;
  final List<EmployeeLaborSummary> crewHours;
  final Map<String, double> activityHours;

  const ProjectDetailsState({
    this.selectedTab = ProjectDetailsTab.overview,
    this.selectedTaskTab = TaskStatusTab.open,
    this.tasks = const [],
    this.measurementItems = const [],
    this.notes = const [],
    this.voiceNotes = const [],
    this.selectedPhotoCategory = 'All',
    this.photos = const [],
    this.totalLoggedHours = 0.0,
    this.budgetHours = 0.0,
    this.crewHours = const [],
    this.activityHours = const {},
  });

  bool get isProfitable =>
      budgetHours > 0 ? totalLoggedHours <= budgetHours : true;

  double get remainingHours => budgetHours - totalLoggedHours;

  double get budgetProgress =>
      budgetHours > 0 ? (totalLoggedHours / budgetHours).clamp(0.0, 1.5) : 0.0;

  String get formattedTotalHours =>
      '${totalLoggedHours.toStringAsFixed(totalLoggedHours.truncateToDouble() == totalLoggedHours ? 0 : 1)}h';

  String get formattedBudgetHours =>
      '${budgetHours.toStringAsFixed(budgetHours.truncateToDouble() == budgetHours ? 0 : 1)}h';

  List<ProjectTask> get filteredTasks {
    return tasks.where((t) {
      if (selectedTaskTab == TaskStatusTab.open) return !t.completed;
      return t.completed;
    }).toList();
  }

  ProjectDetailsState copyWith({
    ProjectDetailsTab? selectedTab,
    TaskStatusTab? selectedTaskTab,
    List<ProjectTask>? tasks,
    List<MeasurementItem>? measurementItems,
    List<ProjectNote>? notes,
    List<String>? voiceNotes,
    String? selectedPhotoCategory,
    List<PhotoItem>? photos,
    double? totalLoggedHours,
    double? budgetHours,
    List<EmployeeLaborSummary>? crewHours,
    Map<String, double>? activityHours,
  }) {
    return ProjectDetailsState(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedTaskTab: selectedTaskTab ?? this.selectedTaskTab,
      tasks: tasks ?? this.tasks,
      measurementItems: measurementItems ?? this.measurementItems,
      notes: notes ?? this.notes,
      voiceNotes: voiceNotes ?? this.voiceNotes,
      selectedPhotoCategory:
          selectedPhotoCategory ?? this.selectedPhotoCategory,
      photos: photos ?? this.photos,
      totalLoggedHours: totalLoggedHours ?? this.totalLoggedHours,
      budgetHours: budgetHours ?? this.budgetHours,
      crewHours: crewHours ?? this.crewHours,
      activityHours: activityHours ?? this.activityHours,
    );
  }
}

class ProjectDetailsNotifier extends Notifier<ProjectDetailsState> {
  @override
  ProjectDetailsState build() {
    return const ProjectDetailsState();
  }

  void selectTab(ProjectDetailsTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void selectTaskTab(TaskStatusTab tab) {
    state = state.copyWith(selectedTaskTab: tab);
  }

  void toggleTask(int index) {
    final filtered = state.filteredTasks;
    if (index < 0 || index >= filtered.length) return;
    final targetTask = filtered[index];

    final updatedTasks = state.tasks.map((task) {
      if (identical(task, targetTask) ||
          (task.description == targetTask.description &&
              task.employee == targetTask.employee &&
              task.completed == targetTask.completed)) {
        return task.copyWith(completed: !task.completed);
      }
      return task;
    }).toList();

    state = state.copyWith(tasks: updatedTasks);
  }

  void addTask(ProjectTask task) {
    state = state.copyWith(tasks: [task, ...state.tasks]);
  }

  void addMeasurement(MeasurementItem item) {
    state = state.copyWith(
      measurementItems: [item, ...state.measurementItems],
    );
  }

  void addNote(ProjectNote note) {
    state = state.copyWith(notes: [note, ...state.notes]);
  }

  void addVoiceNote(String voiceNote) {
    state = state.copyWith(voiceNotes: [voiceNote, ...state.voiceNotes]);
  }

  void selectPhotoCategory(String category) {
    state = state.copyWith(selectedPhotoCategory: category);
  }

  void addPhoto(PhotoItem photo) {
    state = state.copyWith(photos: [photo, ...state.photos]);
  }
}

final projectDetailsProvider =
    NotifierProvider<ProjectDetailsNotifier, ProjectDetailsState>(
  ProjectDetailsNotifier.new,
);
