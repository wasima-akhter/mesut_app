import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../utils/app_date_time_formatter.dart';

extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  DateTime get dateOnly => DateTime(year, month, day);

  /// Convert to ISO-8601 UTC timestamp string
  String toUtcIso() => AppDateTimeFormatter.toUtcIsoString(this);

  /// Format date localized
  String formatLocalized({AppLanguage? language, String style = 'medium'}) =>
      AppDateTimeFormatter.formatDate(this, language: language, style: style);

  /// Format date range localized
  String formatRangeLocalized(DateTime end, {AppLanguage? language}) =>
      AppDateTimeFormatter.formatDateRange(this, end, language: language);

  /// Format relative timestamp (e.g. "Today, 08:30 AM" or "Heute, 08:30 Uhr")
  String formatRelative({AppLanguage? language, bool includeTime = true}) =>
      AppDateTimeFormatter.formatRelative(this,
          language: language, includeTime: includeTime);

  /// Get day of the week name localized
  String getDayName({
    AppLanguage? language,
    bool short = false,
    bool upper = false,
  }) =>
      AppDateTimeFormatter.dayName(this,
          language: language, short: short, upper: upper);

  /// Get month name localized
  String getMonthName({
    AppLanguage? language,
    bool short = false,
    bool upper = false,
  }) =>
      AppDateTimeFormatter.monthName(month,
          language: language, short: short, upper: upper);

  /// Format day header (e.g. "MONDAY, OCT 8" or "MONTAG, 8. OKT.")
  String formatDayHeader({AppLanguage? language}) =>
      AppDateTimeFormatter.formatDayHeader(this, language: language);
}

extension DurationExtensions on Duration {
  /// Format duration in full form (e.g. "1 hour 30 minutes" or "1 Stunde 30 Minuten")
  String formatFullLocalized({AppLanguage? language}) =>
      AppDateTimeFormatter.formatDurationFull(this, language: language);

  /// Format duration in compact form (e.g. "7h 30m" or "7 Std. 30 Min.")
  String formatCompactLocalized({AppLanguage? language}) =>
      AppDateTimeFormatter.formatDurationCompact(this, language: language);
}

extension TimeOfDayExtensions on TimeOfDay {
  /// Format TimeOfDay localized (e.g. "07:30 am" or "07:30 Uhr")
  String formatLocalized({AppLanguage? language}) =>
      AppDateTimeFormatter.formatTimeOfDay(this, language: language);
}
