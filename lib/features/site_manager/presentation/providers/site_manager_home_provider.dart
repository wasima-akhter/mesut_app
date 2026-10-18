import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SiteManagerHomeState {
  final bool notificationsEnabled;
  final bool showAllOperations;
  final int activeSites;
  final int scaffolds;
  final int inspectionsDue;
  final List<Map<String, dynamic>> operations;

  const SiteManagerHomeState({
    this.notificationsEnabled = false,
    this.showAllOperations = false,
    this.activeSites = 3,
    this.scaffolds = 30,
    this.inspectionsDue = 30,
    this.operations = const [
      {
        'type': 'Erection',
        'typeColor': Color(0xFF00A651),
        'project': 'Prj-0842 . Goltsteins.Complex',
        'address': 'Goltsteinstrabe 12, 50968 Köln',
        'client': 'Mesut Rahaman',
        'planned': 14,
        'running': 5,
        'loggedHours': 142.5,
        'budgetHours': 160.0,
      },
      {
        'type': 'Dismantling',
        'typeColor': Color(0xFFFF9800),
        'project': 'Prj-0845 . Riverside Tower',
        'address': 'Rheinstrasse 28, 50667 Köln',
        'client': 'David Miller',
        'planned': 8,
        'running': 3,
        'loggedHours': 85.0,
        'budgetHours': 120.0,
      },
      {
        'type': 'Erection',
        'typeColor': Color(0xFF00A651),
        'project': 'Prj-0850 . Central Plaza',
        'address': 'Hohenzollernring 44, 50672 Köln',
        'client': 'Thomas Weber',
        'planned': 15,
        'running': 7,
        'loggedHours': 114.5,
        'budgetHours': 100.0,
      },
    ],
  });

  List<Map<String, dynamic>> get visibleOperations =>
      showAllOperations ? operations : operations.take(1).toList();

  SiteManagerHomeState copyWith({
    bool? notificationsEnabled,
    bool? showAllOperations,
    int? activeSites,
    int? scaffolds,
    int? inspectionsDue,
    List<Map<String, dynamic>>? operations,
  }) {
    return SiteManagerHomeState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      showAllOperations: showAllOperations ?? this.showAllOperations,
      activeSites: activeSites ?? this.activeSites,
      scaffolds: scaffolds ?? this.scaffolds,
      inspectionsDue: inspectionsDue ?? this.inspectionsDue,
      operations: operations ?? this.operations,
    );
  }
}

class SiteManagerHomeNotifier extends Notifier<SiteManagerHomeState> {
  @override
  SiteManagerHomeState build() {
    return const SiteManagerHomeState();
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void toggleShowAllOperations() {
    state = state.copyWith(showAllOperations: !state.showAllOperations);
  }
}

final siteManagerHomeProvider =
    NotifierProvider<SiteManagerHomeNotifier, SiteManagerHomeState>(
  SiteManagerHomeNotifier.new,
);
