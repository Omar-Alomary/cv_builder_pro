import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/core/utils/date_formatter.dart';
import 'package:cv_builder_pro/core/utils/validators.dart';
import 'package:cv_builder_pro/translations/index.dart';

void main() {
  setUp(() {
    Get.addTranslations(AppTranslations().keys);
  });
  tearDown(Get.reset);
  test('Arabic and Persian digits normalize without changing other text', () {
    expect(DateFormatter.normalizeDigits('١٢/٢٠٢٤'), '12/2024');
    expect(DateFormatter.normalizeDigits('۱۲/۲۰۲۴'), '12/2024');
    expect(DateFormatter.parseMonthYear('١/٢٠٢٤'), DateTime(2024, 1));
  });
  test('graduation years accept the expected graduation boundary', () {
    final now = DateTime(2026, 10, 1);
    for (final year in ['1900', '2026', '2036', '٢٠٢٤']) {
      expect(Validators.validateYear(year, now: now), isNull);
    }
    for (final year in ['', '1899', '2037', '20xx', '24']) {
      expect(Validators.validateYear(year, now: now), isNotNull);
    }
  });
  test(
    'experience dates require valid months chronological order and no future months',
    () {
      final now = DateTime(2026, 10, 1);
      expect(Validators.validateMonthYear('10/2026', now: now), isNull);
      expect(Validators.validateMonthYear('11/2026', now: now), isNotNull);
      expect(Validators.validateMonthYear('13/2024', now: now), isNotNull);
      expect(
        Validators.validateEndDate('01/2024', startDate: '01/2024', now: now),
        isNull,
      );
      expect(
        Validators.validateEndDate('01/2024', startDate: '02/2024', now: now),
        isNotNull,
      );
      expect(
        Validators.validateEndDate('', startDate: '02/2024', now: now),
        isNotNull,
      );
    },
  );
}
