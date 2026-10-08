import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../localization/app_localization.dart';

/// Central reusable utility for converting, formatting, and localizing
/// timestamps, dates, times, days, weeks, months, durations, and measurement units.
class AppDateTimeFormatter {
  const AppDateTimeFormatter._();

  // ============================================================
  // UTC CONVERSIONS & PARSING
  // ============================================================

  /// Parse an ISO-8601 string into a UTC [DateTime].
  /// Example: "2026-10-08 14:30" or "2026-10-08T14:30:00Z" -> DateTime (UTC)
  static DateTime parseUtc(String raw) {
    final sanitized = raw.trim().replaceAll(' ', 'T');
    final parsed = DateTime.tryParse(sanitized) ?? DateTime.now();
    return parsed.isUtc ? parsed : parsed.toUtc();
  }

  /// Convert a [DateTime] into a standardized UTC ISO-8601 string.
  /// Example: "2026-10-08T14:30:00.000Z"
  static String toUtcIsoString(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// Get active language from [AppLocalization] or fallback to English.
  static AppLanguage _getActiveLanguage(AppLanguage? language) {
    if (language != null) return language;
    final code = AppLocalization.current.get('locale.code', 'en');
    return AppLanguage.fromCode(code);
  }

  // ============================================================
  // DAYS OF THE WEEK
  // ============================================================

  static const List<String> _enDaysFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _deDaysFull = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];

  static const List<String> _enDaysShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _deDaysShort = [
    'Mo.',
    'Di.',
    'Mi.',
    'Do.',
    'Fr.',
    'Sa.',
    'So.',
  ];

  /// Get localized day of the week name (1 = Monday, 7 = Sunday).
  static String dayName(
    DateTime date, {
    AppLanguage? language,
    bool short = false,
    bool upper = false,
  }) {
    final lang = _getActiveLanguage(language);
    final weekdayIndex = (date.weekday - 1).clamp(0, 6);

    String name;
    if (lang == AppLanguage.german) {
      name = short ? _deDaysShort[weekdayIndex] : _deDaysFull[weekdayIndex];
    } else {
      name = short ? _enDaysShort[weekdayIndex] : _enDaysFull[weekdayIndex];
    }

    return upper ? name.toUpperCase() : name;
  }

  // ============================================================
  // MONTHS OF THE YEAR
  // ============================================================

