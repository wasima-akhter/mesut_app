import '../../../core/localization/app_localization.dart';

enum TimeTrackingTab { myTime, siteCrewTime }

enum ActivityType { erection, dismantling, standing, others }

extension ActivityTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.erection:
        return AppLocalization.current.scaffoldErection;
      case ActivityType.dismantling:
        return AppLocalization.current.scaffoldDismantling;
      case ActivityType.standing:
        return AppLocalization.current.standingScaffold;
      case ActivityType.others:
        return AppLocalization.current.otherActivity;
    }
  }
}

enum TimeEntryFilter { thisWeek, thisMonth }

extension TimeEntryFilterExtension on TimeEntryFilter {
  String get label {
    switch (this) {
      case TimeEntryFilter.thisWeek:
        return AppLocalization.current.thisWeek;
      case TimeEntryFilter.thisMonth:
        return AppLocalization.current.thisMonth;
    }
  }
}

enum TimeEntryTab { myTime, siteCrewTime }

extension TimeEntryTabX on TimeEntryTab {
  String get label {
    switch (this) {
      case TimeEntryTab.myTime:
        return AppLocalization.current.myTime;

      case TimeEntryTab.siteCrewTime:
        return AppLocalization.current.siteCrewTime;
    }
  }
}
