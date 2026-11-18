import 'package:construction_app/features/employee/time_tracking/presentation/providers/employee_timer_provider.dart';
import 'package:construction_app/features/entry/nav/bottom_nav_tabs.dart';
import 'package:construction_app/features/site_manager/home/presentation/providers/site_manager_home_provider.dart';
import 'package:construction_app/features/site_manager/time_tracking/presentation/providers/site_manager_time_provider.dart';
import 'package:construction_app/features/site_manager/projects/enums.dart';
import 'package:construction_app/features/site_manager/projects/presentation/providers/site_manager_projects_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bottom Navigation Tabs Configuration Tests', () {
    test('SiteManagerBottomTabs defines 5 unique routes', () {
      final tabs = SiteManagerBottomTabs.tabs;
      expect(tabs.length, equals(5));
      final routes = tabs.map((t) => t.route).toSet();
      expect(routes.length, equals(5));
    });

    test('EmployeeBottomTabs defines 4 unique routes', () {
      final tabs = EmployeeBottomTabs.tabs;
      expect(tabs.length, equals(4));
      final routes = tabs.map((t) => t.route).toSet();
      expect(routes.length, equals(4));
    });
  });

  group('Riverpod Providers State Tests', () {
    test(
      'EmployeeTimerNotifier start, pause, and finish timer updates state correctly',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(employeeTimerProvider).isTimerRunning, isFalse);
        container.read(employeeTimerProvider.notifier).startTimer();
        expect(container.read(employeeTimerProvider).isTimerRunning, isTrue);
        expect(container.read(employeeTimerProvider).isOnBreak, isFalse);

        container.read(employeeTimerProvider.notifier).pauseTimer();
        expect(container.read(employeeTimerProvider).isOnBreak, isTrue);

        container.read(employeeTimerProvider.notifier).finishTimer();
        expect(container.read(employeeTimerProvider).isTimerRunning, isFalse);
        expect(container.read(employeeTimerProvider).isOnBreak, isFalse);
      },
    );

    test('SiteManagerProjectsNotifier tab selection filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(siteManagerProjectsProvider.notifier);
      notifier.selectTab(ProjectTab.active);
      expect(
        container.read(siteManagerProjectsProvider).selectedTab,
        equals(ProjectTab.active),
      );
    });

    test('SiteManagerHomeNotifier toggles operations view', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(siteManagerHomeProvider.notifier);
      expect(
        container.read(siteManagerHomeProvider).showAllOperations,
        isFalse,
      );
      notifier.toggleShowAllOperations();
      expect(container.read(siteManagerHomeProvider).showAllOperations, isTrue);
    });

    test('SiteManagerTimeNotifier toggles running timer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(siteManagerTimeProvider.notifier);
      expect(container.read(siteManagerTimeProvider).isTimerRunning, isFalse);
      notifier.toggleTimer();
      expect(container.read(siteManagerTimeProvider).isTimerRunning, isTrue);
    });
  });
}
