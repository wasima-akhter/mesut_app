import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/router/route_guards.dart';
import 'package:construction_app/core/enums/app_enum.dart';
import 'package:construction_app/core/enums/backend_enums.dart';
import 'package:construction_app/core/providers/common_provider.dart';
import 'package:construction_app/core/storage/storage_provider.dart';
import 'package:construction_app/features/employee/time_tracking/data/datasources/mobile_timer_remote_datasource.dart';
import 'package:construction_app/features/employee/time_tracking/domain/entities/offline_time_log.dart';
import 'package:construction_app/features/employee/time_tracking/presentation/providers/offline_sync_provider.dart';
import 'package:construction_app/features/shared/config/domain/entities/mobile_config_entity.dart';
import 'package:construction_app/features/shared/notifications/domain/entities/notification_entity.dart';
import 'package:construction_app/features/shared/notifications/domain/repositories/notifications_repository.dart';
import 'package:construction_app/features/shared/notifications/presentation/providers/notifications_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_app_wrapper.dart';

class MockMobileTimerRemoteDataSource extends Mock
    implements MobileTimerRemoteDataSource {}

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<OfflineTimeLog>[]);
  });

  group('OfflineTimeLog & OfflineSyncNotifier Tests', () {
    late MockMobileTimerRemoteDataSource mockRemote;

    setUp(() {
      mockRemote = MockMobileTimerRemoteDataSource();
    });

    test(
      'OfflineTimeLog generates v4 clientSyncId and preserves across round-trip',
      () {
        final start = DateTime.utc(2026, 5, 1, 8, 0);
        final end = DateTime.utc(2026, 5, 1, 12, 0);

        final log = OfflineTimeLog.create(
          phaseId: 'phase-101',
          activityType: BackendActivityType.erection,
          startTime: start,
          endTime: end,
          breakMinutes: 15,
          projectName: 'Site Alpha',
        );

        expect(log.clientSyncId, isNotEmpty);
        expect(log.clientSyncId.length, greaterThanOrEqualTo(32));

        final stored = log.toStorageJson();
        final restored = OfflineTimeLog.fromStorageJson(stored);
        expect(restored.clientSyncId, equals(log.clientSyncId));
        expect(restored.phaseId, equals('phase-101'));
        expect(restored.activityType, equals(BackendActivityType.erection));
        expect(restored.breakMinutes, equals(15));
      },
    );

    test(
      'OfflineSyncNotifier keeps identical clientSyncId on retry and removes on sync',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = await createTestStorageService();
        await storage.saveAccessToken('valid-token');

        var capturedIds = <String>[];
        var shouldFail = true;

        when(() => mockRemote.syncOfflineLogs(any())).thenAnswer((inv) async {
          final logs = inv.positionalArguments.first as List<OfflineTimeLog>;
          capturedIds = logs.map((e) => e.clientSyncId).toList();
          if (shouldFail) {
            throw Exception('Network unreachable');
          }
          return MobileSyncResult(
            created: 1,
            skipped: 0,
            logs: [
              {'clientSyncId': logs.first.clientSyncId},
            ],
          );
        });

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            storageServiceProvider.overrideWithValue(storage),
            mobileTimerRemoteDataSourceProvider.overrideWithValue(mockRemote),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(offlineSyncProvider.notifier);
        await notifier.enqueueCompletedSegment(
          phaseId: 'phase-22',
          activityType: BackendActivityType.dismantling,
          startTime: DateTime.utc(2026, 5, 2, 9, 0),
          endTime: DateTime.utc(2026, 5, 2, 11, 30),
          attemptImmediateSync: false,
        );

        final pendingBefore = container.read(offlineSyncProvider).pendingLogs;
        expect(pendingBefore, hasLength(1));
        final originalSyncId = pendingBefore.first.clientSyncId;

        // Attempt 1 fails -> queue preserved with same clientSyncId
        final failedResult = await notifier.syncPendingLogs();
        expect(failedResult, isNull);
        expect(capturedIds, equals([originalSyncId]));
        expect(container.read(offlineSyncProvider).pendingLogs, hasLength(1));
        expect(
          container.read(offlineSyncProvider).pendingLogs.first.clientSyncId,
          equals(originalSyncId),
        );

        // Attempt 2 succeeds -> same clientSyncId sent and item removed
        shouldFail = false;
        final successResult = await notifier.syncPendingLogs();
        expect(successResult, isNotNull);
        expect(successResult!.created, equals(1));
        expect(capturedIds, equals([originalSyncId]));
        expect(container.read(offlineSyncProvider).pendingLogs, isEmpty);
      },
    );
  });

  group('MobileConfigEntity Tests', () {
    test(
      'parses defaultLanguage, enabledLanguages, manualTime flag, and legalContents',
      () {
        final config = MobileConfigEntity.fromJson({
          'defaultLanguage': 'de',
          'enabledLanguages': ['de', 'en'],
          'allowEmployeeManualTime': false,
          'legalContents': [
            {
              'legalContentType': 'PRIVACY_AND_POLICY',
              'content': '<p>Datenschutz</p>',
            },
            {
              'legalContentType': 'TERMS_AND_CONDITION',
              'content': '<p>AGB</p>',
            },
          ],
        });

        expect(config.defaultLanguage, equals('de'));
        expect(config.enabledLanguages, equals(['de', 'en']));
        expect(config.allowEmployeeManualTime, isFalse);
        expect(
          config.findLegal(LegalContentType.privacyPolicy)?.content,
          equals('<p>Datenschutz</p>'),
        );
        expect(
          config.findLegal(LegalContentType.termsAndConditions)?.content,
          equals('<p>AGB</p>'),
        );
      },
    );
  });

  group('NotificationsNotifier Socket & Dedupe Tests', () {
    test(
      'handles socket count, new notification dedupe, read, and all-read',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = await createTestStorageService();

        final mockRepo = MockNotificationsRepository();
        when(
          () => mockRepo.getNotifications(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const NotificationsFeedPage(items: [], unreadCount: 0),
        );

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            storageServiceProvider.overrideWithValue(storage),
            notificationsRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(notificationsProvider.future);
        final notifier = container.read(notificationsProvider.notifier);

        notifier.applySocketUnreadCount(2);
        expect(container.read(unreadNotificationsCountProvider), equals(2));

        notifier.applySocketNewNotification({
          'id': 'notif-1',
          'title': 'New Shift',
          'body': 'Assigned to Tower B',
          'isRead': false,
          'createdAt': '2026-05-01T10:00:00.000Z',
        });
        expect(container.read(unreadNotificationsCountProvider), equals(3));

        // Duplicate id must not double-increment unread count
        notifier.applySocketNewNotification({
          'id': 'notif-1',
          'title': 'New Shift',
          'body': 'Assigned to Tower B',
          'isRead': false,
        });
        expect(container.read(unreadNotificationsCountProvider), equals(3));

        notifier.applySocketNotificationRead('notif-1');
        expect(container.read(unreadNotificationsCountProvider), equals(2));

        notifier.applySocketAllRead();
        expect(container.read(unreadNotificationsCountProvider), equals(0));
      },
    );
  });

  group('RouteGuard RBAC Tests', () {
    test(
      'blocks employee from site-manager routes and allows siteManager',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = await createTestStorageService();

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            storageServiceProvider.overrideWithValue(storage),
          ],
        );
        addTearDown(container.dispose);

        final guard = container.read(routeGuardProvider);
        expect(
          guard.isSiteManagerOnlyPath(RouteConstants.siteManagerDashboard),
          isTrue,
        );
        expect(
          guard.isSiteManagerOnlyPath(RouteConstants.siteManagerProjectDetail),
          isTrue,
        );
        expect(
          guard.isSiteManagerOnlyPath(RouteConstants.notifications),
          isFalse,
        );

        container.read(userRoleProvider.notifier).setRole(UserRole.employee);
        expect(guard.canAccessSiteManager(), isFalse);
        expect(guard.canAccessEmployee(), isTrue);

        container.read(userRoleProvider.notifier).setRole(UserRole.siteManager);
        expect(guard.canAccessSiteManager(), isTrue);
        expect(guard.canAccessEmployee(), isFalse);
      },
    );
  });
}
