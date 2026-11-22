import '../localization/app_localization.dart';

enum AbsenceType {
  vacation,
  sick,
  personal,
  other;

  String get label {
    switch (this) {
      case AbsenceType.vacation:
        return AppLocalization.current.get('absence.vacation', 'Vacation');
      case AbsenceType.sick:
        return AppLocalization.current.get('absence.sick', 'Sick Leave');
      case AbsenceType.personal:
        return AppLocalization.current.get('absence.personal', 'Personal');
      case AbsenceType.other:
        return AppLocalization.current.otherActivity;
    }
  }
}
