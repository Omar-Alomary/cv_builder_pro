# Part 2 — الدفعة الثالثة عشرة: المفضلة
هذه الملفات كاملة ومطبقة في المشروع. أزيلت FavoritesScreen القديمة من legacy_app.dart وربط المسار بالشاشة المستقلة. لا تغييرات على الاعتماديات.
تبحث الشاشة بالاسم والبريد والمهارات، وتفتح نسخة مستقلة عند التعديل. الإزالة بعد تأكيد تحدّث التخزين والمفضلة فقط ولا تحذف السيرة، وفشل التخزين يبقي المفضلة كما هي مع رسالة خطأ. توجد حالة فارغة مع إنشاء سيرة وحالة عدم تطابق مع مسح البحث. تدعم البطاقات صورة الملف مع بديل عند تعذر تحميلها.
العرض عمود على الجوال وعمودان على التابلت وثلاثة على سطح المكتب، بارتفاعات مرنة مع النصوص الكبيرة. يدعم RTL/LTR والوضع الليلي والتمرير في الوضع الأفقي.
التحقق: فحص المجلدات المطورة دون ملاحظات، ونجاح 100 اختبار إجمالاً، منها 8 اختبارات جديدة للمفضلة. لم يتم تشغيل التطبيق على جهاز في هذه الدفعة؛ بقية الشاشات القديمة ستنقل في الدفعات القادمة.

## lib/features/favorites/presentation/pages/favorites_screen.dart

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/favorite_card.dart';

