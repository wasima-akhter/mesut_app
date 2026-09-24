enum TimeEntryType {
  regular,
  breakTime,
  overtime;

  String get label {
    switch (this) {
      case TimeEntryType.regular:
        return 'Regular';
      case TimeEntryType.breakTime:
        return 'Break';
      case TimeEntryType.overtime:
        return 'Overtime';
    }
  }
}