  static const List<String> _enMonthsFull = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _deMonthsFull = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];

  static const List<String> _enMonthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _deMonthsShort = [
    'Jan.',
    'Feb.',
    'Mär.',
    'Apr.',
    'Mai',
    'Jun.',
    'Juli',
    'Aug.',
    'Sep.',
    'Okt.',
    'Nov.',
    'Dez.',
  ];

  /// Get localized month name (1 = January, 12 = December).
  static String monthName(
    int month, {
    AppLanguage? language,
    bool short = false,
    bool upper = false,
  }) {
    final lang = _getActiveLanguage(language);
    final monthIndex = (month - 1).clamp(0, 11);

    String name;
    if (lang == AppLanguage.german) {
      name = short ? _deMonthsShort[monthIndex] : _deMonthsFull[monthIndex];
    } else {
      name = short ? _enMonthsShort[monthIndex] : _enMonthsFull[monthIndex];
    }

    return upper ? name.toUpperCase() : name;
  }

  // ============================================================
  // DATE FORMATTING
  // ============================================================

  /// Format a [DateTime] into a localized date string.
  /// Examples:
  /// - German: `8. Okt. 2026`, `8. Oktober 2026`, `08.10.2026`
  /// - English: `Oct 8, 2026`, `October 8, 2026`, `08-10-2026`
  static String formatDate(
    DateTime date, {
    AppLanguage? language,
    String style = 'medium', // 'short', 'medium', 'full', 'numeric'
  }) {
    final lang = _getActiveLanguage(language);
    final localDate = date.toLocal();

    switch (style) {
      case 'numeric':
        final day = localDate.day.toString().padLeft(2, '0');
        final month = localDate.month.toString().padLeft(2, '0');
        final year = localDate.year;
        return lang == AppLanguage.german
            ? '$day.$month.$year'
            : '$day-$month-$year';

      case 'weekday_full':
        final dName = dayName(localDate, language: lang, short: false);
        final mName = monthName(localDate.month, language: lang, short: false);
        return lang == AppLanguage.german
            ? '$dName, ${localDate.day}. $mName'
            : '$dName, $mName ${localDate.day}';

      case 'full':
        final mName = monthName(localDate.month, language: lang, short: false);
        return lang == AppLanguage.german
            ? '${localDate.day}. $mName ${localDate.year}'
            : '$mName ${localDate.day}, ${localDate.year}';

      case 'medium':
      default:
        final mShort = monthName(localDate.month, language: lang, short: true);
        return lang == AppLanguage.german
            ? '${localDate.day}. $mShort ${localDate.year}'
            : '$mShort ${localDate.day}, ${localDate.year}';
    }
  }

  /// Format date range.
  /// Example:
  /// - English: `Sep 14 – Sep 20, 2026`
  /// - German: `14. Sep. – 20. Sep. 2026`
  static String formatDateRange(
    DateTime start,
    DateTime end, {
    AppLanguage? language,
  }) {
    final lang = _getActiveLanguage(language);
    final startLocal = start.toLocal();
    final endLocal = end.toLocal();

    final mStart = monthName(startLocal.month, language: lang, short: true);
    final mEnd = monthName(endLocal.month, language: lang, short: true);

    if (lang == AppLanguage.german) {
      return '${startLocal.day}. $mStart – ${endLocal.day}. $mEnd ${endLocal.year}';
    } else {
      return '$mStart ${startLocal.day} – $mEnd ${endLocal.day}, ${endLocal.year}';
    }
  }

  /// Format date with day name.
  /// Example:
  /// - English: `MONDAY, OCT 8`
  /// - German: `MONTAG, 8. OKT.`
  static String formatDayHeader(DateTime date, {AppLanguage? language}) {
    final lang = _getActiveLanguage(language);
    final localDate = date.toLocal();
    final dName = dayName(localDate, language: lang, upper: true);
    final mName = monthName(localDate.month, language: lang, short: true, upper: true);

    if (lang == AppLanguage.german) {
      return '$dName, ${localDate.day}. $mName';
    } else {
      return '$dName, $mName ${localDate.day}';
    }
  }

  // ============================================================
  // TIME OF DAY & RELATIVE TIMESTAMPS
  // ============================================================

  /// Format a [TimeOfDay].
  /// Example:
  /// - English: `07:30 am` / `04:15 pm`
  /// - German: `07:30 Uhr` / `16:15 Uhr`
  static String formatTimeOfDay(TimeOfDay time, {AppLanguage? language}) {
    final lang = _getActiveLanguage(language);
    final minuteStr = time.minute.toString().padLeft(2, '0');

    if (lang == AppLanguage.german) {
      final hourStr = time.hour.toString().padLeft(2, '0');
      return '$hourStr:$minuteStr Uhr';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'am' : 'pm';
      return '$hour:$minuteStr $period';
    }
  }

  /// Format a [DateTime] time part.
  /// Example:
  /// - English: `10:30 AM` / `04:45 PM`
  /// - German: `10:30 Uhr` / `16:45 Uhr`
  static String formatTime(DateTime dateTime, {AppLanguage? language}) {
    final local = dateTime.toLocal();
    return formatTimeOfDay(
      TimeOfDay(hour: local.hour, minute: local.minute),
      language: language,
    );
  }

  /// Format relative timestamp (e.g. for notifications and photos).
  /// Examples:
  /// - English: `Today, 08:30 AM`, `Yesterday, 04:45 PM`, `Oct 4, 09:00 AM`
  /// - German: `Heute, 08:30 Uhr`, `Gestern, 16:45 Uhr`, `4. Okt., 09:00 Uhr`
  static String formatRelative(
    DateTime dateTime, {
    AppLanguage? language,
    bool includeTime = true,
  }) {
    final lang = _getActiveLanguage(language);
    final local = dateTime.toLocal();
    final now = DateTime.now();

    final isToday = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;

    final timeStr = includeTime ? formatTime(local, language: lang) : '';

    if (isToday) {
      final todayLabel = lang == AppLanguage.german ? 'Heute' : 'Today';
      return includeTime ? '$todayLabel, $timeStr' : todayLabel;
    } else if (isYesterday) {
      final yesterdayLabel = lang == AppLanguage.german ? 'Gestern' : 'Yesterday';
      return includeTime ? '$yesterdayLabel, $timeStr' : yesterdayLabel;
    } else {
      final mShort = monthName(local.month, language: lang, short: true);
      final datePart = lang == AppLanguage.german
          ? '${local.day}. $mShort'
          : '$mShort ${local.day.toString().padLeft(2, '0')}';
      return includeTime ? '$datePart, $timeStr' : datePart;
    }
  }

  // ============================================================
  // DURATIONS & TIME UNITS
  // ============================================================

  /// Full duration string.
  /// Example:
  /// - English: `1 hour 30 minutes` / `2 hours` / `45 minutes`
  /// - German: `1 Stunde 30 Minuten` / `2 Stunden` / `45 Minuten`
  static String formatDurationFull(
    Duration duration, {
    AppLanguage? language,
  }) {
    final lang = _getActiveLanguage(language);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    final parts = <String>[];

    if (hours > 0) {
      if (lang == AppLanguage.german) {
        parts.add(hours == 1 ? '1 Stunde' : '$hours Stunden');
      } else {
        parts.add(hours == 1 ? '1 hour' : '$hours hours');
      }
    }

    if (minutes > 0 || parts.isEmpty) {
      if (lang == AppLanguage.german) {
        parts.add(minutes == 1 ? '1 Minute' : '$minutes Minuten');
      } else {
        parts.add(minutes == 1 ? '1 minute' : '$minutes minutes');
      }
    }

    return parts.join(' ');
  }

  /// Compact duration string.
  /// Example:
  /// - English: `7h 30min` / `45m` / `2hrs`
  /// - German: `7 Std. 30 Min.` / `45 Min.` / `2 Std.`
  static String formatDurationCompact(
    Duration duration, {
    AppLanguage? language,
  }) {
    final lang = _getActiveLanguage(language);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return lang == AppLanguage.german
          ? '$hours Std. $minutes Min.'
          : '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return lang == AppLanguage.german
          ? '$hours Std.'
          : '${hours}h';
    } else {
      return lang == AppLanguage.german
          ? '$minutes Min.'
          : '${minutes}m';
    }
  }

  /// Format short units without altering the numeric value.
  /// Examples:
  /// - `1h` -> `1 Std.`
  /// - `5m` -> `5 Min.`
  /// - `30s` -> `30 Sek.`
  /// - `2.5 days` -> `2.5 Tage`
  /// - `1 week` -> `1 Woche`
  /// - `1 month` -> `1 Monat`
  static String formatShortUnit(
    num value,
    String unitType, {
    AppLanguage? language,
  }) {
    final lang = _getActiveLanguage(language);
    final isGerman = lang == AppLanguage.german;

    switch (unitType.toLowerCase()) {
      case 'h':
      case 'hr':
      case 'hrs':
      case 'hour':
      case 'hours':
        return isGerman ? '$value Std.' : '${value}h';

      case 'm':
      case 'min':
      case 'mins':
      case 'minute':
      case 'minutes':
        return isGerman ? '$value Min.' : '${value}m';

      case 's':
      case 'sec':
      case 'secs':
      case 'second':
      case 'seconds':
        return isGerman ? '$value Sek.' : '${value}s';

      case 'd':
      case 'day':
      case 'days':
        if (isGerman) {
          return value == 1 ? '1 Tag' : '$value Tage';
        }
        return value == 1 ? '1 day' : '$value days';

      case 'w':
      case 'wk':
      case 'wks':
      case 'week':
      case 'weeks':
        if (isGerman) {
          return value == 1 ? '1 Woche' : '$value Wochen';
        }
        return value == 1 ? '1 week' : '$value weeks';

      case 'mo':
      case 'month':
      case 'months':
        if (isGerman) {
          return value == 1 ? '1 Monat' : '$value Monate';
        }
        return value == 1 ? '1 month' : '$value months';

      case 'y':
      case 'yr':
      case 'year':
      case 'years':
        if (isGerman) {
          return value == 1 ? '1 Jahr' : '$value Jahre';
        }
        return value == 1 ? '1 year' : '$value years';

      default:
        return '$value $unitType';
    }
  }

  // ============================================================
  // MEASUREMENT UNITS (AREA, LENGTH, QUANTITY, SPEED)
  // ============================================================

  /// Format measurement values while preserving SI symbols and localizing unit names.
  /// Examples:
  /// - `450 m²` -> `450 m²`
  /// - `24 m` -> `24 m`
  /// - `5 PCS` -> `5 Stk.` (DE) vs `5 PCS` (EN)
  /// - `45 km/h` -> `45 km/h`
  static String formatMeasurement(
    num value,
    String unit, {
    AppLanguage? language,
  }) {
    final lang = _getActiveLanguage(language);
    final isGerman = lang == AppLanguage.german;

    final trimmedUnit = unit.trim().toUpperCase();

    if (trimmedUnit == 'PCS' || trimmedUnit == 'PIECES' || trimmedUnit == 'PIECE') {
      return isGerman ? '$value Stk.' : '$value PCS';
    } else if (trimmedUnit == 'M²' || trimmedUnit == 'M2' || trimmedUnit == 'SQM') {
      return '$value m²';
    } else if (trimmedUnit == 'M' || trimmedUnit == 'METER') {
      return '$value m';
    } else if (trimmedUnit == 'KM/H') {
      return '$value km/h';
    } else if (trimmedUnit == 'KG') {
      return '$value kg';
    } else if (trimmedUnit == 'CM') {
      return '$value cm';
    } else if (trimmedUnit == 'MM') {
      return '$value mm';
    }

    return '$value $unit';
  }

  /// Format calendar week number.
  /// Example:
  /// - English: `Week 38`
  /// - German: `Woche 38` (or `KW 38`)
  static String formatWeek(int weekNumber, {AppLanguage? language, bool useKw = false}) {
    final lang = _getActiveLanguage(language);
    if (lang == AppLanguage.german) {
      return useKw ? 'KW $weekNumber' : 'Woche $weekNumber';
    }
    return 'Week $weekNumber';
  }
}
