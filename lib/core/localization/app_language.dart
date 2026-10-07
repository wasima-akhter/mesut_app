enum AppLanguage {
  english('en', 'English'),
  german('de', 'Deutsch');

  final String code;
  final String label;

  const AppLanguage(this.code, this.label);

  static AppLanguage fromCode(String? code) {
    if (code == 'de') {
      return AppLanguage.german;
    }
    return AppLanguage.english;
  }
}
