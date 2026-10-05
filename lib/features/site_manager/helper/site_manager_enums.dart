enum TimeTrackingTab { myTime, siteCrewTime }

enum ActivityType { erection, dismantling, standing, others }

extension ActivityTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.erection:
        return 'Erection';
      case ActivityType.dismantling:
        return 'Dismantling';
      case ActivityType.standing:
        return 'Standing';
      case ActivityType.others:
        return 'Others';
    }
  }
}

enum TimeEntryFilter { thisWeek, thisMonth }

extension TimeEntryFilterExtension on TimeEntryFilter {
  String get label {
    switch (this) {
      case TimeEntryFilter.thisWeek:
        return 'This Week';
      case TimeEntryFilter.thisMonth:
        return 'This Month';
    }
  }
}

enum TimeEntryTab { myTime, siteCrewTime }

extension TimeEntryTabX on TimeEntryTab {
  String get label {
    switch (this) {
      case TimeEntryTab.myTime:
        return 'My Time';

      case TimeEntryTab.siteCrewTime:
        return 'Site Crew Time';
    }
  }
}
