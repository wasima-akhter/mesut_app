abstract final class DateTimeHelper {
  static String twoDigits(int value) => value.toString().padLeft(2, '0');

  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = twoDigits(dateTime.minute);

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $period';
  }

  static String formatDate(DateTime dateTime) {
    return '${twoDigits(dateTime.day)}/'
        '${twoDigits(dateTime.month)}/'
        '${dateTime.year}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }
}
