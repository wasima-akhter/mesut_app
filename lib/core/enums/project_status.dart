import '../localization/app_localization.dart';

enum ProjectStatus {
  planning,
  active,
  onHold,
  completed;

  String get label {
    switch (this) {
      case ProjectStatus.planning:
        return AppLocalization.current.get('status.planning', 'Planning');
      case ProjectStatus.active:
        return AppLocalization.current.active;
      case ProjectStatus.onHold:
        return AppLocalization.current.onHold;
      case ProjectStatus.completed:
        return AppLocalization.current.completed;
    }
  }
}
