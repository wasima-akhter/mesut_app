enum JobStatus {
  upcoming,
  active,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case JobStatus.upcoming:
        return 'Upcoming';
      case JobStatus.active:
        return 'Active';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }
}
