import 'package:get/get.dart';
import '../data/models/template_model.dart';
import '../data/models/template_fields.dart';

/// Manages template metadata and visible resume sections.
class TemplateController extends GetxController {
  final RxList<TemplateModel> templates = <TemplateModel>[].obs;

  final Map<String, TemplateFields> templateConfig = {
    'modern': TemplateFields(
      showProfilePicture: true,
      showSummary: true,
      showAddress: true,
      showLinkedin: true,
      showGithub: true,
      showPortfolio: true,
      showWebsite: false,
      showProjects: false,
      showAchievements: true,
      showInterests: true,
      showCourses: true,
      showCertificates: true,
      showLanguages: true,
    ),
    'classic': TemplateFields(
      showProfilePicture: true,
      showSummary: true,
      showAddress: true,
      showLinkedin: true,
      showGithub: false,
      showPortfolio: false,
      showWebsite: true,
      showProjects: false,
      showAchievements: true,
      showInterests: false,
      showCourses: false,
      showCertificates: false,
      showLanguages: false,
    ),
    'business': TemplateFields(
      showProfilePicture: true,
      showSummary: true,
      showAddress: true,
      showLinkedin: true,
      showGithub: false,
      showPortfolio: false,
      showWebsite: true,
      showProjects: false,
      showAchievements: true,
      showInterests: false,
      showCourses: false,
      showCertificates: true,
      showLanguages: true,
    ),
    'technical': TemplateFields(
      showProfilePicture: true,
      showSummary: true,
      showAddress: true,
      showLinkedin: true,
      showGithub: true,
      showPortfolio: true,
      showWebsite: false,
      showProjects: true,
      showAchievements: false,
      showInterests: false,
      showCourses: true,
      showCertificates: true,
      showLanguages: false,
    ),
    'ats': TemplateFields(
      showProfilePicture: false,
      showSummary: true,
      showAddress: true,
      showLinkedin: true,
      showGithub: true,
      showPortfolio: true,
      showWebsite: true,
      showProjects: true,
      showAchievements: true,
      showInterests: true,
      showCourses: true,
      showCertificates: true,
      showLanguages: true,
    ),
  };

  TemplateFields getFieldsForTemplate(String templateId) {
    final template = getTemplateById(templateId);
    return templateConfig[template?.type ?? templateId] ??
        templateConfig['classic']!;
  }

  bool showProfilePicture(String templateId) {
    return getFieldsForTemplate(templateId).showProfilePicture;
  }

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  void loadTemplates() {
    final arabic = <TemplateModel>[
      TemplateModel(
        id: 'modern',
        previewImage: 'assets/templates/modern.png',
        name: 'Modern Template',
        nameAr: 'قالب عصري',
        description: 'Clean and modern design with timeline layout',
        descriptionAr: 'تصميم نظيف وعصري مع تخطيط زمني',
        type: 'modern',
        previewColor: '#2196F3',
        icon: '✨',
        language: 'ar',
        isFeatured: true,
      ),
      TemplateModel(
        id: 'classic',
        previewImage: 'assets/templates/classic.png',
        name: 'Classic Template',
        nameAr: 'قالب كلاسيكي',
        description: 'Traditional elegant design for professionals',
        descriptionAr: 'تصميم تقليدي أنيق للمحترفين',
        type: 'classic',
        previewColor: '#4CAF50',
        icon: '🏛️',
        language: 'ar',
        isFeatured: true,
      ),
      TemplateModel(
        id: 'business',
        previewImage: 'assets/templates/business.png',
        name: 'Business Template',
        nameAr: 'قالب أعمال',
        description: 'Professional design for corporate careers',
        descriptionAr: 'تصميم احترافي للمسار الوظيفي',
        type: 'business',
        previewColor: '#FF9800',
        icon: '📊',
        language: 'ar',
        isFeatured: true,
      ),
      TemplateModel(
        id: 'technical',
        previewImage: 'assets/templates/technical.png',
        name: 'Technical',
        nameAr: 'تقني',
        description: 'Focus on skills and projects',
        descriptionAr: 'تأكيد على المهارات والمشاريع',
        type: 'technical',
        previewColor: '#E91E63',
        icon: '⚙️',
        language: 'ar',
        isFeatured: true,
      ),
      TemplateModel(
        id: 'ats',
        previewImage: 'assets/templates/ats.png',
        name: 'ATS-Friendly',
        nameAr: 'قالب ATS',
        description: 'Simple design for ATS systems',
        descriptionAr: 'مُحسّن لأنظمة تتبع المتقدمين',
        type: 'ats',
        icon: '🤖',
        previewColor: '#9C27B0',
        language: 'ar',
        isFeatured: true,
      ),
    ];
    templates.assignAll([
      ...arabic,
      for (final template in arabic)
        TemplateModel(
          id: '${template.id}_en',
          name: template.name,
          nameAr: template.nameAr,
          description: template.description,
          descriptionAr: template.descriptionAr,
          type: template.type,
          language: 'en',
          icon: template.icon,
          previewImage: 'assets/templates/${template.id}_en.png',
          previewColor: template.previewColor,
          isFeatured: template.isFeatured,
        ),
    ]);
  }

  List<TemplateModel> getFeaturedTemplates() {
    return templates.where((t) => t.isFeatured).toList();
  }

  List<TemplateModel> searchTemplates(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return templates.toList();
    return templates
        .where(
          (template) => [
            template.name,
            template.nameAr,
            template.description,
            template.descriptionAr,
            template.type,
          ].any((text) => text.toLowerCase().contains(normalized)),
        )
        .toList();
  }

  TemplateModel? getTemplateById(String id) {
    return templates.firstWhereOrNull((t) => t.id == id);
  }
}
