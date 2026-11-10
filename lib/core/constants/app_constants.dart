/// Application-wide limits and metadata.
abstract final class AppConstants {
  static const appName = 'CV Maker Pro';
  static const supportedLanguageCodes = ['ar', 'en'];
  static const defaultTemplateId = 'modern';
  static const templateIds = [
    'modern',
    'classic',
    'business',
    'technical',
    'ats',
    'modern_en',
    'classic_en',
    'business_en',
    'technical_en',
    'ats_en',
  ];
  static String templateType(String id) =>
      id.endsWith('_en') ? id.substring(0, id.length - 3) : id;
  static String documentLocale(String id, String fallback) =>
      id.endsWith('_en') ? 'en' : fallback;
  static const autoSaveDelay = Duration(milliseconds: 800);
  static const maxImportBytes = 10 * 1024 * 1024;
  static const schemaVersion = 1;
}
