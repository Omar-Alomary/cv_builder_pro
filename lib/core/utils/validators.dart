import 'package:get/get.dart';
import 'date_formatter.dart';

/// Form validation using the shared translation catalogues.
abstract final class Validators {
  static String? validateYear(String? value, {DateTime? now}) {
    final text = DateFormatter.normalizeDigits(value?.trim() ?? '');
    final year = int.tryParse(text);
    return RegExp(r'^[0-9]{4}$').hasMatch(text) &&
            year != null &&
            year >= 1900 &&
            year <= (now ?? DateTime.now()).year + 10
        ? null
        : 'builder_invalid_year'.tr;
  }

  static String? validateMonthYear(String? value, {DateTime? now}) {
    final date = DateFormatter.parseMonthYear(value);
    if (date == null) return 'invalid_date'.tr;
    final today = now ?? DateTime.now();
    return date.isAfter(DateTime(today.year, today.month))
        ? 'builder_future_date'.tr
        : null;
  }

  static String? validateEndDate(
    String? value, {
    required String startDate,
    DateTime? now,
  }) {
    final error = validateMonthYear(value, now: now);
    if (error != null) return error;
    final start = DateFormatter.parseMonthYear(startDate);
    final end = DateFormatter.parseMonthYear(value)!;
    return start != null && end.isBefore(start)
        ? 'invalid_date_range'.tr
        : null;
  }

  static String? validateRequired(String? value, String fieldName) =>
      value == null || value.trim().isEmpty
      ? 'field_required'.trParams({'field': fieldName})
      : null;

  static String? validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'email_required'.tr;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'invalid_email'.tr;
    }
    return null;
  }

  static String? validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'phone_required'.tr;
    final normalized = text.replaceAll(RegExp(r'[\s()\-]'), '');
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(normalized)) {
      return 'invalid_phone'.tr;
    }
    return null;
  }

  static String? validateUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text)) {
      return 'invalid_url'.tr;
    }
    return null;
  }
}
