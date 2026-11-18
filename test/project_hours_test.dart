import 'package:construction_app/core/localization/app_strings.dart';
import 'package:construction_app/features/employee/shared/helper/employee_enums.dart';
import 'package:construction_app/features/employee/shared/helper/employee_models.dart';
import 'package:construction_app/features/site_manager/home/presentation/providers/site_manager_home_provider.dart';
import 'package:construction_app/features/site_manager/projects/presentation/providers/site_manager_project_details_provider.dart';
import 'package:construction_app/features/site_manager/projects/domain/entities/project_phase_card_entity.dart';
import 'package:construction_app/features/site_manager/projects/enums.dart';
import 'package:construction_app/features/site_manager/projects/models.dart';
import 'package:construction_app/features/site_manager/projects/presentation/providers/site_manager_projects_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Project Model Hours & Profitability Tests', () {
    test('Calculates profitability correctly when under budget', () {
      const project = Project(
        id: 'Prj-0842',
        title: 'Goltstein Complex',
        company: 'Hochief AG',
        address: 'Goltsteinstraße 12, 50968 Köln',
        owner: 'Mesut Yilmaz',
        duration: 'Erection: Sept 18 – Sept 20',
        phase: ProjectPhase.erection,
        priority: ProjectPriority.high,
        status: ProjectStatus.inProgress,
        totalLoggedHours: 142.5,
        budgetHours: 160.0,
      );

      expect(project.totalLoggedHours, equals(142.5));
      expect(project.budgetHours, equals(160.0));
      expect(project.isProfitable, isTrue);
      expect(project.remainingHours, equals(17.5));
      expect(project.budgetProgress, closeTo(0.89, 0.01));
      expect(project.formattedTotalHours, equals('142.5h'));
      expect(project.formattedBudgetHours, equals('160h'));
    });

    test('Calculates loss risk correctly when exceeding budget', () {
      const project = Project(
        id: 'Prj-0858',
        title: 'Central Plaza',
        company: 'Hochief AG',
        address: 'Hohenzollernring 44, 50672 Köln',
        owner: 'Mesut Yilmaz',
        duration: 'Dismantling: Sept 21 – Sept 25',
        phase: ProjectPhase.dismantling,
        priority: ProjectPriority.high,
        status: ProjectStatus.notStarted,
        totalLoggedHours: 114.5,
        budgetHours: 100.0,
      );

      expect(project.isProfitable, isFalse);
      expect(project.remainingHours, equals(-14.5));
      expect(project.budgetProgress, closeTo(1.145, 0.01));
      expect(project.formattedTotalHours, equals('114.5h'));
      expect(project.formattedBudgetHours, equals('100h'));
    });
  });

  group('ProjectDetailsState Labor & Hours Tests', () {
    test('Initial ProjectDetailsState has accurate crew hours breakdown', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(projectDetailsProvider);

      expect(state.totalLoggedHours, equals(142.5));
      expect(state.budgetHours, equals(160.0));
      expect(state.isProfitable, isTrue);
      expect(state.remainingHours, equals(17.5));
      expect(state.crewHours.length, equals(4));

      final tim = state.crewHours.firstWhere(
        (c) => c.employeeName == 'Tim Müller',
      );
      expect(tim.loggedHours, equals(54.5));
      expect(tim.formattedHours, equals('54.5h'));

      final sumCrew = state.crewHours.fold<double>(
        0.0,
        (acc, c) => acc + c.loggedHours,
      );
      expect(sumCrew, equals(state.totalLoggedHours));

      expect(state.activityHours.containsKey('Erection'), isTrue);
      expect(state.activityHours.containsKey('Dismantling'), isTrue);
    });

    test('ProjectDetailsState copyWith updates hours and crew data', () {
      const state = ProjectDetailsState();
      final updated = state.copyWith(
        totalLoggedHours: 175.0,
        budgetHours: 160.0,
      );

      expect(updated.totalLoggedHours, equals(175.0));
      expect(updated.isProfitable, isFalse);
      expect(updated.remainingHours, equals(-15.0));
    });
  });

  group('SiteManagerProjectsProvider Hours Data Tests', () {
    test(
      'Initial state has no dummy projects and tracks empty list before fetch',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final state = container.read(siteManagerProjectsProvider);
        expect(state.items, isEmpty);
      },
    );

    test('ProjectPhaseCardEntity hours and profitability calculation', () {
      const card = ProjectPhaseCardEntity(
        phaseId: 'phase-1',
        type: 'ERECTION',
        status: 'IN_PROGRESS',
        priority: 'HIGH',
        durationDays: 3,
        projectId: 'prj-0842',
        projectName: 'Goltstein Complex',
        coordinates: ProjectPhaseCoordinates(lat: 50.9082, lng: 6.9723),
        customer: ProjectPhaseCustomer(
          id: 'c-1',
          name: 'Hochtief AG',
          category: 'COMMERCIAL',
        ),
        assigneeName: 'Mesut Yilmaz',
        budgetedHours: 160.0,
        totalLoggedHours: 142.5,
        isProfitable: true,
      );

      expect(card.totalLoggedHours, equals(142.5));
      expect(card.budgetedHours, equals(160.0));
      expect(card.isProfitable, isTrue);
      expect(card.hasHoursLogged, isTrue);
      expect(card.hasBudget, isTrue);
      expect(card.formattedLoggedHours, equals('142.5'));
      expect(card.formattedBudgetHours, equals('160.0'));
      expect(card.formattedAddress, contains('Goltsteinstraße'));
    });
  });

  group('SiteManagerHomeState Operations Hours Tests', () {
    test(
      'Operation cards in home dashboard contain loggedHours and budgetHours',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final homeState = container.read(siteManagerHomeProvider);
        expect(homeState.operations.isNotEmpty, isTrue);

        for (final op in homeState.operations) {
          expect(op.containsKey('loggedHours'), isTrue);
          expect(op.containsKey('budgetHours'), isTrue);
          final logged = (op['loggedHours'] as num).toDouble();
          final budget = (op['budgetHours'] as num).toDouble();
          expect(logged, greaterThan(0));
          expect(budget, greaterThan(0));
        }
      },
    );
  });

  group('EmployeeAssignmentModel Hours Tests', () {
    test('EmployeeAssignmentModel exposes total project hours', () {
      const assignment = EmployeeAssignmentModel(
        project: 'PRJ-0842 · Goltstein Complex',
        address: 'Goltsteinstraße 12, 50968 Köln',
        activity: EmployeeActivityType.erection,
        schedule: '07:30 am – 04:15 pm',
        scaffoldArea: '450 m²',
        siteManager: 'Mesut Yilmaz',
        totalProjectHours: '142.5h',
      );

      expect(assignment.totalProjectHours, equals('142.5h'));
    });
  });

  group('Project Time Logs Sheet Localization Tests', () {
    test(
      'AppStrings provides correct project time logs strings and interpolation',
      () {
        const strings = AppStrings({});

        expect(strings.totalProjectHours, equals('Total Project Hours'));
        expect(
          strings.loggedAcrossEmployees('142.5h', 4),
          equals('142.5h logged across 4 employees'),
        );
        expect(
          strings.profitabilityHealthy,
          equals('Project Profitability: Healthy'),
        );
        expect(
          strings.profitabilityAtRisk,
          equals('Project Profitability: At Risk'),
        );
        expect(
          strings.remainingUnderLaborBudget('17.5', '160h'),
          equals('17.5h remaining under the 160h labor budget.'),
        );
        expect(
          strings.exceedingBudgetLimit('14.5', '100h'),
          equals('14.5h exceeding the allocated 100h target.'),
        );
        expect(
          strings.itemizedTimeLogsByCrew,
          equals('Itemized Time Logs by Crew'),
        );
        expect(
          strings.primaryTask('Erection Phase'),
          equals('Primary task: Erection Phase'),
        );
        expect(strings.underBudget, equals('Under Budget'));
        expect(strings.overBudget, equals('Over Budget'));
        expect(strings.leadScaffolder, equals('Lead Scaffolder'));
        expect(strings.scaffolder, equals('Scaffolder'));
        expect(strings.erectionAndAnchoring, equals('Erection & Anchoring'));
        expect(strings.materialHandling, equals('Material Handling'));
      },
    );
  });
}
