import 'package:construction_app/core/enums/backend_enums.dart';
import 'package:construction_app/features/shared/mobile_time_tracking/data/datasources/mobile_time_tracking_datasource.dart';
import 'package:construction_app/features/shared/mobile_time_tracking/data/models/mobile_time_tracking_models.dart';
import 'package:construction_app/features/shared/mobile_time_tracking/data/repositories/mobile_time_tracking_repository_impl.dart';
import 'package:construction_app/features/shared/mobile_time_tracking/domain/entities/mobile_time_log_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMobileTimeTrackingRemoteDataSource extends Mock
    implements MobileTimeTrackingRemoteDataSource {}

void main() {
  group('MobileTimeTracking Models & Repository Tests', () {
    test('MobileTimerStartResultModel parses timeLog and project', () {
      final result = MobileTimerStartResultModel.fromJson({
        'timeLog': {
          'id': 'log-1',
          'phaseId': 'phase-1',
          'activityType': 'ERECTION',
          'startTime': '2026-11-12T09:13:52.467Z',
          'endTime': null,
          'isManual': false,
          'status': 'PENDING_APPROVAL',
          'breakMinutes': 0,
          'netHours': 0,
          'user': {'id': 'u-1', 'firstName': 'Tim', 'lastName': 'Muller'},
        },
        'project': {
          'id': 'proj-1',
          'name': 'Goltstein Complex',
          'address': 'Goltsteinstr. 12',
          'customer': {'id': 'c-1', 'name': 'Hochtief AG'},
          'phases': [],
          'budgetedHours': 100,
          'totalLoggedHours': 20,
          'isProfitable': true,
        },
      });

      expect(result.timeLog.id, equals('log-1'));
      expect(result.timeLog.activityType, equals(BackendActivityType.erection));
      expect(result.timeLog.user?.fullName, equals('Tim Muller'));
      expect(result.project?.name, equals('Goltstein Complex'));
    });

    test(
      'MobileCrewTimeModel parses totalProjectHours, hoursByActivity, crewBreakdown, and logs',
      () {
        final crew = MobileCrewTimeModel.fromJson({
          'totalProjectHours': 18.5,
          'hoursByActivity': [
            {'activityType': 'ERECTION', 'hours': 12.0},
            {'activityType': 'DISMANTLING', 'hours': 6.5},
          ],
          'crewBreakdown': [
            {
              'user': {'id': 'u-1', 'firstName': 'Alex', 'lastName': 'Brown'},
              'totalHours': 8.5,
              'synced': true,
            },
            {
              'user': {'id': 'u-2', 'firstName': 'John', 'lastName': 'Smith'},
              'totalHours': 10.0,
              'synced': false,
            },
          ],
          'logs': [
            {
              'id': 'log-2',
              'phaseId': 'phase-2',
              'activityType': 'DISMANTLING',
              'startTime': '2026-11-12T08:00:00Z',
              'endTime': '2026-11-12T14:30:00Z',
              'isManual': true,
              'status': 'APPROVED',
              'breakMinutes': 30,
              'netHours': 6.0,
            },
          ],
        });

        expect(crew.totalProjectHours, equals(18.5));
        expect(crew.hoursByActivity, hasLength(2));
        expect(crew.crewBreakdown, hasLength(2));
        expect(crew.crewBreakdown.last.synced, isFalse);
        expect(crew.logs, hasLength(1));
        expect(crew.logs.first.netHours, equals(6.0));
      },
    );

    test('MobileTimeTrackingRepositoryImpl delegates all 5 methods', () async {
      final mockDs = MockMobileTimeTrackingRemoteDataSource();
      final repo = MobileTimeTrackingRepositoryImpl(mockDs);

      const dummyLog = MobileTimeLogEntity(
        id: 'log-1',
        phaseId: 'ph-1',
        activityType: BackendActivityType.erection,
      );

      when(
        () => mockDs.startTimer(
          phaseId: 'ph-1',
          activityType: BackendActivityType.erection,
          gpsStartLat: 50.9,
          gpsStartLng: 6.9,
        ),
      ).thenAnswer(
        (_) async => const MobileTimerStartResultEntity(timeLog: dummyLog),
      );
      when(
        () => mockDs.stopTimer(
          timeLogId: 'log-1',
          gpsEndLat: 50.9,
          gpsEndLng: 6.9,
        ),
      ).thenAnswer((_) async => dummyLog);
      final start = DateTime.utc(2026, 11, 12, 8);
      final end = DateTime.utc(2026, 11, 12, 16);
      when(
        () => mockDs.logManualTime(
          phaseId: 'ph-1',
          activityType: BackendActivityType.erection,
          startTime: start,
          endTime: end,
          breakMinutes: 30,
        ),
      ).thenAnswer((_) async => dummyLog);
      when(
        () => mockDs.getTimeLogs(period: 'WEEK'),
      ).thenAnswer((_) async => const [dummyLog]);
      when(
        () => mockDs.getCrewTime(projectId: 'proj-1'),
      ).thenAnswer((_) async => const MobileCrewTimeEntity());

      await repo.startTimer(
        phaseId: 'ph-1',
        activityType: BackendActivityType.erection,
        gpsStartLat: 50.9,
        gpsStartLng: 6.9,
      );
      await repo.stopTimer(timeLogId: 'log-1', gpsEndLat: 50.9, gpsEndLng: 6.9);
      await repo.logManualTime(
        phaseId: 'ph-1',
        activityType: BackendActivityType.erection,
        startTime: start,
        endTime: end,
        breakMinutes: 30,
      );
      await repo.getTimeLogs(period: 'WEEK');
      await repo.getCrewTime(projectId: 'proj-1');

      verify(
        () => mockDs.startTimer(
          phaseId: 'ph-1',
          activityType: BackendActivityType.erection,
          gpsStartLat: 50.9,
          gpsStartLng: 6.9,
        ),
      ).called(1);
      verify(
        () => mockDs.stopTimer(
          timeLogId: 'log-1',
          gpsEndLat: 50.9,
          gpsEndLng: 6.9,
        ),
      ).called(1);
      verify(() => mockDs.getTimeLogs(period: 'WEEK')).called(1);
      verify(() => mockDs.getCrewTime(projectId: 'proj-1')).called(1);
    });
  });
}
