extension StringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String get orEmpty => this ?? '';

  String get capitalize {
    final value = this;

    if (value == null || value.isEmpty) {
      return '';
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String get capitalizeWords {
    final value = this;

    if (value == null || value.trim().isEmpty) {
      return '';
    }

    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String get initials {
    final value = this;

    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final parts = value.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
