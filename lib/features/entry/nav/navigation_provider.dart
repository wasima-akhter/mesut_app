import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider = NotifierProvider<NavigationNotifier, int>(
  NavigationNotifier.new,
);

class NavigationNotifier extends Notifier<int> {
  @override
  int build() {
    // Default tab.
    return 0;
  }

  void changeTab(int index) {
    state = index;
  }

  // ------------------------------------------------------------
  // SITE MANAGER TABS
  // ------------------------------------------------------------

  void goToTabHome() {
    changeTab(0);
  }

  void goToTabProjects() {
    changeTab(1);
  }

  void goToTabMap() {
    changeTab(2);
  }

  void goToTabTimer() {
    changeTab(3);
  }

  void goToTabMore() {
    changeTab(4);
  }

  // ------------------------------------------------------------
  // EMPLOYEE TABS
  // ------------------------------------------------------------

  void goToTabTime() {
    changeTab(1);
  }

  void goToTabMyPlan() {
    changeTab(2);
  }

  void goToTabProfile() {
    changeTab(3);
  }
}
