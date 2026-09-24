enum AbsenceType {
  vacation,
  sick,
  personal,
  other;

  String get label {
    switch (this) {
      case AbsenceType.vacation:
        return 'Vacation';
      case AbsenceType.sick:
        return 'Sick Leave';
      case AbsenceType.personal:
        return 'Personal';
      case AbsenceType.other:
        return 'Other';
    }
  }
}
