import '../localization/app_localization.dart';

enum InspectionStatus {
  scheduled,
  inProgress,
  completed,
  failed;

  String get label {
    switch (this) {
      case InspectionStatus.scheduled:
        return AppLocalization.current.get('status.scheduled', 'Scheduled');
      case InspectionStatus.inProgress:
        return AppLocalization.current.inProgress;
      case InspectionStatus.completed:
        return AppLocalization.current.completed;
      case InspectionStatus.failed:
        return AppLocalization.current.get('status.failed', 'Failed');
    }
  }
}