/// Searchable favorites that react to persisted changes without copying lists.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _search = TextEditingController();
  bool _confirming = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _remove(ResumeModel resume) async {
    if (_confirming || resume.id == null) return;
    _confirming = true;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.value<double>(
                context: context,
                mobile: 500,
                tablet: 600,
                desktop: 650,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'remove_favorite'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'favorite_remove_confirmation'.trParams({
                      'name': resume.fullName.trim().isEmpty
                          ? 'untitled_resume'.tr
                          : resume.fullName,
                    }),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppButton(
                        label: 'cancel'.tr,
                        variant: AppButtonVariant.text,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      AppButton(
                        key: const ValueKey('confirm-remove-favorite'),
                        label: 'remove_favorite'.tr,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (confirmed == true && mounted) {
        final controller = Get.find<ResumeController>();
        if (controller.getFavoriteResumes().any(
          (item) => item.id == resume.id,
        )) {
          await controller.toggleFavorite(resume.id!);
        }
      }
    } finally {
      _confirming = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr),
        toolbarHeight: 56 + math.max(0, scale - 1) * 30,
      ),
      body: SafeArea(
        child: Responsive.maxWidth(
          child: SingleChildScrollView(
            key: const ValueKey('favorites-scroll'),
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _search,
                  label: 'search_favorites'.tr,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (_) => setState(() {}),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          key: const ValueKey('clear-favorites-search'),
                          tooltip: 'clear_template_search'.tr,
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(_search.clear),
                        ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final favorites = Get.find<ResumeController>()
                      .getFavoriteResumes();
                  final query = _search.text.trim().toLowerCase();
                  final entries = favorites
                      .where(
                        (resume) => [
                          resume.fullName,
                          resume.email,
                          ...resume.skills.map((skill) => skill.name),
                        ].any((text) => text.toLowerCase().contains(query)),
                      )
                      .toList();
                  if (entries.isEmpty) {
                    return AppEmptyState(
                      title:
                          (favorites.isEmpty
                                  ? 'favorites_empty_title'
                                  : 'no_search_results')
                              .tr,
                      description: favorites.isEmpty
                          ? 'favorites_empty_description'.tr
                          : null,
                      icon: Icons.favorite_border,
                      actionLabel:
                          (favorites.isEmpty
                                  ? 'create_resume'
                                  : 'clear_template_search')
                              .tr,
                      onAction: () async {
                        if (favorites.isEmpty) {
                          await Get.toNamed<void>(AppRoutes.resumeBuilder);
                        } else {
                          setState(_search.clear);
                        }
                      },
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = Responsive.value<int>(
                        context: context,
                        mobile: 1,
                        tablet: 2,
                        desktop: 3,
                      );
                      final width =
                          (constraints.maxWidth - 16 * (columns - 1)) / columns;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: entries
                            .map(
                              (resume) => SizedBox(
                                width: width,
                                child: FavoriteCard(
                                  resume: resume,
                                  onEdit: () async {
                                    await Get.toNamed<void>(
                                      AppRoutes.resumeBuilder,
                                      arguments: resume.copyWith(),
                                    );
                                  },
                                  onRemove: () => _remove(resume),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

```

## lib/features/favorites/presentation/widgets/favorite_card.dart

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';

/// Saved favorite with profile fallback and accessible editing actions.
class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.resume,
    required this.onEdit,
    required this.onRemove,
  });
  final ResumeModel resume;
  final Future<void> Function() onEdit;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    final name = resume.fullName.trim().isEmpty
        ? 'untitled_resume'.tr
        : resume.fullName;
    final theme = Theme.of(context);
    final fallback = Icon(
      Icons.person_outline,
      color: theme.colorScheme.primary,
      size: 32,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: resume.profilePicture?.isNotEmpty == true
                          ? Image.file(
                              File(resume.profilePicture!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => fallback,
                            )
                          : fallback,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (resume.email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                resume.email,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'last_saved'.trParams({
                'time': DateFormatter.relativeTime(
                  resume.updatedAt ?? resume.createdAt,
                  locale: Get.locale?.languageCode ?? 'en',
                ),
              }),
              style: theme.textTheme.bodySmall,
            ),
            if (resume.skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: resume.skills
                    .take(3)
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            AppButton(
              key: ValueKey('edit-favorite-${resume.id}'),
              label: 'edit_resume'.tr,
              icon: Icons.edit_outlined,
              fullWidth: true,
              onPressed: onEdit,
            ),
            const SizedBox(height: 8),
            AppButton(
              key: ValueKey('remove-favorite-${resume.id}'),
              label: 'remove_favorite'.tr,
              icon: Icons.favorite,
              variant: AppButtonVariant.outlined,
              fullWidth: true,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

```

## lib/features/favorites/index.dart

```dart
export 'presentation/pages/favorites_screen.dart';
export 'presentation/widgets/favorite_card.dart';

```

## lib/features/index.dart

```dart
export 'splash/index.dart';
export 'language/index.dart';
export 'home/index.dart';
export 'templates/index.dart';
export 'favorites/index.dart';

```

## lib/app/routes/app_pages.dart

```dart
import 'package:get/get.dart';
import '../../legacy_app.dart' as legacy;
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/language/presentation/pages/language_selection_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/templates/presentation/pages/templates_screen.dart';
import '../../features/favorites/presentation/pages/favorites_screen.dart';
import 'app_routes.dart';

/// Registers existing screens during the staged migration.
abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.root, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.templates, page: () => const TemplatesScreen()),
    GetPage(name: AppRoutes.favorites, page: () => const FavoritesScreen()),
    GetPage(
      name: AppRoutes.settings,
      page: () => const legacy.SettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () => const legacy.ResumeBuilderScreen(),
    ),
    GetPage(name: AppRoutes.preview, page: () => const legacy.PreviewScreen()),
  ];
}

```

## lib/translations/en_us.dart

```dart
/// English interface messages.
const Map<String, String> enUs = {
  'home': 'Home',
  'templates': 'Templates',
  'favorites': 'Favorites',
  'settings': 'Settings',
  'save': 'Save',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'edit': 'Edit',
  'next': 'Next',
  'previous': 'Previous',
  'finish': 'Finish',
  'preview': 'Preview',
  'view_all': 'View All',
  'success': 'Success',
  'resume_saved': 'Resume saved successfully',
  'resume_deleted': 'Resume deleted successfully',
  'no_resumes_found': 'No resumes found',
  'no_favorites': 'No favorites yet',
  'browse_templates': 'Browse Templates',
  'create_new': 'Create New',
  'recent_activity': 'Recent Activity',
  'featured_templates': 'Featured Templates',
  'use_template': 'Use Template',
  'personal_info': 'Personal Information',
  'education': 'Education',
  'experience': 'Experience',
  'skills': 'Skills',
  'full_name': 'Full Name',
  'email': 'Email',
  'phone': 'Phone',
  'address': 'Address',
  'summary': 'Professional Summary',
  'degree': 'Degree',
  'institution': 'Institution',
  'graduation_year': 'Graduation Year',
  'grade': 'Grade',
  'add_education': 'Add Education',
  'edit_education': 'Edit Education',
  'no_education_added': 'No education added',
  'degree_required': 'Degree is required',
  'institution_required': 'Institution is required',
  'year_required': 'Graduation year is required',
  'job_title': 'Job Title',
  'company': 'Company',
  'start_date': 'Start Date',
  'end_date': 'End Date',
  'current_job': 'Current Job',
  'description': 'Description',
  'add_experience': 'Add Experience',
  'edit_experience': 'Edit Experience',
  'no_experience_added': 'No experience added',
  'job_title_required': 'Job title is required',
  'company_required': 'Company is required',
  'start_date_required': 'Start date is required',
  'skill_name': 'Skill Name',
  'skill_level': 'Skill Level',
  'add_skill': 'Add Skill',
  'no_skills_added': 'No skills added',
  'language': 'Language',
  'change_app_language': 'Change app language',
  'dark_mode': 'Dark Mode',
  'switch_theme': 'Switch between light and dark theme',
  'contact_us': 'Contact Us',
  'share_app': 'Share App',
  'email_required': 'Email is required',
  'invalid_email': 'Please enter a valid email',
  'phone_required': 'Phone number is required',
  'invalid_phone': 'Please enter a valid phone number',
  'is_required': 'is required',
  'create_resume': 'Create Resume',
  'edit_resume': 'Edit Resume',
  'customize_resume': 'Customize Resume',
  'apply_changes': 'Apply Changes',
  'customization_saved': 'Customization saved successfully',
  'failed_to_generate_preview': 'Failed to generate preview',
  'failed_to_export': 'Failed to export PDF',
  'choose_color': 'Choose Color',
  'preview_updated': 'Preview updated successfully',
  'update_preview': 'Update Preview',
  'courses': 'Courses',
  'certificates': 'Certificates',
  'languages': 'Languages',
  'add_course': 'Add Course',
  'add_certificate': 'Add Certificate',
  'add_language': 'Add Language',
  'course_name': 'Course Name',
  'certificate_name': 'Certificate Name',
  'language_name': 'Language Name',
  'provider': 'Provider',
  'organization': 'Organization',
  'proficiency_level': 'Proficiency Level',
  'no_courses_added': 'No courses added',
  'no_certificates_added': 'No certificates added',
  'no_languages_added': 'No languages added',
  'course_name_required': 'Course name is required',
  'provider_required': 'Provider is required',
  'certificate_name_required': 'Certificate name is required',
  'organization_required': 'Organization is required',
  'language_name_required': 'Language name is required',
  'additional_info': 'Additional Info',
  'projects': 'Projects',
  'achievements': 'Achievements',
  'interests': 'Interests',
  'project_name': 'Project Name',
  'achievement': 'Achievement',
  'no_projects_added': 'No projects added',
  'no_achievements_added': 'No achievements added',
  'no_additional_sections': 'No additional sections available',
  'your_selected_interests': 'Your Selected Interests:',
  'select_interests': 'Select Your Interests',
  'linkedin': 'LinkedIn',
  'github': 'GitHub',
  'website': 'Website',
  'portfolio': 'Portfolio',
  'profile_image_updated': 'Profile image updated successfully',
  'clear_cache': 'Clear Cache',
  'clear_cache_description': 'Remove temporary files and free up space',
  'clear_cache_confirmation': 'Are you sure you want to clear cache?',
  'cache_cleared': 'Cache cleared successfully',
  'cache_clear_failed': 'Failed to clear cache',
  'data': 'Data',
  'about': 'About',
  'app_version': 'App Version',
  'version_1_0_0': 'Version 1.0.0',
  'exit_app': 'Exit App',
  'exit_confirmation': 'Are you sure you want to exit?',
  'exit': 'Exit',
  'yes': 'Yes',
  'no': 'No',
  'logged_out': 'Logged out',
  'come_back_soon': 'We hope to see you again soon!',
  'logout_confirmation': 'Are you sure you want to logout?',
  'professional_resume_builder': 'Professional Resume Builder',
  'appearance': 'Appearance',
  'data_management': 'Data Management',
  'support': 'Support',
  'get_help_support': 'Get help and support',
  'rate_app': 'Rate App',
  'rate_us_on_store': 'Rate us on the store',
  'share_with_friends': 'Share with friends',
  'cannot_open_email': 'Cannot open email client',
  'select_language': 'Select Language',
  'add_project': 'Add Project',
  'edit_project': 'Edit Project',
  'current_project': 'Current Project',
  'technologies_used': 'Technologies Used',
  'add_technology': 'Add Technology',
  'project_name_required': 'Project name is required',
  'description_required': 'Description is required',
  'achievement_name': 'Achievement Name',
  'achievement_name_required': 'Achievement name is required',
  'category': 'Category',
  'date_required': 'Date is required',
  'add_achievement': 'Add Achievement',
  'edit_achievement': 'Edit Achievement',
  'cache_cleared_completely': 'Cache cleared completely',
  'clear_all_data': 'Clear All Data',
  'clear_all_data_confirmation':
      'This will delete ALL your resumes and settings. This action cannot be undone. Are you sure?',
  'clear_all': 'Clear All',
  'all_data_cleared': 'All data cleared successfully',
  'clear_all_data_failed': 'Failed to clear all data',
  'close': 'Close',
  'date': 'Date',
  'year': 'Year',
  'error': 'Error',
  'retry': 'Retry',
  'featured': 'Featured',
  'logout': 'Log out',
  'my_skills': 'My skills',
  'resumes': 'Resumes',
  'edit_certificate': 'Edit certificate',
  'edit_course': 'Edit course',
  'edit_language': 'Edit language',
  'app_name': 'CV Builder Pro',
  'search_templates': 'Search templates',
  'search': 'Search',
  'no_search_results': 'No matching results',
  'search_hint': 'Search by name or description',
  'total_resumes': 'Total resumes',
  'favorite_resumes': 'Favorite resumes',
  'available_templates': 'Available templates',
  'saving': 'Saving…',
  'auto_saved': 'Saved automatically',
  'last_saved': 'Last saved: @time',
  'save_failed': 'Could not save your changes. Try again.',
  'loading': 'Loading…',
  'please_wait': 'Please wait',
  'storage_error':
      'Storage operation failed. Check device storage and try again.',
  'startup_error':
      'Local storage could not be opened. Close and reopen the app. If the problem persists, check storage space and app permissions.',
  'field_required': '@field is required',
  'invalid_url': 'Enter a full http(s) URL',
  'invalid_date': 'Use a valid MM/YYYY date',
  'invalid_date_range': 'The end date must not precede the start date',
  'choose_image': 'Choose image',
  'remove_image': 'Remove image',
  'delete_resume_confirmation': 'Delete this resume?',
  'select_resume': 'Select a resume',
  'import_resume': 'Import resume',
  'export_json': 'Export JSON',
  'export_pdf': 'Export PDF',
  'share_json': 'Share JSON',
  'share_pdf': 'Share PDF',
  'print_pdf': 'Print PDF',
  'import_json': 'Import JSON',
  'import_pdf': 'Import PDF',
  'import_txt': 'Import TXT',
  'recommended': 'Recommended',
  'choose_file': 'Choose file',
  'paste_json': 'Paste JSON',
  'paste_json_hint': 'Paste the complete resume JSON here',
  'json_import_description':
      'Restores all fields from a compatible resume JSON file.',
  'pdf_import_description':
      'Attempts to extract text from supported text-based PDF files. Scanned PDFs require OCR.',
  'txt_import_description':
      'Extracts recognizable contact details and text for review.',
  'import_preview': 'Review imported data',
  'import_loading': 'Reading resume…',
  'import_success': 'Resume imported successfully',
  'import_failed': 'Could not import this file. Check its format and contents.',
  'import_cancelled': 'No file selected',
  'unsupported_file': 'This file type is not supported',
  'file_too_large': 'The file exceeds the 10 MB import limit',
  'invalid_json': 'The JSON structure or field types are invalid',
  'pdf_import_unsupported':
      'Text could not be extracted from this PDF. Try JSON or TXT.',
  'review_before_save':
      'Review and correct the imported information before saving.',
  'save_and_edit': 'Save and edit',
  'export_success': 'Export completed',
  'export_failed': 'Could not export the resume',
  'export_cancelled': 'Export cancelled',
  'export_quality': 'Export quality',
  'quality_standard': 'Standard',
  'quality_high': 'High',
  'customization': 'Customization',
  'font_family': 'Font',
  'font_size': 'Font size',
  'primary_color': 'Primary color',
  'secondary_color': 'Secondary color',
  'ats_checker': 'ATS checker',
  'ats_score': 'ATS score',
  'ats_score_out_of': '@score out of 100',
  'ats_recheck': 'Check again',
  'ats_use_template': 'Use ATS template',
  'ats_edit_resume': 'Go to edit',
  'ats_issues': 'Issues',
  'ats_suggestions': 'Suggestions',
  'ats_missing_keywords': 'Missing keywords',
  'ats_no_issues': 'No issues found by these checks',
  'ats_no_resume': 'Select or create a resume to start the check',
  'ats_checking': 'Analyzing resume…',
  'ats_guidance':
      'This is a rule-based guide, not a guarantee of acceptance by recruiting systems.',
  'ats_formatting_note':
      'Formatting checks use the configured template, not a parsed exported PDF.',
  'ats_template_applied': 'ATS template saved',
  'ats_section_contact': 'Contact',
  'ats_section_summary': 'Summary',
  'ats_section_experience': 'Experience',
  'ats_section_education': 'Education',
  'ats_section_skills': 'Skills',
  'ats_section_keywords': 'Keywords',
  'ats_section_formatting': 'Formatting',
  'ats_severity_critical': 'Critical',
  'ats_severity_warning': 'Warning',
  'ats_severity_info': 'Information',
  'ats_keyword_teamwork': 'teamwork',
  'ats_keyword_leadership': 'leadership',
  'ats_keyword_communication': 'communication',
  'ats_keyword_problem_solving': 'problem-solving',
  'time_just_now': 'Just now',
  'time_ago': '@count @unit ago',
  'time_in': 'In @count @unit',
  'time_minute': 'minute',
  'time_minutes': 'minutes',
  'time_hour': 'hour',
  'time_hours': 'hours',
  'time_day': 'day',
  'time_days': 'days',
  'ats_issue_name': 'The resume has no name.',
  'ats_fix_name': 'Add your full name.',
  'ats_issue_email': 'Email is missing or invalid.',
  'ats_fix_email': 'Add a valid email address.',
  'ats_issue_phone': 'Phone is missing or invalid.',
  'ats_fix_phone': 'Add a valid phone number.',
  'ats_issue_linkedin': 'A valid LinkedIn URL is missing.',
  'ats_fix_linkedin': 'Add your full LinkedIn profile URL.',
  'ats_issue_website': 'A website or portfolio URL is missing.',
  'ats_fix_website': 'Add a relevant website or portfolio URL.',
  'ats_issue_summary_missing': 'Professional summary is missing.',
  'ats_fix_summary_missing': 'Write a concise professional summary.',
  'ats_issue_summary_length': 'Summary length is outside 50–300 characters.',
  'ats_fix_summary_length': 'Keep the summary between 50 and 300 characters.',
  'ats_issue_summary_keywords': 'The summary lacks recognized job keywords.',
  'ats_fix_summary_keywords': 'Include relevant skills in the summary.',
  'ats_issue_experience_missing':
      'No complete work experience entry was found.',
  'ats_fix_experience_missing':
      'Add relevant work, internship or volunteer experience.',
  'ats_issue_experience_actions':
      'Experience descriptions lack recognized action verbs.',
  'ats_fix_experience_actions':
      'Describe achievements with verbs such as developed or led.',
  'ats_issue_experience_dates':
      'Experience dates are missing, invalid or in the future.',
  'ats_fix_experience_dates':
      'Use MM/YYYY dates and mark ongoing positions as current.',
  'ats_issue_education_missing':
      'Education is missing a degree or institution.',
  'ats_fix_education_missing': 'Add your degree and institution.',
  'ats_issue_education_year': 'A valid graduation year is missing.',
  'ats_fix_education_year':
      'Add a four-digit graduation or expected graduation year.',
  'ats_issue_skills_minimum': 'Fewer than five distinct skills were found.',
  'ats_fix_skills_minimum': 'Add at least five relevant distinct skills.',
  'ats_issue_skills_count': 'Fewer than ten distinct skills were found.',
  'ats_fix_skills_count':
      'Add more relevant skills where supported by your experience.',
  'ats_issue_skills_diversity':
      'A mix of recognized technical and interpersonal skills was not found.',
  'ats_fix_skills_diversity':
      'Include both technical and interpersonal skills you actually use.',
  'ats_issue_keywords_missing':
      'Common transferable skill keywords were not found.',
  'ats_fix_keywords_missing':
      'Mention relevant teamwork, leadership, communication or problem-solving experience.',
  'ats_issue_placeholders': 'Placeholder text requiring review was found.',
  'ats_fix_placeholders':
      'Replace placeholder text with your own verified information.',
  'ats_issue_photo': 'The configured output includes a photo.',
  'ats_fix_photo': 'Use the ATS template to omit the photo from the output.',
  'ats_issue_font': 'The selected font is not in the simple-font list.',
  'ats_fix_font': 'Choose Cairo or Poppins, or use the ATS template.',
  'ats_issue_columns':
      'A single-column layout is not confirmed for this configuration.',
  'ats_fix_columns': 'Use the single-column ATS template.',
  'ats_select_resume': 'Select or create a resume before analyzing.',
  'ats_analysis_failed':
      'The resume could not be analyzed. Check its data and try again.',
  'ats_save_failed': 'The ATS template could not be saved.',
  'ats_apply_failed': 'The ATS template could not be applied.',
  'action_failed': 'The action could not be completed. Try again.',
  'splash_tagline': 'Create your professional resume',
  'splash_preparing': 'Getting ready…',
  'language_selection_title': 'Choose your language',
  'language_selection_subtitle':
      'Select your preferred language. You can change it later in settings.',
  'language_english': 'English',
  'language_arabic': 'العربية',
  'country_us': 'United States',
  'country_sa': 'Saudi Arabia',
  'select_english': 'Select English',
  'select_arabic': 'Select Arabic',
  'switch_to_english': 'Use the app in English',
  'switch_to_arabic': 'Use the app in Arabic',
  'home_welcome': 'Welcome back!',
  'home_empty_description': 'Start by creating your first professional resume.',
  'home_templates_description': 'Choose from our professional designs.',
  'home_recent_description': 'Your latest saved resumes and changes.',
  'show_recent': 'Show recent',
  'untitled_resume': 'Untitled resume',
  'no_templates_available': 'No templates are available',
  'template_position': '@current of @total',
  'add_favorite': 'Add to favorites',
  'remove_favorite': 'Remove from favorites',
  'tip_action_verbs': 'Use action verbs to describe your achievements.',
  'tip_tailor_resume': 'Tailor your resume for each job application.',
  'tip_resume_length': 'Keep your resume concise and relevant.',
  'tip_relevant_skills': 'Highlight your most relevant skills and experience.',
  'tip_job_keywords': 'Use relevant keywords from the job description.',
  'clear_template_search': 'Clear search',
  'reset_template_filters': 'Reset filters',
  'template_category_all': 'All',
  'template_category_ats': 'ATS',
  'template_category_business': 'Business',
  'template_category_classic': 'Classic',
  'template_category_modern': 'Modern',
  'template_category_technical': 'Technical',
  'favorite_remove_confirmation':
      'Remove "@name" from favorites? The resume will remain saved.',
  'favorites_empty_description':
      'Add your saved resumes to favorites to find them here.',
  'favorites_empty_title': 'No favorites yet',
  'search_favorites': 'Search favorites',
};

```

## lib/translations/ar_sa.dart

```dart
/// Arabic interface messages.
const Map<String, String> arSa = {
  'home': 'الرئيسية',
  'templates': 'القوالب',
  'favorites': 'المفضلة',
  'settings': 'الإعدادات',
  'save': 'حفظ',
  'cancel': 'إلغاء',
  'delete': 'حذف',
  'edit': 'تعديل',
  'next': 'التالي',
  'previous': 'السابق',
  'finish': 'إنهاء',
  'preview': 'معاينة',
  'view_all': 'عرض الكل',
  'success': 'نجاح',
  'resume_saved': 'تم حفظ السيرة الذاتية بنجاح',
  'resume_deleted': 'تم حذف السيرة الذاتية بنجاح',
  'no_resumes_found': 'لا توجد سير ذاتية',
  'no_favorites': 'لا توجد مفضلات بعد',
  'browse_templates': 'تصفح جميع القوالب',
  'create_new': 'إنشاء سيرة جديدة',
  'recent_activity': 'النشاطات الأخيرة',
  'featured_templates': 'قوالب مميزة',
  'use_template': 'استخدم القالب',
  'personal_info': 'المعلومات الشخصية',
  'education': 'التعليم',
  'experience': 'الخبرات',
  'skills': 'المهارات',
  'full_name': 'الاسم الكامل',
  'email': 'البريد الإلكتروني',
  'phone': 'رقم الهاتف',
  'address': 'العنوان',
  'summary': 'الملخص المهني',
  'degree': 'الشهادة',
  'institution': 'المؤسسة التعليمية',
  'graduation_year': 'سنة التخرج',
  'grade': 'التقدير',
  'add_education': 'إضافة تعليم',
  'edit_education': 'تعديل التعليم',
  'no_education_added': 'لم تتم إضافة تعليم',
  'degree_required': 'الشهادة مطلوبة',
  'institution_required': 'المؤسسة التعليمية مطلوبة',
  'year_required': 'سنة التخرج مطلوبة',
  'job_title': 'المسمى الوظيفي',
  'company': 'الشركة',
  'start_date': 'تاريخ البدء',
  'end_date': 'تاريخ الانتهاء',
  'current_job': 'وظيفة حالية',
  'description': 'الوصف',
  'add_experience': 'إضافة خبرة',
  'edit_experience': 'تعديل الخبرة',
  'no_experience_added': 'لم تتم إضافة خبرات',
  'job_title_required': 'المسمى الوظيفي مطلوب',
  'company_required': 'الشركة مطلوبة',
  'start_date_required': 'تاريخ البدء مطلوب',
  'skill_name': 'اسم المهارة',
  'skill_level': 'المستوى',
  'add_skill': 'إضافة مهارة',
  'no_skills_added': 'لم تتم إضافة مهارات',
  'language': 'اللغة',
  'change_app_language': 'تغيير لغة التطبيق',
  'dark_mode': 'الوضع الليلي',
  'switch_theme': 'التبديل بين الوضع الليلي والنهاري',
  'contact_us': 'اتصل بنا',
  'share_app': 'مشاركة التطبيق',
  'email_required': 'البريد الإلكتروني مطلوب',
  'invalid_email': 'الرجاء إدخال بريد إلكتروني صحيح',
  'phone_required': 'رقم الهاتف مطلوب',
  'invalid_phone': 'الرجاء إدخال رقم هاتف صحيح',
  'is_required': 'مطلوب',
  'create_resume': 'إنشاء سيرة ذاتية',
  'edit_resume': 'تعديل السيرة الذاتية',
  'customize_resume': 'تخصيص السيرة الذاتية',
  'apply_changes': 'تطبيق التغييرات',
  'customization_saved': 'تم حفظ التخصيص بنجاح',
  'failed_to_generate_preview': 'فشل في إنشاء المعاينة',
  'failed_to_export': 'فشل في تصدير PDF',
  'choose_color': 'اختر اللون',
  'preview_updated': 'تم تحديث المعاينة بنجاح',
  'update_preview': 'تحديث المعاينة',
  'courses': 'الدورات التدريبية',
  'certificates': 'الشهادات',
  'languages': 'اللغات',
  'add_course': 'إضافة دورة',
  'add_certificate': 'إضافة شهادة',
  'add_language': 'إضافة لغة',
  'course_name': 'اسم الدورة',
  'certificate_name': 'اسم الشهادة',
  'language_name': 'اسم اللغة',
  'provider': 'مقدم الدورة',
  'organization': 'الجهة المانحة',
  'proficiency_level': 'مستوى الإتقان',
  'no_courses_added': 'لم تتم إضافة دورات',
  'no_certificates_added': 'لم تتم إضافة شهادات',
  'no_languages_added': 'لم تتم إضافة لغات',
  'course_name_required': 'اسم الدورة مطلوب',
  'provider_required': 'مقدم الدورة مطلوب',
  'certificate_name_required': 'اسم الشهادة مطلوب',
  'organization_required': 'الجهة المانحة مطلوبة',
  'language_name_required': 'اسم اللغة مطلوب',
  'additional_info': 'معلومات إضافية',
  'projects': 'المشاريع',
  'achievements': 'الإنجازات',
  'interests': 'الاهتمامات',
  'project_name': 'اسم المشروع',
  'achievement': 'الإنجاز',
  'no_projects_added': 'لم تتم إضافة مشاريع',
  'no_achievements_added': 'لم تتم إضافة إنجازات',
  'no_additional_sections': 'لا توجد أقسام إضافية',
  'your_selected_interests': 'اهتماماتك المختارة:',
  'select_interests': 'اختر اهتماماتك',
  'linkedin': 'لينكد إن',
  'github': 'جيت هاب',
  'website': 'الموقع الإلكتروني',
  'portfolio': 'ملف الأعمال',
  'profile_image_updated': 'تم تحديث صورة الملف الشخصي بنجاح',
  'clear_cache': 'مسح الكاش',
  'clear_cache_description': 'إزالة الملفات المؤقتة وتحرير المساحة',
  'clear_cache_confirmation': 'هل أنت متأكد من مسح الكاش؟',
  'cache_cleared': 'تم مسح الكاش بنجاح',
  'cache_clear_failed': 'فشل في مسح الكاش',
  'data': 'البيانات',
  'about': 'حول التطبيق',
  'app_version': 'إصدار التطبيق',
  'version_1_0_0': 'الإصدار 1.0.0',
  'exit_app': 'الخروج من التطبيق',
  'exit_confirmation': 'هل أنت متأكد من الخروج من التطبيق؟',
  'exit': 'خروج',
  'yes': 'نعم',
  'no': 'لا',
  'logged_out': 'تم تسجيل الخروج',
  'come_back_soon': 'نتمنى رؤيتك مرة أخرى قريباً!',
  'logout_confirmation': 'هل أنت متأكد من تسجيل الخروج؟',
  'professional_resume_builder': 'منشئ السير الذاتية الاحترافي',
  'appearance': 'المظهر',
  'data_management': 'إدارة البيانات',
  'support': 'الدعم',
  'get_help_support': 'احصل على المساعدة والدعم',
  'rate_app': 'تقييم التطبيق',
  'rate_us_on_store': 'قيمنا في المتجر',
  'share_with_friends': 'شارك مع الأصدقاء',
  'cannot_open_email': 'لا يمكن فتح بريد إلكتروني',
  'select_language': 'اختر لغتك المفضلة',
  'add_project': 'إضافة مشروع',
  'edit_project': 'تعديل مشروع',
  'current_project': 'مشروع حالي',
  'technologies_used': 'التقنيات المستخدمة',
  'add_technology': 'إضافة تقنية',
  'project_name_required': 'اسم المشروع مطلوب',
  'description_required': 'الوصف مطلوب',
  'achievement_name': 'اسم الإنجاز',
  'achievement_name_required': 'اسم الإنجاز مطلوب',
  'category': 'التصنيف',
  'date_required': 'التاريخ مطلوب',
  'add_achievement': 'إضافة إنجاز',
  'edit_achievement': 'تعديل إنجاز',
  'cache_cleared_completely': 'تم مسح الكاش بالكامل',
  'clear_all_data': 'مسح جميع البيانات',
  'clear_all_data_confirmation':
      'سيؤدي هذا إلى حذف جميع سيرك الذاتية وإعداداتك. هذا الإجراء لا يمكن التراجع عنه. هل أنت متأكد؟',
  'clear_all': 'مسح الكل',
  'all_data_cleared': 'تم مسح جميع البيانات بنجاح',
  'clear_all_data_failed': 'فشل في مسح جميع البيانات',
  'close': 'إغلاق',
  'date': 'التاريخ',
  'year': 'السنة',
  'error': 'خطأ',
  'retry': 'إعادة المحاولة',
  'featured': 'مميز',
  'logout': 'تسجيل الخروج',
  'my_skills': 'مهاراتي',
  'resumes': 'السير الذاتية',
  'edit_certificate': 'تعديل الشهادة',
  'edit_course': 'تعديل الدورة',
  'edit_language': 'تعديل اللغة',
  'app_name': 'CV Builder Pro',
  'search_templates': 'البحث في القوالب',
  'search': 'بحث',
  'no_search_results': 'لا توجد نتائج مطابقة',
  'search_hint': 'ابحث بالاسم أو الوصف',
  'total_resumes': 'إجمالي السير',
  'favorite_resumes': 'السير المفضلة',
  'available_templates': 'القوالب المتاحة',
  'saving': 'جارٍ الحفظ…',
  'auto_saved': 'تم الحفظ تلقائياً',
  'last_saved': 'آخر حفظ: @time',
  'save_failed': 'تعذر حفظ التغييرات. أعد المحاولة.',
  'loading': 'جارٍ التحميل…',
  'please_wait': 'يرجى الانتظار',
  'storage_error': 'تعذرت عملية التخزين. تحقق من مساحة الجهاز وأعد المحاولة.',
  'startup_error':
      'تعذر فتح التخزين المحلي. أغلق التطبيق ثم أعد تشغيله. إذا استمرت المشكلة، تحقق من مساحة التخزين وصلاحيات التطبيق.',
  'field_required': '@field مطلوب',
  'invalid_url': 'أدخل رابطاً كاملاً يبدأ بـ http أو https',
  'invalid_date': 'استخدم تاريخاً صالحاً بصيغة MM/YYYY',
  'invalid_date_range': 'يجب ألا يسبق تاريخ الانتهاء تاريخ البدء',
  'choose_image': 'اختيار صورة',
  'remove_image': 'إزالة الصورة',
  'delete_resume_confirmation': 'هل تريد حذف هذه السيرة؟',
  'select_resume': 'اختر سيرة ذاتية',
  'import_resume': 'استيراد سيرة',
  'export_json': 'تصدير JSON',
  'export_pdf': 'تصدير PDF',
  'share_json': 'مشاركة JSON',
  'share_pdf': 'مشاركة PDF',
  'print_pdf': 'طباعة PDF',
  'import_json': 'استيراد JSON',
  'import_pdf': 'استيراد PDF',
  'import_txt': 'استيراد TXT',
  'recommended': 'موصى به',
  'choose_file': 'اختيار ملف',
  'paste_json': 'لصق JSON',
  'paste_json_hint': 'الصق بيانات السيرة بصيغة JSON هنا',
  'json_import_description': 'يستعيد جميع الحقول من ملف JSON متوافق للسيرة.',
  'pdf_import_description':
      'يحاول استخراج النص من ملفات PDF النصية المدعومة. الملفات الممسوحة ضوئياً تحتاج إلى OCR.',
  'txt_import_description':
      'يستخرج بيانات الاتصال والنصوص التي يمكن التعرف عليها لمراجعتها.',
  'import_preview': 'مراجعة البيانات المستوردة',
  'import_loading': 'جارٍ قراءة السيرة…',
  'import_success': 'تم استيراد السيرة بنجاح',
  'import_failed': 'تعذر استيراد الملف. تحقق من صيغته ومحتواه.',
  'import_cancelled': 'لم يتم اختيار ملف',
  'unsupported_file': 'نوع الملف غير مدعوم',
  'file_too_large': 'يتجاوز الملف حد الاستيراد البالغ 10 ميجابايت',
  'invalid_json': 'بنية JSON أو أنواع الحقول غير صالحة',
  'pdf_import_unsupported':
      'تعذر استخراج النص من ملف PDF هذا. جرّب JSON أو TXT.',
  'review_before_save': 'راجع المعلومات المستوردة وصححها قبل الحفظ.',
  'save_and_edit': 'حفظ وتعديل',
  'export_success': 'اكتمل التصدير',
  'export_failed': 'تعذر تصدير السيرة',
  'export_cancelled': 'تم إلغاء التصدير',
  'export_quality': 'جودة التصدير',
  'quality_standard': 'قياسية',
  'quality_high': 'عالية',
  'customization': 'التخصيص',
  'font_family': 'الخط',
  'font_size': 'حجم الخط',
  'primary_color': 'اللون الرئيسي',
  'secondary_color': 'اللون الثانوي',
  'ats_checker': 'فحص ATS',
  'ats_score': 'نتيجة ATS',
  'ats_score_out_of': '@score من 100',
  'ats_recheck': 'إعادة الفحص',
  'ats_use_template': 'استخدام قالب ATS',
  'ats_edit_resume': 'انتقل للتعديل',
  'ats_issues': 'الملاحظات',
  'ats_suggestions': 'الاقتراحات',
  'ats_missing_keywords': 'الكلمات المفتاحية المفقودة',
  'ats_no_issues': 'لم تُكتشف ملاحظات وفق هذه القواعد',
  'ats_no_resume': 'اختر سيرة أو أنشئ سيرة لبدء الفحص',
  'ats_checking': 'جارٍ تحليل السيرة…',
  'ats_guidance':
      'هذا تقييم إرشادي قائم على قواعد، ولا يضمن القبول لدى أنظمة التوظيف.',
  'ats_formatting_note':
      'يعتمد فحص التنسيق على إعداد القالب، وليس على تحليل ملف PDF مصدّر.',
  'ats_template_applied': 'تم حفظ قالب ATS',
  'ats_section_contact': 'بيانات الاتصال',
  'ats_section_summary': 'الملخص المهني',
  'ats_section_experience': 'الخبرة',
  'ats_section_education': 'التعليم',
  'ats_section_skills': 'المهارات',
  'ats_section_keywords': 'الكلمات المفتاحية',
  'ats_section_formatting': 'التنسيق',
  'ats_severity_critical': 'حرجة',
  'ats_severity_warning': 'تنبيه',
  'ats_severity_info': 'معلومة',
  'ats_keyword_teamwork': 'العمل الجماعي',
  'ats_keyword_leadership': 'القيادة',
  'ats_keyword_communication': 'التواصل',
  'ats_keyword_problem_solving': 'حل المشكلات',
  'time_just_now': 'الآن',
  'time_ago': 'منذ @count @unit',
  'time_in': 'خلال @count @unit',
  'time_minute': 'دقيقة',
  'time_minutes': 'دقيقة',
  'time_hour': 'ساعة',
  'time_hours': 'ساعة',
  'time_day': 'يوم',
  'time_days': 'يوم',
  'ats_issue_name': 'السيرة لا تحتوي على اسم.',
  'ats_fix_name': 'أضف اسمك الكامل.',
  'ats_issue_email': 'البريد الإلكتروني مفقود أو غير صالح.',
  'ats_fix_email': 'أضف بريداً إلكترونياً صالحاً.',
  'ats_issue_phone': 'رقم الهاتف مفقود أو غير صالح.',
  'ats_fix_phone': 'أضف رقم هاتف صالحاً.',
  'ats_issue_linkedin': 'رابط LinkedIn صالح مفقود.',
  'ats_fix_linkedin': 'أضف رابط ملفك الكامل في LinkedIn.',
  'ats_issue_website': 'رابط الموقع أو معرض الأعمال مفقود.',
  'ats_fix_website': 'أضف رابط موقع أو معرض أعمال مناسب.',
  'ats_issue_summary_missing': 'الملخص المهني مفقود.',
  'ats_fix_summary_missing': 'اكتب ملخصاً مهنياً موجزاً.',
  'ats_issue_summary_length': 'طول الملخص خارج نطاق 50–300 حرف.',
  'ats_fix_summary_length': 'اجعل الملخص بين 50 و300 حرف.',
  'ats_issue_summary_keywords': 'الملخص يفتقر إلى كلمات وظيفية معروفة.',
  'ats_fix_summary_keywords': 'اذكر المهارات المرتبطة بالوظيفة في الملخص.',
  'ats_issue_experience_missing': 'لا توجد خبرة بمسمى وظيفي وشركة.',
  'ats_fix_experience_missing': 'أضف خبرة عمل أو تدريب أو تطوع مناسبة.',
  'ats_issue_experience_actions': 'أوصاف الخبرة تفتقر إلى أفعال إنجاز معروفة.',
  'ats_fix_experience_actions': 'صف إنجازاتك بأفعال مثل طورت أو قدت.',
  'ats_issue_experience_dates':
      'تواريخ الخبرة مفقودة أو غير مرتبة أو مستقبلية.',
  'ats_fix_experience_dates': 'استخدم MM/YYYY وحدد الوظائف المستمرة كعمل حالي.',
  'ats_issue_education_missing': 'التعليم يفتقر إلى المؤهل أو المؤسسة.',
  'ats_fix_education_missing': 'أضف المؤهل والمؤسسة التعليمية.',
  'ats_issue_education_year': 'سنة تخرج صالحة مفقودة.',
  'ats_fix_education_year': 'أضف سنة التخرج أو التخرج المتوقع بأربعة أرقام.',
  'ats_issue_skills_minimum': 'عدد المهارات المختلفة أقل من خمس.',
  'ats_fix_skills_minimum': 'أضف خمس مهارات مختلفة مرتبطة بالوظيفة على الأقل.',
  'ats_issue_skills_count': 'عدد المهارات المختلفة أقل من عشر.',
  'ats_fix_skills_count': 'أضف مهارات مناسبة إضافية تدعمها خبرتك.',
  'ats_issue_skills_diversity':
      'لم يظهر مزيج من المهارات التقنية والشخصية المعروفة.',
  'ats_fix_skills_diversity': 'اذكر مهارات تقنية وشخصية تستخدمها فعلياً.',
  'ats_issue_keywords_missing': 'لم تظهر كلمات المهارات العامة المعروفة.',
  'ats_fix_keywords_missing':
      'اذكر خبرة مناسبة في العمل الجماعي أو القيادة أو التواصل أو حل المشكلات.',
  'ats_issue_placeholders': 'ظهر نص تجريبي يحتاج إلى مراجعة.',
  'ats_fix_placeholders': 'استبدل النصوص التجريبية بمعلوماتك الصحيحة.',
  'ats_issue_photo': 'الإخراج المحدد يتضمن صورة.',
  'ats_fix_photo': 'استخدم قالب ATS لاستبعاد الصورة من الإخراج.',
  'ats_issue_font': 'الخط المحدد خارج قائمة الخطوط البسيطة.',
  'ats_fix_font': 'اختر Cairo أو Poppins أو استخدم قالب ATS.',
  'ats_issue_columns': 'لم يُعتمد تخطيط بعمود واحد لهذا الإعداد.',
  'ats_fix_columns': 'استخدم قالب ATS ذي العمود الواحد.',
  'ats_select_resume': 'اختر سيرة أو أنشئ سيرة قبل الفحص.',
  'ats_analysis_failed': 'تعذر تحليل السيرة. راجع بياناتها وأعد المحاولة.',
  'ats_save_failed': 'تعذر حفظ قالب ATS.',
  'ats_apply_failed': 'تعذر تطبيق قالب ATS.',
  'action_failed': 'تعذر إكمال العملية. أعد المحاولة.',
  'splash_tagline': 'أنشئ سيرتك الذاتية الاحترافية',
  'splash_preparing': 'جارٍ التجهيز…',
  'language_selection_title': 'اختر لغتك',
  'language_selection_subtitle':
      'اختر اللغة التي تفضلها. يمكنك تغييرها لاحقاً من الإعدادات.',
  'language_english': 'English',
  'language_arabic': 'العربية',
  'country_us': 'الولايات المتحدة',
  'country_sa': 'السعودية',
  'select_english': 'اختيار الإنجليزية',
  'select_arabic': 'اختيار العربية',
  'switch_to_english': 'استخدم التطبيق باللغة الإنجليزية',
  'switch_to_arabic': 'استخدم التطبيق باللغة العربية',
  'home_welcome': 'مرحباً بك!',
  'home_empty_description': 'ابدأ بإنشاء أول سيرة ذاتية احترافية لك.',
  'home_templates_description': 'اختر من تصاميمنا الاحترافية.',
  'home_recent_description': 'آخر السير الذاتية المحفوظة والتغييرات.',
  'show_recent': 'عرض الأحدث',
  'untitled_resume': 'سيرة بدون اسم',
  'no_templates_available': 'لا توجد قوالب متاحة',
  'template_position': '@current من @total',
  'add_favorite': 'إضافة إلى المفضلة',
  'remove_favorite': 'إزالة من المفضلة',
  'tip_action_verbs': 'استخدم أفعالاً قوية لوصف إنجازاتك.',
  'tip_tailor_resume': 'خصص سيرتك الذاتية لكل وظيفة تتقدم لها.',
  'tip_resume_length': 'اجعل سيرتك الذاتية موجزة ومرتبطة بالوظيفة.',
  'tip_relevant_skills': 'ركز على المهارات والخبرات الأكثر صلة بالوظيفة.',
  'tip_job_keywords': 'استخدم الكلمات المفتاحية المناسبة من وصف الوظيفة.',
  'clear_template_search': 'مسح البحث',
  'reset_template_filters': 'إعادة ضبط الفلاتر',
  'template_category_all': 'الكل',
  'template_category_ats': 'ATS',
  'template_category_business': 'أعمال',
  'template_category_classic': 'كلاسيكي',
  'template_category_modern': 'عصري',
  'template_category_technical': 'تقني',
  'favorite_remove_confirmation':
      'هل تريد إزالة «@name» من المفضلة؟ ستبقى السيرة محفوظة.',
  'favorites_empty_description': 'أضف سيرك المحفوظة إلى المفضلة لتظهر هنا.',
  'favorites_empty_title': 'لا توجد مفضلات بعد',
  'search_favorites': 'البحث في المفضلة',
};

```

## test/favorites/favorites_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/favorites/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final entries = [
    ResumeModel(
      id: 1,
      fullName: 'Alice',
      email: 'alice@example.com',
      isFavorite: true,
      skills: [
        Skill(name: 'Flutter'),
        Skill(name: 'Communication'),
      ],
    ),
    ResumeModel(
      id: 2,
      fullName: 'عمر',
      email: 'omer@example.com',
      isFavorite: true,
      skills: [Skill(name: 'Dart')],
    ),
    ResumeModel(id: 3, fullName: 'Hidden', isFavorite: false),
  ];
  bool failSave = false;
  @override
  List<ResumeModel> loadResumes() =>
      entries.map((item) => item.copyWith()).toList();
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (failSave) throw Exception('disk failure');
    entries[entries.indexWhere((item) => item.id == resume.id)] = resume
        .copyWith();
    return resume.copyWith();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget host({
  double scale = 1,
  bool arabic = false,
  void Function(Object?)? capture,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: arabic ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: const FavoritesScreen(),
  getPages: [
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () {
        capture?.call(Get.arguments);
        return const Scaffold(body: Text('builder-marker'));
      },
    ),
  ],
);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  // The awaited confirmation keeps the initiating button busy behind the dialog.
  await tester.pump(const Duration(milliseconds: 400));
  if (find.byType(Dialog).evaluate().isEmpty) {
    await tester.pumpAndSettle();
  }
}

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 800.0, 1920.0]) {
    testWidgets('favorites fit width $width and Arabic large text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      Get.put(ResumeController(repository: _Repository()));
      await tester.pumpWidget(host(scale: 2, arabic: true));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const ValueKey('favorites-scroll')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FavoriteCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'search matches name email and skill and clear restores favorites',
    (tester) async {
      Get.put(ResumeController(repository: _Repository()));
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      for (final query in [' ALICE ', 'example.com', 'dart', 'عمر']) {
        await tester.enterText(find.byType(TextFormField), query);
        await tester.pumpAndSettle();
        expect(
          find.byType(FavoriteCard),
          findsNWidgets(query == 'example.com' ? 2 : 1),
        );
      }
      await tester.enterText(find.byType(TextFormField), 'missing');
      await tester.pumpAndSettle();
      expect(find.text('no_search_results'.tr), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('clear-favorites-search')));
      await tester.pumpAndSettle();
      expect(find.byType(FavoriteCard), findsNWidgets(2));
    },
  );
  testWidgets('editing passes an isolated draft', (tester) async {
    final controller = Get.put(ResumeController(repository: _Repository()));
    ResumeModel? draft;
    await tester.pumpWidget(
      host(capture: (value) => draft = value as ResumeModel),
    );
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('edit-favorite-1')));
    expect(draft!.id, 1);
    draft!.fullName = 'Changed';
    draft!.skills.clear();
    expect(controller.resumes.first.fullName, 'Alice');
    expect(controller.resumes.first.skills, isNotEmpty);
  });
  testWidgets(
    'cancel preserves favorite and confirm persists removal without deleting resume',
    (tester) async {
      final repository = _Repository();
      final controller = Get.put(ResumeController(repository: repository));
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const ValueKey('remove-favorite-1')));
      await tester.tap(find.text('cancel'.tr));
      await tester.pumpAndSettle();
      expect(controller.getFavoriteResumes(), hasLength(2));
      await tapVisible(tester, find.byKey(const ValueKey('remove-favorite-1')));
      await tester.tap(find.byKey(const ValueKey('confirm-remove-favorite')));
      await tester.pumpAndSettle();
      expect(controller.getFavoriteResumes(), hasLength(1));
      expect(controller.resumes, hasLength(3));
      expect(repository.entries.first.isFavorite, isFalse);
      expect(find.byKey(const ValueKey('remove-favorite-1')), findsNothing);
    },
  );
  testWidgets('failed save retains favorite', (tester) async {
    final repository = _Repository()..failSave = true;
    final controller = Get.put(ResumeController(repository: repository));
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('remove-favorite-1')));
    await tester.tap(find.byKey(const ValueKey('confirm-remove-favorite')));
    await tester.pumpAndSettle();
    expect(controller.getFavoriteResumes(), hasLength(2));
    expect(repository.entries.first.isFavorite, isTrue);
  });
  testWidgets('empty favorites creates a new resume', (tester) async {
    final repository = _Repository()..entries.clear();
    Get.put(ResumeController(repository: repository));
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('favorites_empty_title'.tr), findsOneWidget);
    await tapVisible(tester, find.text('create_resume'.tr));
    expect(find.text('builder-marker'), findsOneWidget);
  });
}

```
