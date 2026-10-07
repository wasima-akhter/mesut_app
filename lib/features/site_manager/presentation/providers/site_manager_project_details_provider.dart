import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/enums.dart';
import '../../projects/models.dart';

class ProjectDetailsState {
  final ProjectDetailsTab selectedTab;
  final TaskStatusTab selectedTaskTab;
  final List<ProjectTask> tasks;
  final List<MeasurementItem> measurementItems;
  final List<ProjectNote> notes;
  final List<String> voiceNotes;
  final String selectedPhotoCategory;
  final List<PhotoItem> photos;

  const ProjectDetailsState({
    this.selectedTab = ProjectDetailsTab.overview,
    this.selectedTaskTab = TaskStatusTab.open,
    this.tasks = const [],
    this.measurementItems = const [],
    this.notes = const [],
    this.voiceNotes = const [
      'Voice note 01 • North facade inspection audio record (0:45)',
    ],
    this.selectedPhotoCategory = 'All',
    this.photos = const [
      PhotoItem(
        title: 'Erection - Level 3 Complete',
        meta: '18 Sep 2026, 14:22 • Tim Müller',
        tag: 'Erection',
        badge: 'NEW',
        imagePath: 'assets/images/project_preview.jpg',
      ),
      PhotoItem(
        title: 'Base Jack Leveling Check',
        meta: '17 Sep 2026, 09:10 • Mesut Yilmaz',
        tag: 'Base Check',
        badge: null,
        imagePath: 'assets/images/project_preview.jpg',
      ),
      PhotoItem(
        title: 'Corner Anchor Detail B2',
        meta: '16 Sep 2026, 16:45 • Tim Müller',
        tag: 'Anchor Check',
        badge: null,
        imagePath: 'assets/images/project_preview.jpg',
      ),
    ],
  });

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
    );
  }
}

class ProjectDetailsNotifier extends Notifier<ProjectDetailsState> {
  @override
  ProjectDetailsState build() {
    return ProjectDetailsState(
      tasks: [
        ProjectTask(
          description:
              'Anchor scaffolds ties into reinforced concrete at 4th floor',
          employee: 'Tim Muler',
          priority: ProjectPriority.high,
          dueDate: null,
        ),
        ProjectTask(
          description:
              'Anchor scaffolds ties into reinforced concrete at 4th floor',
          employee: 'Tim Muler',
          priority: ProjectPriority.high,
          dueDate: null,
        ),
        ProjectTask(
          description:
              'Anchor scaffolds ties into reinforced concrete at 4th floor',
          employee: 'Tim Muler',
          priority: ProjectPriority.high,
          dueDate: null,
          completed: true,
        ),
        ProjectTask(
          description:
              'Anchor scaffolds ties into reinforced concrete at 4th floor',
          employee: 'Tim Muler',
          priority: ProjectPriority.high,
          dueDate: null,
          completed: true,
        ),
      ],
      measurementItems: [
        MeasurementItem(
          position: 'Section A - North Facade',
          length: 18.50,
          height: 12.00,
          quantity: 1,
          unit: 'm²',
          remark: 'Front Scaffold (Fassadengerüst)',
        ),
        MeasurementItem(
          position: 'Section B - West Wing',
          length: 14.00,
          height: 9.50,
          quantity: 1,
          unit: 'm²',
          remark: 'Front Scaffold (Fassadengerüst)',
        ),
        MeasurementItem(
          position: 'Roof Protection - North',
          length: 18.50,
          height: 2.00,
          quantity: 1,
          unit: 'm²',
          remark: 'Roof Safety Scaffold',
        ),
      ],
      notes: [
        ProjectNote(
          category: ProjectNoteCategory.general,
          author: 'Mesut Yilmaz',
          details:
              'Ground check completed. North facade ground is level and ready for base jacks. Client requested extra pedestrian tunnel at main entrance.',
        ),
        ProjectNote(
          category: ProjectNoteCategory.siteAccess,
          author: 'Tim Muller',
          details:
              'Material delivery received: 120 standards, 80 ledgers, base plates confirmed. Stored at laydown area B as agreed with site security.',
        ),
        ProjectNote(
          category: ProjectNoteCategory.specialRequirements,
          author: 'Mesut Yilmaz',
          details:
              'Pre-assembly briefing done with crew. High-wind protocol reviewed. Weather forecast shows rain on Thursday - plan to finish Section A by Wednesday evening.',
        ),
      ],
    );
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
