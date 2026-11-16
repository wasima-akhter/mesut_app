import 'package:construction_app/features/shared/mobile_dashboard/data/datasources/mobile_dashboard_datasource.dart';
import 'package:construction_app/features/shared/mobile_dashboard/data/models/mobile_dashboard_models.dart';
import 'package:construction_app/features/shared/mobile_dashboard/data/repositories/mobile_dashboard_repository_impl.dart';
import 'package:construction_app/features/shared/mobile_dashboard/domain/entities/mobile_dashboard_entity.dart';
import 'package:construction_app/features/shared/mobile_dashboard/domain/entities/mobile_profile_entity.dart';
import 'package:construction_app/features/shared/mobile_dashboard/domain/entities/mobile_project_entity.dart';
import 'package:construction_app/features/shared/mobile_dashboard/domain/entities/mobile_schedule_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMobileDashboardRemoteDataSource extends Mock
    implements MobileDashboardRemoteDataSource {}

void main() {
  group('MobileDashboard Models & Repository Tests', () {
    test('MobileDashboardModel parses stats, upcomingTasks, and mapPins', () {
      final entity = MobileDashboardModel.fromJson({
        'stats': {
          'pendingInspections': 4,
          'assignedProjects': 7,
        },
        'upcomingTasks': [
          {
            'phaseId': 'phase-1',
            'type': 'ERECTION',
            'status': 'ENQUIRY',
            'priority': 'HIGH',
            'startDate': '2026-11-12T06:36:45.459Z',
            'endDate': '2026-11-14T06:36:45.459Z',
            'project': {
              'id': 'proj-1',
              'name': 'Goltstein Complex',
              'address': 'Goltsteinstr. 12, Köln',
            },
          },
        ],
        'mapPins': [
          {
            'id': 'proj-1',
            'name': 'Goltstein Complex',
            'latitude': 50.912,
            'longitude': 6.961,
            'activePhaseType': 'ERECTION',
          },
        ],
      });

      expect(entity.stats.pendingInspections, equals(4));
      expect(entity.stats.assignedProjects, equals(7));
      expect(entity.upcomingTasks, hasLength(1));
      expect(entity.upcomingTasks.first.type, equals('ERECTION'));
      expect(entity.upcomingTasks.first.project.name, equals('Goltstein Complex'));
      expect(entity.mapPins, hasLength(1));
      expect(entity.mapPins.first.latitude, closeTo(50.912, 0.0001));
    });

    test('MobileProjectModel, MobileProfileModel, and MobileScheduleModel parse correctly', () {
      final projects = MobileProjectModel.fromList([
        {
          'id': 'proj-10',
          'name': 'Tower West',
          'address': 'Rheinstr. 5',
          'customer': {'id': 'cust-1', 'name': 'Hochtief AG'},
          'phases': [
            {
              'id': 'ph-1',
              'type': 'DISMANTLING',
              'status': 'IN_PROGRESS',
              'priority': 'MEDIUM',
              'startDate': '2026-11-12T06:36:45.491Z',
              'endDate': '2026-11-18T06:36:45.491Z',
            },
          ],
          'budgetedHours': 120,
          'totalLoggedHours': 48.5,
          'isProfitable': true,
        },
      ]);

      expect(projects, hasLength(1));
      expect(projects.first.customer.name, equals('Hochtief AG'));
      expect(projects.first.phases.first.type, equals('DISMANTLING'));
      expect(projects.first.totalLoggedHours, equals(48.5));
      expect(projects.first.isProfitable, isTrue);

      final profile = MobileProfileModel.fromJson({
        'id': 'u-1',
        'firstName': 'Mesut',
        'lastName': 'Gundogdu',
        'role': 'SITE_MANAGER',
        'email': 'mesut@example.com',
        'phone': '+49123456',
        'avatarUrl': 'https://example.com/avatar.png',
        'weeklyHoursTarget': 40,
        'hoursThisWeek': 32.5,
        'assignedProjectsCount': 6,
        'completedProjectsCount': 19,
      });

      expect(profile.fullName, equals('Mesut Gundogdu'));
      expect(profile.hoursThisWeek, equals(32.5));
      expect(profile.assignedProjectsCount, equals(6));
      expect(profile.completedProjectsCount, equals(19));

      final schedule = MobileScheduleModel.fromList([
        {
          'date': '2026-11-12',
          'phases': [
            {
              'id': 'ph-2',
              'type': 'STANDING',
              'status': 'ENQUIRY',
              'priority': 'LOW',
              'startDate': '2026-11-12T08:00:00Z',
              'endDate': '2026-11-12T16:00:00Z',
              'project': {
                'id': 'proj-2',
                'name': 'Dom Plaza',
                'address': 'Domkloster 4',
              },
            },
          ],
        },
      ]);

      expect(schedule, hasLength(1));
      expect(schedule.first.date, equals('2026-11-12'));
      expect(schedule.first.phases.first.project.name, equals('Dom Plaza'));
    });

    test('MobileDashboardRepositoryImpl delegates all 5 methods to remote datasource', () async {
      final mockDs = MockMobileDashboardRemoteDataSource();
      final repo = MobileDashboardRepositoryImpl(mockDs);

      when(() => mockDs.getDashboard())
          .thenAnswer((_) async => const MobileDashboardEntity());
      when(() => mockDs.getProjects())
          .thenAnswer((_) async => const <MobileProjectEntity>[]);
      when(() => mockDs.getProfile()).thenAnswer(
        (_) async => const MobileProfileEntity(
          id: 'u1',
          firstName: 'A',
          lastName: 'B',
          role: 'EMPLOYEE',
          email: 'a@b.com',
          phone: '123',
        ),
      );
      final start = DateTime.utc(2026, 11, 12);
      final end = DateTime.utc(2026, 11, 19);
      when(() => mockDs.getSchedule(startDate: start, endDate: end))
          .thenAnswer((_) async => const <MobileScheduleDayEntity>[]);
      when(() => mockDs.getMapPins(type: 'ERECTION'))
          .thenAnswer((_) async => const <MobileMapPinEntity>[]);

      await repo.getDashboard();
      await repo.getProjects();
      await repo.getProfile();
      await repo.getSchedule(startDate: start, endDate: end);
      await repo.getMapPins(type: 'ERECTION');

      verify(() => mockDs.getDashboard()).called(1);
      verify(() => mockDs.getProjects()).called(1);
      verify(() => mockDs.getProfile()).called(1);
      verify(() => mockDs.getSchedule(startDate: start, endDate: end)).called(1);
      verify(() => mockDs.getMapPins(type: 'ERECTION')).called(1);
    });
  });
}
