import 'package:construction_app/features/site_manager/presentation/providers/site_manager_photos_provider.dart';
import 'package:construction_app/features/site_manager/projects/models.dart';
import 'package:construction_app/features/site_manager/projects/services/pdf_export_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectPhotosProvider State Tests', () {
    test('initial state contains initial photos and plan files', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(projectPhotosProvider);
      expect(state.photos.isNotEmpty, isTrue);
      expect(state.planFiles.isNotEmpty, isTrue);
      expect(state.coverPhoto, isNotNull);
      expect(state.coverPhoto!.isCover, isTrue);
    });

    test('addPhoto and removePhoto updates state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(projectPhotosProvider.notifier);
      final initialCount = container.read(projectPhotosProvider).photos.length;

      final newPhoto = ProjectPhoto(
        id: 'test_123',
        url: 'https://example.com/photo.jpg',
        title: 'Test Photo',
      );

      notifier.addPhoto(newPhoto);
      expect(container.read(projectPhotosProvider).photos.length, initialCount + 1);
      expect(
        container.read(projectPhotosProvider).photos.any((p) => p.id == 'test_123'),
        isTrue,
      );

      notifier.removePhoto('test_123');
      expect(container.read(projectPhotosProvider).photos.length, initialCount);
    });

    test('setCoverPhoto marks target photo as cover', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(projectPhotosProvider.notifier);
      final secondPhotoId = container.read(projectPhotosProvider).photos[1].id;

      notifier.setCoverPhoto(secondPhotoId);

      final state = container.read(projectPhotosProvider);
      expect(state.coverPhoto?.id, secondPhotoId);
      expect(state.photos.firstWhere((p) => p.id == secondPhotoId).isCover, isTrue);
    });

    test('addPlanFile and removePlanFile updates plans list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(projectPhotosProvider.notifier);
      final initialPlansCount = container.read(projectPhotosProvider).planFiles.length;

      final testPlan = ProjectPlanFile(name: 'New_Scaffold_Plan.pdf', size: '3.1 MB');
      notifier.addPlanFile(testPlan);
      expect(container.read(projectPhotosProvider).planFiles.length, initialPlansCount + 1);

      notifier.removePlanFile('New_Scaffold_Plan.pdf');
      expect(container.read(projectPhotosProvider).planFiles.length, initialPlansCount);
    });

    test('photo selection toggle and selectAll works', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(projectPhotosProvider.notifier);
      final firstId = container.read(projectPhotosProvider).photos.first.id;

      notifier.togglePhotoSelection(firstId);
      expect(container.read(projectPhotosProvider).isSelected(firstId), isTrue);

      notifier.selectAllPhotos();
      final allPhotosCount = container.read(projectPhotosProvider).photos.length;
      expect(container.read(projectPhotosProvider).selectedPhotoIds.length, allPhotosCount);

      notifier.clearSelection();
      expect(container.read(projectPhotosProvider).selectedPhotoIds.isEmpty, isTrue);
    });
  });

  group('PdfExportService Tests', () {
    test('generateSamplePlanPdf produces valid PDF byte output', () async {
      final bytes = await PdfExportService.generateSamplePlanPdf('Approval_Plan_01.pdf');
      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      // Valid PDF files start with %PDF
      final header = String.fromCharCodes(bytes.take(4));
      expect(header, '%PDF');
    });

    test('generatePhotosPdf compiles photos into PDF byte output', () async {
      final photos = [
        ProjectPhoto(
          id: 'test1',
          url: 'non_existent_local_path.jpg',
          title: 'Photo 1',
          caption: 'Facade inspection detail',
        ),
      ];

      final bytes = await PdfExportService.generatePhotosPdf(
        photos: photos,
        projectName: 'Goltstein Complex',
        projectId: 'Prj-0842',
      );

      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      final header = String.fromCharCodes(bytes.take(4));
      expect(header, '%PDF');
    });
  });
}
