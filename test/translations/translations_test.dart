import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/translations/index.dart';
import 'package:cv_builder_pro/core/utils/validators.dart';
import 'package:cv_builder_pro/core/utils/date_formatter.dart';

void main() {
  setUp(() {
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en', 'US');
  });
  tearDown(() {
    Get.clearTranslations();
    Get.locale = null;
  });

  test('Both catalogues have identical keys and nonempty messages', () {
    expect(arSa.keys.toSet(), enUs.keys.toSet());
    expect(enUs.values.every((value) => value.trim().isNotEmpty), true);
    expect(arSa.values.every((value) => value.trim().isNotEmpty), true);
  });

  test('Locale aliases retain language-only fallback compatibility', () {
    final keys = AppTranslations().keys;
    expect(identical(keys['en'], keys['en_US']), true);
    expect(identical(keys['ar'], keys['ar_SA']), true);
    Get.locale = const Locale('ar', 'SA');
    expect('home'.tr, 'الرئيسية');
    Get.locale = const Locale('ar', 'EG');
    expect('home'.tr, 'الرئيسية');
    Get.locale = const Locale('en', 'US');
    expect('home'.tr, 'Home');
  });

  test('Placeholders match between languages and substitute in messages', () {
    final pattern = RegExp(r'@([a-zA-Z][a-zA-Z0-9_]*)');
    for (final key in enUs.keys) {
      Set<String> placeholders(String value) =>
          pattern.allMatches(value).map((match) => match.group(1)!).toSet();
      expect(placeholders(arSa[key]!), placeholders(enUs[key]!), reason: key);
    }
    expect('ats_score_out_of'.trParams({'score': '85'}), '85 out of 100');
    Get.locale = const Locale('ar', 'SA');
    expect('ats_score_out_of'.trParams({'score': '85'}), '85 من 100');
  });

  test('All literal translation keys used in lib are defined', () {
    final pattern = RegExp(r"""['"]([a-zA-Z0-9_]+)['"]\.tr\b""");
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))) {
      for (final match in pattern.allMatches(file.readAsStringSync())) {
        expect(
          enUs.containsKey(match.group(1)),
          true,
          reason: '${file.path}: ${match.group(1)}',
        );
      }
    }
  });

  test('Every explicit ATS message and fix key exists in both catalogues', () {
    final source = File(
      'lib/core/services/ats_analyzer_service.dart',
    ).readAsStringSync();
    final pattern = RegExp(r"'((?:ats_issue_|ats_fix_)[a-z_]+)'");
    final keys = pattern
        .allMatches(source)
        .map((match) => match.group(1)!)
        .toSet();
    expect(keys, hasLength(42));
    for (final key in keys) {
      expect(enUs.containsKey(key) && arSa.containsKey(key), true, reason: key);
    }
  });

  test('Source catalogues contain no duplicate keys', () {
    final pattern = RegExp(r"^\s*'([^']+)'\s*:", multiLine: true);
    for (final path in [
      'lib/translations/en_us.dart',
      'lib/translations/ar_sa.dart',
    ]) {
      final keys = pattern
          .allMatches(File(path).readAsStringSync())
          .map((match) => match.group(1)!)
          .toList();
      expect(keys.length, keys.toSet().length, reason: path);
    }
  });

  test('Shared validators resolve messages from the selected catalogue', () {
    expect(Validators.validateEmail(''), enUs['email_required']);
    expect(Validators.validateEmail('valid@example.com'), isNull);
    Get.locale = const Locale('ar', 'SA');
    expect(Validators.validateEmail('wrong'), arSa['invalid_email']);
    expect(Validators.validateRequired('', 'الاسم'), 'الاسم مطلوب');
    expect(Validators.validatePhone('123'), arSa['invalid_phone']);
    expect(Validators.validateUrl('javascript:example'), arSa['invalid_url']);
  });

  test(
    'Relative time uses the requested locale independently of Get locale',
    () {
      final now = DateTime(2026, 10, 23, 12);
      final date = now.subtract(const Duration(hours: 2));
      expect(
        DateFormatter.relativeTime(date, now: now, locale: 'en_US'),
        '2 hours ago',
      );
      expect(
        DateFormatter.relativeTime(date, now: now, locale: 'ar-SA'),
        'منذ 2 ساعة',
      );
      expect(
        DateFormatter.relativeTime(
          now.add(const Duration(minutes: 1)),
          now: now,
        ),
        'In 1 minute',
      );
    },
  );
}
