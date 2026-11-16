import 'package:construction_app/features/site_manager/data/datasources/mobile_inspection_datasource.dart';
import 'package:construction_app/features/site_manager/data/datasources/mobile_phase_datasource.dart';
import 'package:construction_app/features/site_manager/data/models/mobile_inspection_model.dart';
import 'package:construction_app/features/site_manager/data/models/mobile_phase_model.dart';
import 'package:construction_app/features/site_manager/data/repositories/mobile_inspection_repository_impl.dart';
import 'package:construction_app/features/site_manager/data/repositories/mobile_phase_repository_impl.dart';
import 'package:construction_app/features/site_manager/domain/entities/mobile_inspection_entity.dart';
import 'package:construction_app/features/site_manager/domain/entities/mobile_phase_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMobileInspectionRemoteDataSource extends Mock
    implements MobileInspectionRemoteDataSource {}

class MockMobilePhaseRemoteDataSource extends Mock
    implements MobilePhaseRemoteDataSource {}

void main() {
  group('MobileInspection Models & Repository Tests', () {
    test('MobileInspectionModel parses fields and status flags', () {
      final inspection = MobileInspectionModel.fromJson({
        'id': 'insp-1',
        'siteTitle': 'Goltstein Complex',
        'address': 'Goltsteinstr. 12',
        'postalCode': '50968',
        'city': 'Köln',
        'appointmentDate': '2026-11-12T09:15:47.608Z',
        'scaffoldArea': 120.5,
        'scaffoldHeight': 8.2,
        'scaffoldType': 'Fassade',
        'status': 'PENDING',
        'customer': {'id': 'c-1', 'name': 'Hochtief AG'},
      });

      expect(inspection.id, equals('insp-1'));
      expect(inspection.siteTitle, equals('Goltstein Complex'));
      expect(inspection.scaffoldArea, equals(120.5));
      expect(inspection.scaffoldHeight, equals(8.2));
      expect(inspection.scaffoldType, equals('Fassade'));
      expect(inspection.isPending, isTrue);
      expect(inspection.isSurveyDone, isFalse);
    });

    test('MobileInspectionRepositoryImpl delegates getInspections, getById, and completeInspection', () async {
      final mockDs = MockMobileInspectionRemoteDataSource();
      final repo = MobileInspectionRepositoryImpl(mockDs);

      const dummy = MobileInspectionEntity(
        id: 'insp-1',
        siteTitle: 'Site',
        address: 'Addr',
        postalCode: '50968',
        city: 'Köln',
        status: 'SURVEY_DONE',
      );

      when(() => mockDs.getInspections()).thenAnswer((_) async => const [dummy]);
      when(() => mockDs.getInspectionById('insp-1'))
          .thenAnswer((_) async => dummy);
      when(
        () => mockDs.completeInspection(
          'insp-1',
          scaffoldArea: 120.5,
          scaffoldHeight: 8.2,
          scaffoldType: 'Fassade',
        ),
      ).thenAnswer((_) async => dummy);

      await repo.getInspections();
      await repo.getInspectionById('insp-1');
      final completed = await repo.completeInspection(
        'insp-1',
        scaffoldArea: 120.5,
        scaffoldHeight: 8.2,
        scaffoldType: 'Fassade',
      );

      expect(completed.isSurveyDone, isTrue);
      verify(() => mockDs.getInspections()).called(1);
      verify(() => mockDs.getInspectionById('insp-1')).called(1);
      verify(
        () => mockDs.completeInspection(
          'insp-1',
          scaffoldArea: 120.5,
          scaffoldHeight: 8.2,
          scaffoldType: 'Fassade',
        ),
      ).called(1);
    });
  });

  group('MobilePhase Models & Repository Tests', () {
    test('MobilePhaseModel parses phase and project fields', () {
      final phases = MobilePhaseModel.fromList([
        {
          'id': 'ph-1',
          'type': 'ERECTION',
          'status': 'ENQUIRY',
          'priority': 'HIGH',
          'startDate': '2026-11-12T09:18:26.972Z',
          'endDate': '2026-11-15T09:18:26.972Z',
          'project': {
            'id': 'proj-1',
            'name': 'Tower East',
            'address': 'Rheinstr. 8',
          },
        },
      ]);

      expect(phases, hasLength(1));
      expect(phases.first.type, equals('ERECTION'));
      expect(phases.first.project.name, equals('Tower East'));
    });

    test('MobilePhaseRepositoryImpl delegates getManagedPhases and updatePhaseStatus', () async {
      final mockDs = MockMobilePhaseRemoteDataSource();
      final repo = MobilePhaseRepositoryImpl(mockDs);

      const dummy = MobilePhaseEntity(
        id: 'ph-1',
        type: 'ERECTION',
        status: 'COMPLETED',
        priority: 'HIGH',
        project: MobilePhaseProjectEntity(
          id: 'proj-1',
          name: 'Tower East',
          address: 'Rheinstr. 8',
        ),
      );

      when(() => mockDs.getManagedPhases())
          .thenAnswer((_) async => const [dummy]);
      when(() => mockDs.updatePhaseStatus('ph-1', 'COMPLETED'))
          .thenAnswer((_) async => dummy);

      await repo.getManagedPhases();
      final updated = await repo.updatePhaseStatus('ph-1', 'COMPLETED');

      expect(updated.status, equals('COMPLETED'));
      verify(() => mockDs.getManagedPhases()).called(1);
      verify(() => mockDs.updatePhaseStatus('ph-1', 'COMPLETED')).called(1);
    });
  });
}
