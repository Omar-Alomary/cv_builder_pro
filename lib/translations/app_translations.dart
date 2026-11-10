import 'package:get/get.dart';
import 'en_us.dart';
import 'ar_sa.dart';

/// Registers both full locale identifiers and language-only fallbacks.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': enUs,
    'en_US': enUs,
    'ar': arSa,
    'ar_SA': arSa,
  };
}
