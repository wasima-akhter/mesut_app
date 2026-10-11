import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models.dart';

class ProjectPhotosState {
  final List<ProjectPhoto> photos;
  final List<ProjectPlanFile> planFiles;
  final String activeFilter; // 'all', 'photos', 'plans'
  final Set<String> selectedPhotoIds;
  final bool isGeneratingPdf;

  const ProjectPhotosState({
    this.photos = const [],
    this.planFiles = const [],
    this.activeFilter = 'all',
    this.selectedPhotoIds = const {},
    this.isGeneratingPdf = false,
  });

  ProjectPhoto? get coverPhoto =>
      photos.where((p) => p.isCover).firstOrNull ?? photos.firstOrNull;

  List<ProjectPhoto> get otherPhotos {
    final cover = coverPhoto;
    if (cover == null) return [];
    return photos.where((p) => p.id != cover.id).toList();
  }

  bool isSelected(String id) => selectedPhotoIds.contains(id);

  List<ProjectPhoto> get selectedPhotos {
    if (selectedPhotoIds.isEmpty) return photos;
    return photos.where((p) => selectedPhotoIds.contains(p.id)).toList();
  }

  ProjectPhotosState copyWith({
    List<ProjectPhoto>? photos,
    List<ProjectPlanFile>? planFiles,
    String? activeFilter,
    Set<String>? selectedPhotoIds,
    bool? isGeneratingPdf,
  }) {
    return ProjectPhotosState(
      photos: photos ?? this.photos,
      planFiles: planFiles ?? this.planFiles,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedPhotoIds: selectedPhotoIds ?? this.selectedPhotoIds,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
    );
  }
}

class ProjectPhotosNotifier extends Notifier<ProjectPhotosState> {
  @override
  ProjectPhotosState build() {
    return ProjectPhotosState(
      photos: [
        ProjectPhoto(
          id: '1',
          url: 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5',
          isCover: true,
          title: 'Facade Erection Overview',
          caption: 'North facade scaffold complete with safety netting',
        ),
        ProjectPhoto(
          id: '2',
          url: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
          title: 'Base Jack Leveling Check',
          caption: 'Ground leveling and heavy timber sole plates verification',
        ),
        ProjectPhoto(
          id: '3',
          url: 'https://images.unsplash.com/photo-1590725175248-ecb2a7f7a4c6',
          title: 'Anchor Ties Connection',
          caption: 'Ring bolts installed into reinforced concrete ring beams',
        ),
        ProjectPhoto(
          id: '4',
          url: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e',
          title: 'Corner Scaffold Assembly',
          caption: 'West wing corner connection with double ledger bracing',
        ),
        ProjectPhoto(
          id: '5',
          url: 'https://images.unsplash.com/photo-1541971875076-8f970d573be6',
          title: 'Roof Protection Netting',
          caption: 'Top level roof perimeter safety guardrails installed',
        ),
        ProjectPhoto(
          id: '6',
          url: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742',
          title: 'Access Ladder Tower',
          caption: 'Internal staircase access with self-closing safety gate',
        ),
      ],
      planFiles: [
        ProjectPlanFile(
          name: 'Goltstein_Scaffold_Approval_Plan.pdf',
          size: '2.4 MB',
        ),
        ProjectPlanFile(
          name: 'Goltstein_Scaffold_Approval_Plan_02.pdf',
          size: '1.9 MB',
        ),
      ],
    );
  }

  void addPhoto(ProjectPhoto photo) {
    state = state.copyWith(photos: [...state.photos, photo]);
  }

  void addPhotos(List<ProjectPhoto> newPhotos) {
    state = state.copyWith(photos: [...state.photos, ...newPhotos]);
  }

  void removePhoto(String photoId) {
    final updated = state.photos.where((p) => p.id != photoId).toList();
    // If the removed photo was cover, assign cover to the first remaining
    if (updated.isNotEmpty && !updated.any((p) => p.isCover)) {
      updated.first.isCover = true;
    }
    final updatedSelection = Set<String>.from(state.selectedPhotoIds)
      ..remove(photoId);
    state = state.copyWith(photos: updated, selectedPhotoIds: updatedSelection);
  }

  void setCoverPhoto(String photoId) {
    final updated = state.photos.map((p) {
      return p.copyWith(isCover: p.id == photoId);
    }).toList();
    state = state.copyWith(photos: updated);
  }

  void addPlanFile(ProjectPlanFile planFile) {
    state = state.copyWith(planFiles: [...state.planFiles, planFile]);
  }

  void removePlanFile(String fileName) {
    state = state.copyWith(
      planFiles: state.planFiles.where((f) => f.name != fileName).toList(),
    );
  }

  void togglePhotoSelection(String photoId) {
    final current = Set<String>.from(state.selectedPhotoIds);
    if (current.contains(photoId)) {
      current.remove(photoId);
    } else {
      current.add(photoId);
    }
    state = state.copyWith(selectedPhotoIds: current);
  }

  void selectAllPhotos() {
    state = state.copyWith(
      selectedPhotoIds: state.photos.map((p) => p.id).toSet(),
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedPhotoIds: {});
  }

  void setActiveFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setGeneratingPdf(bool generating) {
    state = state.copyWith(isGeneratingPdf: generating);
  }
}

final projectPhotosProvider =
    NotifierProvider<ProjectPhotosNotifier, ProjectPhotosState>(
  ProjectPhotosNotifier.new,
);
