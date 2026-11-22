import '../localization/app_localization.dart';

enum JobStatus {
  upcoming,
  active,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case JobStatus.upcoming:
        return AppLocalization.current.get('status.upcoming', 'Upcoming');
      case JobStatus.active:
        return AppLocalization.current.active;
      case JobStatus.completed:
        return AppLocalization.current.completed;
      case JobStatus.cancelled:
        return AppLocalization.current.get('status.cancelled', 'Cancelled');
    }
  }
}
