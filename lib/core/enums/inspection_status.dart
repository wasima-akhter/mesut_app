enum InspectionStatus {
  scheduled,
  inProgress,
  completed,
  failed;

  String get label {
    switch (this) {
      case InspectionStatus.scheduled:
        return 'Scheduled';
      case InspectionStatus.inProgress:
        return 'In Progress';
      case InspectionStatus.completed:
        return 'Completed';
      case InspectionStatus.failed:
        return 'Failed';
    }
  }
}
