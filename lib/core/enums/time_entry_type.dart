import '../localization/app_localization.dart';

enum TimeEntryType {
  regular,
  breakTime,
  overtime;

  String get label {
    switch (this) {
      case TimeEntryType.regular:
        return AppLocalization.current.get('timeEntry.regular', 'Regular');
      case TimeEntryType.breakTime:
        return AppLocalization.current.get('timeEntry.break', 'Break');
      case TimeEntryType.overtime:
        return AppLocalization.current.get('timeEntry.overtime', 'Overtime');
    }
  }
}
