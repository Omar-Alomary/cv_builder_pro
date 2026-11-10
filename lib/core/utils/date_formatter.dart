import 'package:intl/intl.dart';
import '../../translations/en_us.dart';
import '../../translations/ar_sa.dart';

/// Strict resume dates and localized relative time.
abstract final class DateFormatter {
  static String normalizeDigits(String value) => String.fromCharCodes(
    value.runes.map((code) {
      if (code >= 0x660 && code <= 0x669) return code - 0x660 + 48;
      if (code >= 0x6f0 && code <= 0x6f9) return code - 0x6f0 + 48;
      return code;
    }),
  );
  static String monthYear(DateTime date) => DateFormat('MM/yyyy').format(date);

  static DateTime? parseMonthYear(String? value) {
    final match = RegExp(
      r'^(0?[1-9]|1[0-2])/([0-9]{4})$',
    ).firstMatch(normalizeDigits(value?.trim() ?? ''));
    if (match == null) return null;
    final year = int.parse(match.group(2)!);
    if (year < 1) return null;
    return DateTime(year, int.parse(match.group(1)!));
  }

  static bool isValidRange(
    String start,
    String? end, {
    bool isCurrent = false,
  }) {
    final first = parseMonthYear(start);
    if (first == null) return false;
    if (isCurrent) return true;
    final last = parseMonthYear(end);
    return last != null && !last.isBefore(first);
  }

  static String relativeTime(
    DateTime date, {
    String locale = 'en',
    DateTime? now,
  }) {
    final difference = (now ?? DateTime.now()).difference(date);
    final messages = locale.split(RegExp('[-_]')).first == 'ar' ? arSa : enUs;
    final future = difference.isNegative;
    final seconds = difference.inSeconds.abs();
    if (seconds < 60) return messages['time_just_now']!;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;
    final int count;
    final String unit;
    if (days > 0) {
      count = days;
      unit = messages[count == 1 ? 'time_day' : 'time_days']!;
    } else if (hours > 0) {
      count = hours;
      unit = messages[count == 1 ? 'time_hour' : 'time_hours']!;
    } else {
      count = minutes;
      unit = messages[count == 1 ? 'time_minute' : 'time_minutes']!;
    }
    return messages[future ? 'time_in' : 'time_ago']!
        .replaceAll('@count', '$count')
        .replaceAll('@unit', unit);
  }
}
