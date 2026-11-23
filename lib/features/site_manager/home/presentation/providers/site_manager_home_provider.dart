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
    this.activeSites = 0,
    this.scaffolds = 0,
    this.inspectionsDue = 0,
    this.operations = const [],
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
