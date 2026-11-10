# UI/UX — Batch 9: Import + Entry Dialogs
اكتملت إعادة تصميم الاستيراد ونوافذ إدخال أقسام السيرة ضمن طبقة العرض. لم تتغير خدمات قراءة JSON/PDF/TXT أو قواعد التحقق أو النماذج أو المتحكمات أو المستودع أو الترجمات أو الاعتماديات.
بطاقات الاستيراد: JSON مع أيقونة بيانات وشارة توصية خضراء وزر اختيار متدرج أخضر، وPDF مع شارة تنبيه ووصف القيود الأصلي، وTXT مع أيقونة نص. العناوين أصبحت أسماء التنسيقات المختصرة، ونقلت التوصية والتنبيه إلى شارات مرئية. تستخدم البطاقات AppCard وألواناً مناسبة للوضعين وأزراراً بأيقونة رفع، وتظل خدمة اختيار الملف نفسها فعالة. بقيت إمكانية لصق JSON ومعاينته كما هي.
المعاينة: بطاقة من النظام الجديد مع عنوان وشرح وصورة رمزية بديلة واسم وبريد وأعداد الأقسام ومحرر JSON الكامل وزري الحفظ والإلغاء. النص الملخص يعكس السيرة المستوردة الأصلية، بينما يُعاد تحليل محتوى المحرر عند الحفظ وفق السلوك القائم. بقي تصفير المعرف الأجنبي ومسار الصورة والمفضلة وإنشاء نسخة مستقلة قبل فتح البناء دون تغيير. يظل فشل الحفظ محتفظاً بالمعاينة القابلة للتحرير.
الانتظار: ImportLoadingWidget داخل بطاقة AppCard ويستخدم AppLoading المشترك، مع الحركة أو بديلها الثابت حسب الإعداد. تبقى جميع بطاقات اختيار الملفات معطلة أثناء انتظار الاختيار والقراءة، وتتفعّل مجدداً عند الإلغاء أو اكتمال العملية. لا توجد أزرار صورية أو خدمة استيراد بديلة في التطبيق.
النوافذ السبع: التعليم والخبرة والدورات والشهادات واللغات والمشاريع والإنجازات. يستخدم الجميع ResumeFormDialog بزوايا 24 وأيقونة القسم وعنوان مرن، وحقول AppTextField ومسافات موحدة، وزر حفظ متدرج بأيقونة وزر إلغاء بإطار. بقيت حدود العرض 500/600/650 والتمرير واحتساب مساحة لوحة المفاتيح عبر Dialog الأصلي. بقيت القيم الاختيارية والتواريخ والتحقق وتبديل الوظيفة/المشروع الحالي ومستويات اللغة وإرجاع النموذج عند الحفظ دون تغيير.
التحقق: flutter analyze دون ملاحظات، وجميع اختبارات المشروع الـ559 ناجحة، ومنها الاختبارات السابقة الـ47 للاستيراد والتحرير والإلغاء والحفظ. عُدلت محددات زر الإلغاء في ثلاثة ملفات اختبار من TextButton إلى AppButton بسبب تغير مظهره إلى إطار؛ بقيت تأكيدات الإلغاء وسلامة البيانات نفسها. أضيفت 41 حالة: 20 للاستيراد ومعاينته و20 تمر بالنوافذ السبع مع مساحة لوحة مفاتيح محاكاة 280 وتكبير النص 200%، وحالة انتظار اختيار الملف ومنع تكراره. تشمل عروض 320/390/600/1024/1920 واللغتين والوضعين؛ عرض 1024 يستخدم ارتفاعاً أفقياً 480.
راجعت معاينات الجوال وسطح المكتب بخطوط التطبيق. تعرض صور النوافذ نموذج التعليم منفرداً فوق خلفية اختبار بسيطة. خدمات اختيار الملفات والتخزين بدائل اختبار في اختبارات الواجهة؛ لم يُكرر اختيار ملف أو تشغيل على جهاز فعلي في هذه الدفعة. لا تغير في قيود استيراد PDF التي يوضحها الوصف القائم.
## المعاينات
[import — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_import_light_en_390.png)
[import — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_import_light_en_1920.png)
[import — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_import_dark_ar_390.png)
[import — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_import_dark_ar_1920.png)
[import_preview — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_import_preview_light_en_390.png)
[import_preview — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_import_preview_light_en_1920.png)
[import_preview — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_import_preview_dark_ar_390.png)
[import_preview — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_import_preview_dark_ar_1920.png)
[education_dialog — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_education_dialog_light_en_390.png)
[education_dialog — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_education_dialog_light_en_1920.png)
[education_dialog — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_education_dialog_dark_ar_390.png)
[education_dialog — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_09_education_dialog_dark_ar_1920.png)
## الملفات كاملة
1. lib/features/import_resume/presentation/pages/import_resume_screen.dart
2. lib/features/import_resume/presentation/widgets/import_option_card.dart
3. lib/features/import_resume/presentation/widgets/import_preview_widget.dart
4. lib/features/import_resume/presentation/widgets/import_loading_widget.dart
5. lib/features/resume_builder/presentation/widgets/resume_form_dialog.dart
6. lib/features/resume_builder/presentation/dialogs/achievement_dialog.dart
7. lib/features/resume_builder/presentation/dialogs/certificate_dialog.dart
8. lib/features/resume_builder/presentation/dialogs/course_dialog.dart
9. lib/features/resume_builder/presentation/dialogs/education_dialog.dart
10. lib/features/resume_builder/presentation/dialogs/experience_dialog.dart
11. lib/features/resume_builder/presentation/dialogs/language_dialog.dart
12. lib/features/resume_builder/presentation/dialogs/project_dialog.dart
13. test/resume_builder/entries_test.dart
14. test/resume_builder/additional_entries_test.dart
15. test/resume_builder/projects_achievements_interests_test.dart
16. test/import_resume/redesign_import_dialogs_test.dart

## lib/features/import_resume/presentation/pages/import_resume_screen.dart
```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/services/resume_import_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/import_option_card.dart';
import '../widgets/import_preview_widget.dart';
import '../widgets/import_loading_widget.dart';

/// Picks a file or accepts pasted JSON, previews it, and saves an isolated copy.
class ImportResumeScreen extends StatefulWidget {
  const ImportResumeScreen({super.key, this.service});
  final ResumeImportService? service;
  @override
  State<ImportResumeScreen> createState() => _ImportResumeScreenState();
}

class _ImportResumeScreenState extends State<ImportResumeScreen> {
  late final _service = widget.service ?? ResumeImportService();
  final _paste = TextEditingController();
  final _previewKey = GlobalKey();
  ResumeModel? _resume;
  bool _loading = false;
  @override
  void dispose() {
    _paste.dispose();
    super.dispose();
  }

  void _preview(ResumeModel resume) {
    setState(() => _resume = resume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _previewKey.currentContext;
      if (mounted && context != null) {
        Scrollable.ensureVisible(context, alignment: 0);
      }
    });
  }

  Future<void> _pick(String extension) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final resume = await _service.pickAndImport(extension);
      if (resume != null && mounted) _preview(resume);
    } on ImportException catch (error) {
      if (mounted) AppSnackbar.error(context, error.messageKey.tr);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'import_read_failed'.tr);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(ResumeModel resume) async {
    // Foreign IDs and local image paths must not overwrite or access local data.
    final copy = resume.copyWith(
      id: null,
      profilePicture: null,
      createdAt: DateTime.now(),
      updatedAt: null,
      isFavorite: false,
    );
    final saved = await Get.find<ResumeController>().saveResume(copy);
    if (saved && mounted) {
      Get.offNamed<void>(AppRoutes.resumeBuilder, arguments: copy.copyWith());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Scaffold(
      appBar: AppBar(
        title: Text('import_resume'.tr),
        toolbarHeight:
            AppSpacing.touchTarget +
            AppSpacing.sm +
            math.max(0, scale - 1) * AppSpacing.xxl,
      ),
      body: SafeArea(
        child: Responsive.maxWidth(
          child: SingleChildScrollView(
            key: const ValueKey('import-scroll'),
            padding: Responsive.pagePadding(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final options = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final format in ['json', 'pdf', 'txt'])
                      ImportOptionCard(
                        key: ValueKey('import-option-$format'),
                        title: format.toUpperCase(),
                        badgeLabel: format == 'json'
                            ? 'recommended'.tr
                            : format == 'pdf'
                            ? 'ats_severity_warning'.tr
                            : null,
                        recommended: format == 'json',
                        warning: format == 'pdf',
                        description: 'import_${format}_description'.tr,
                        icon: format == 'pdf'
                            ? Icons.picture_as_pdf_outlined
                            : format == 'json'
                            ? Icons.data_object
                            : Icons.text_snippet_outlined,
                        actionLabel: 'import_select_file'.trParams({
                          'format': format.toUpperCase(),
                        }),
                        onSelect: _loading ? null : () => _pick(format),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      key: const ValueKey('paste-resume-json'),
                      controller: _paste,
                      label: 'import_paste_json'.tr,
                      maxLines: 7,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.multiline,
                      enabled: !_loading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: const ValueKey('parse-pasted-json'),
                      label: 'import_preview'.tr,
                      icon: Icons.manage_search_outlined,
                      fullWidth: true,
                      onPressed: _loading
                          ? null
                          : () {
                              try {
                                _preview(_service.fromJsonText(_paste.text));
                              } on ImportException catch (error) {
                                AppSnackbar.error(context, error.messageKey.tr);
                              }
                            },
                    ),
                  ],
                );
                final preview = Column(
                  key: _previewKey,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_loading) const ImportLoadingWidget(),
                    if (_resume != null)
                      ImportPreviewWidget(
                        key: ObjectKey(_resume),
                        resume: _resume!,
                        onSave: _save,
                        onDiscard: () => setState(() => _resume = null),
                      )
                    else if (!_loading)
                      AppEmptyState(
                        title: 'import_preview_empty'.tr,
                        description: 'import_preview_empty_description'.tr,
                        icon: Icons.upload_file,
                      ),
                  ],
                );
                if (Responsive.isTabletOrLarger(context)) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: options),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(child: preview),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    options,
                    const SizedBox(height: AppSpacing.xl),
                    preview,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

```

## lib/features/import_resume/presentation/widgets/import_option_card.dart
```dart
import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// File format card with recommendation or warning and a working picker action.
class ImportOptionCard extends StatelessWidget {
  const ImportOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.actionLabel,
    required this.onSelect,
    this.badgeLabel,
    this.recommended = false,
    this.warning = false,
  });
  final String title, description, actionLabel;
  final IconData icon;
  final Future<void> Function()? onSelect;
  final String? badgeLabel;
  final bool recommended, warning;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = recommended
        ? dark
              ? AppColors.secondaryLight
              : AppColors.successForeground
        : warning
        ? dark
              ? AppColors.accent
              : AppColors.warningForeground
        : scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(icon, color: color, size: AppSpacing.xl),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.resolve(context, AppTextStyles.h4),
                      ),
                      if (badgeLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .12),
                            borderRadius: AppRadii.chip,
                          ),
                          child: Text(
                            badgeLabel!,
                            style: AppTextStyles.resolve(
                              context,
                              AppTextStyles.caption,
                            ).copyWith(color: color),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.bodySmall,
              ).copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: actionLabel,
              icon: Icons.upload_file_outlined,
              fullWidth: true,
              variant: recommended
                  ? AppButtonVariant.primary
                  : AppButtonVariant.secondary,
              gradient: recommended ? AppColors.successGradient : null,
              onPressed: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}

```

## lib/features/import_resume/presentation/widgets/import_preview_widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/resume_import_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/index.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Editable full-schema JSON preview that validates before saving a new resume.
class ImportPreviewWidget extends StatefulWidget {
  const ImportPreviewWidget({
    super.key,
    required this.resume,
    required this.onSave,
    required this.onDiscard,
  });
  final ResumeModel resume;
  final Future<void> Function(ResumeModel) onSave;
  final VoidCallback onDiscard;
  @override
  State<ImportPreviewWidget> createState() => _ImportPreviewWidgetState();
}

class _ImportPreviewWidgetState extends State<ImportPreviewWidget> {
  late final _json = TextEditingController(
    text: ResumeJson.encode(widget.resume),
  );
  @override
  void dispose() {
    _json.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            title: 'import_preview'.tr,
            subtitle: 'import_preview_description'.tr,
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppAvatar(
              name: widget.resume.fullName,
              size: AppSpacing.xxxl,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.resume.fullName.isEmpty
                ? 'untitled_resume'.tr
                : widget.resume.fullName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (widget.resume.email.isNotEmpty)
            Text(widget.resume.email, textDirection: TextDirection.ltr),
          Text(
            'import_section_counts'.trParams({
              'education': '${widget.resume.education.length}',
              'experience': '${widget.resume.experience.length}',
              'skills': '${widget.resume.skills.length}',
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('import-preview-json'),
            controller: _json,
            label: 'import_edit_json'.tr,
            maxLines: 16,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            key: const ValueKey('save-imported-resume'),
            label: 'import_save_edit'.tr,
            icon: Icons.save_outlined,
            fullWidth: true,
            onPressed: () async {
              try {
                final resume = ResumeImportService().fromJsonText(_json.text);
                if (resume.fullName.trim().isEmpty) {
                  AppSnackbar.warning(context, 'import_name_required'.tr);
                  return;
                }
                await widget.onSave(resume);
              } on ImportException catch (error) {
                if (context.mounted) {
                  AppSnackbar.error(context, error.messageKey.tr);
                }
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'import_discard'.tr,
            onPressed: widget.onDiscard,
            fullWidth: true,
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    ),
  );
}

```

## lib/features/import_resume/presentation/widgets/import_loading_widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared_widgets/index.dart';
import '../../../../app/theme/index.dart';

/// Shared animated loading feedback during file selection and decoding.
class ImportLoadingWidget extends StatelessWidget {
  const ImportLoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: AppLoading(message: 'import_loading'.tr),
    ),
  );
}

```

## lib/features/resume_builder/presentation/widgets/resume_form_dialog.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/index.dart';

/// Keyboard-aware editor dialog with an icon header and reachable form actions.
class ResumeFormDialog extends StatelessWidget {
  const ResumeFormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
    this.icon = Icons.edit_note_outlined,
  });
  final String title;
  final Widget child;
  final VoidCallback onSave;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.dialog),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: ConstrainedBox(
        key: const ValueKey('resume-form-dialog-surface'),
        constraints: BoxConstraints(
          maxWidth: Responsive.value<double>(
            context: context,
            mobile: 500,
            tablet: 600,
            desktop: 650,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Icon(
                        icon,
                        color: scheme.primary,
                        size: AppSpacing.xl,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: AppTextStyles.resolve(context, AppTextStyles.h4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              child,
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                key: const ValueKey('save-resume-entry'),
                label: 'save'.tr,
                icon: Icons.check,
                fullWidth: true,
                onPressed: onSave,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'cancel'.tr,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

## lib/features/resume_builder/presentation/dialogs/achievement_dialog.dart
```dart
import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/achievement.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits all achievement fields, including imported custom categories.
class AchievementDialog extends StatefulWidget {
  const AchievementDialog({super.key, this.achievement});
  final Achievement? achievement;
  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.achievement?.name ?? '',
  );
  late final _description = TextEditingController(
    text: widget.achievement?.description ?? '',
  );
  late final _date = TextEditingController(
    text: widget.achievement?.date ?? '',
  );
  late final _organization = TextEditingController(
    text: widget.achievement?.organization ?? '',
  );
  late final _category = TextEditingController(
    text: widget.achievement?.category ?? '',
  );
  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Achievement(
        name: _name.text.trim(),
        description: _description.text.trim(),
        date: DateFormatter.monthYear(
          DateFormatter.parseMonthYear(_date.text)!,
        ),
        organization: _optional(_organization.text),
        category: _optional(_category.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.emoji_events_outlined,
    title: (widget.achievement == null ? 'add_achievement' : 'edit_achievement')
        .tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('achievement-name'),
            controller: _name,
            label: 'achievement_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'achievement_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('achievement-category'),
            controller: _category,
            label: 'category'.tr,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('achievement-organization'),
            controller: _organization,
            label: 'organization'.tr,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('achievement-date'),
            controller: _date,
            label: 'date'.tr,
            hint: 'MM/YYYY',
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.datetime,
            validator: Validators.validateMonthYear,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('achievement-description'),
            controller: _description,
            label: 'description'.tr,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            validator: (value) =>
                Validators.validateRequired(value, 'description'.tr),
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [
      _name,
      _description,
      _date,
      _organization,
      _category,
    ]) {
      control.dispose();
    }
    super.dispose();
  }
}

```

## lib/features/resume_builder/presentation/dialogs/certificate_dialog.dart
```dart
import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/certificate.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits every certificate field in isolation until the user saves.
class CertificateDialog extends StatefulWidget {
  const CertificateDialog({super.key, this.certificate});
  final Certificate? certificate;
  @override
  State<CertificateDialog> createState() => _CertificateDialogState();
}

class _CertificateDialogState extends State<CertificateDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.certificate?.name ?? '',
  );
  late final _organization = TextEditingController(
    text: widget.certificate?.organization ?? '',
  );
  late final _year = TextEditingController(
    text: widget.certificate?.year ?? '',
  );
  late final _credentialId = TextEditingController(
    text: widget.certificate?.credentialId ?? '',
  );
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Certificate(
        name: _name.text.trim(),
        organization: _organization.text.trim(),
        year: DateFormatter.normalizeDigits(_year.text.trim()),
        credentialId: (_credentialId.text.trim().isEmpty
            ? null
            : _credentialId.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.verified_outlined,
    title: (widget.certificate == null ? 'add_certificate' : 'edit_certificate')
        .tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('certificate-name'),
            controller: _name,
            label: 'certificate_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'certificate_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('certificate-organization'),
            controller: _organization,
            label: 'organization'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'organization'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('certificate-year'),
            controller: _year,
            label: 'year'.tr,
            validator: Validators.validateYear,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            hint: 'YYYY',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('certificate-credentialId'),
            controller: _credentialId,
            label: 'builder_credential_id'.tr,
            validator: null,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [_name, _organization, _year, _credentialId]) {
      control.dispose();
    }
    super.dispose();
  }
}

```

## lib/features/resume_builder/presentation/dialogs/course_dialog.dart
```dart
import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/course.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits every course field in isolation until the user saves.
class CourseDialog extends StatefulWidget {
  const CourseDialog({super.key, this.course});
  final Course? course;
  @override
  State<CourseDialog> createState() => _CourseDialogState();
}

class _CourseDialogState extends State<CourseDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.course?.name ?? '');
  late final _provider = TextEditingController(
    text: widget.course?.provider ?? '',
  );
  late final _year = TextEditingController(text: widget.course?.year ?? '');
  late final _certificateUrl = TextEditingController(
    text: widget.course?.certificateUrl ?? '',
  );
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Course(
        name: _name.text.trim(),
        provider: _provider.text.trim(),
        year: DateFormatter.normalizeDigits(_year.text.trim()),
        certificateUrl: (_certificateUrl.text.trim().isEmpty
            ? null
            : _certificateUrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.menu_book_outlined,
    title: (widget.course == null ? 'add_course' : 'edit_course').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('course-name'),
            controller: _name,
            label: 'course_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'course_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('course-provider'),
            controller: _provider,
            label: 'provider'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'provider'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('course-year'),
            controller: _year,
            label: 'year'.tr,
            validator: Validators.validateYear,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            hint: 'YYYY',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('course-certificateUrl'),
            controller: _certificateUrl,
            label: 'builder_certificate_url'.tr,
            validator: Validators.validateUrl,
            keyboardType: TextInputType.url,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [_name, _provider, _year, _certificateUrl]) {
      control.dispose();
    }
    super.dispose();
  }
}

```

## lib/features/resume_builder/presentation/dialogs/education_dialog.dart
```dart
import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/education.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits all education fields without changing the source until confirmed.
class EducationDialog extends StatefulWidget {
  const EducationDialog({super.key, this.education});
  final Education? education;
  @override
  State<EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<EducationDialog> {
  final _form = GlobalKey<FormState>();
  late final _degree = TextEditingController(
    text: widget.education?.degree ?? '',
  );
  late final _institution = TextEditingController(
    text: widget.education?.institution ?? '',
  );
  late final _year = TextEditingController(text: widget.education?.year ?? '');
  late final _grade = TextEditingController(
    text: widget.education?.grade ?? '',
  );
  late final _description = TextEditingController(
    text: widget.education?.description ?? '',
  );
  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Education(
        degree: _degree.text.trim(),
        institution: _institution.text.trim(),
        year: DateFormatter.normalizeDigits(_year.text.trim()),
        grade: _optional(_grade.text),
        description: _optional(_description.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.school_outlined,
    title: (widget.education == null ? 'add_education' : 'edit_education').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('education-degree'),
            controller: _degree,
            label: 'degree'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'degree'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('education-institution'),
            controller: _institution,
            label: 'institution'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'institution'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('education-year'),
            controller: _year,
            label: 'graduation_year'.tr,
            hint: 'YYYY',
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            validator: Validators.validateYear,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('education-grade'),
            controller: _grade,
            label: 'grade'.tr,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('education-description'),
            controller: _description,
            label: 'description'.tr,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [
      _degree,
      _institution,
      _year,
      _grade,
      _description,
    ]) {
      control.dispose();
    }
    super.dispose();
  }
}

```

## lib/features/resume_builder/presentation/dialogs/experience_dialog.dart
```dart
import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/experience.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Validates chronological month/year dates and preserves current employment.
class ExperienceDialog extends StatefulWidget {
  const ExperienceDialog({super.key, this.experience});
  final Experience? experience;
  @override
  State<ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<ExperienceDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: widget.experience?.jobTitle ?? '',
  );
  late final _company = TextEditingController(
    text: widget.experience?.company ?? '',
  );
  late final _start = TextEditingController(
    text: widget.experience?.startDate ?? '',
  );
  late final _end = TextEditingController(
    text: widget.experience?.endDate ?? '',
  );
  late final _description = TextEditingController(
    text: widget.experience?.description ?? '',
  );
  late bool _current = widget.experience?.isCurrent ?? false;
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Experience(
        jobTitle: _title.text.trim(),
        company: _company.text.trim(),
        startDate: DateFormatter.monthYear(
          DateFormatter.parseMonthYear(_start.text)!,
        ),
        endDate: _current
            ? null
            : DateFormatter.monthYear(DateFormatter.parseMonthYear(_end.text)!),
        isCurrent: _current,
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.work_outline,
    title:
        (widget.experience == null ? 'add_experience' : 'edit_experience').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('experience-title'),
            controller: _title,
            label: 'job_title'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'job_title'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('experience-company'),
            controller: _company,
            label: 'company'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'company'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('experience-start'),
            controller: _start,
            label: 'start_date'.tr,
            hint: 'MM/YYYY',
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.datetime,
            validator: Validators.validateMonthYear,
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            key: const ValueKey('experience-current'),
            contentPadding: EdgeInsets.zero,
            title: Text('current_job'.tr),
            value: _current,
            onChanged: (value) => setState(() => _current = value ?? false),
          ),
          if (!_current) ...[
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              key: const ValueKey('experience-end'),
              controller: _end,
              label: 'end_date'.tr,
              hint: 'MM/YYYY',
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.datetime,
              validator: (value) =>
                  Validators.validateEndDate(value, startDate: _start.text),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('experience-description'),
            controller: _description,
            label: 'description'.tr,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [_title, _company, _start, _end, _description]) {
      control.dispose();
    }
    super.dispose();
  }
}

```

## lib/features/resume_builder/presentation/dialogs/language_dialog.dart
```dart
import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/language.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits language proficiency while retaining imported custom levels.
class ResumeLanguageDialog extends StatefulWidget {
  const ResumeLanguageDialog({super.key, this.language});
  final Language? language;
  static const levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Fluent',
    'Native',
  ];
  static String levelLabel(String level) => levels.contains(level)
      ? 'builder_language_${level.toLowerCase()}'.tr
      : level;
  @override
  State<ResumeLanguageDialog> createState() => _ResumeLanguageDialogState();
}

class _ResumeLanguageDialogState extends State<ResumeLanguageDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.language?.name ?? '');
  late String _level = widget.language?.level ?? 'Intermediate';
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(Language(name: _name.text.trim(), level: _level));
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.translate,
    title: (widget.language == null ? 'add_language' : 'edit_language').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            key: const ValueKey('language-name'),
            controller: _name,
            label: 'language_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'language_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('proficiency_level'.tr),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final level in {...ResumeLanguageDialog.levels, _level})
                ChoiceChip(
                  key: ValueKey('language-level-$level'),
                  label: Text(ResumeLanguageDialog.levelLabel(level)),
                  selected: _level == level,
                  onSelected: (_) => setState(() => _level = level),
                ),
            ],
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }
}

```

## lib/features/resume_builder/presentation/dialogs/project_dialog.dart
```dart
import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/project.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits project dates, current status, description and technologies in isolation.
class ProjectDialog extends StatefulWidget {
  const ProjectDialog({super.key, this.project});
  final Project? project;
  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.project?.name ?? '');
  late final _technologies = TextEditingController(
    text: widget.project?.technologies.join('\n') ?? '',
  );
  late final _start = TextEditingController(
    text: widget.project?.startDate ?? '',
  );
  late final _end = TextEditingController(text: widget.project?.endDate ?? '');
  late final _description = TextEditingController(
    text: widget.project?.description ?? '',
  );
  late bool _current = widget.project?.isCurrent ?? false;
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Project(
        name: _title.text.trim(),
        technologies: _technologies.text
            .split('\n')
            .map((v) => v.trim())
            .where((v) => v.isNotEmpty)
            .toList(),
        startDate: DateFormatter.monthYear(
          DateFormatter.parseMonthYear(_start.text)!,
        ),
        endDate: _current
            ? null
            : DateFormatter.monthYear(DateFormatter.parseMonthYear(_end.text)!),
        isCurrent: _current,
        description: _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.code,
    title: (widget.project == null ? 'add_project' : 'edit_project').tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('project-title'),
            controller: _title,
            label: 'project_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'project_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('project-start'),
            controller: _start,
            label: 'start_date'.tr,
            hint: 'MM/YYYY',
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.datetime,
            validator: Validators.validateMonthYear,
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            key: const ValueKey('project-current'),
            contentPadding: EdgeInsets.zero,
            title: Text('current_project'.tr),
            value: _current,
            onChanged: (value) => setState(() => _current = value ?? false),
          ),
          if (!_current) ...[
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              key: const ValueKey('project-end'),
              controller: _end,
              label: 'end_date'.tr,
              hint: 'MM/YYYY',
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.datetime,
              validator: (value) =>
                  Validators.validateEndDate(value, startDate: _start.text),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('project-description'),
            controller: _description,
            label: 'description'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'description'.tr),
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('project-technologies'),
            controller: _technologies,
            label: 'technologies_used'.tr,
            helperText: 'builder_technology_lines'.tr,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [_title, _technologies, _start, _end, _description]) {
      control.dispose();
    }
    super.dispose();
  }
}

```

## test/resume_builder/entries_test.dart
```dart
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ResumeController _prepare() {
  final resumes = Get.put(ResumeController(repository: _Repository()));
  resumes.currentResume.value = ResumeModel(fullName: 'Draft');
  return resumes;
}

Widget _host(Widget child, {double scale = 1, bool arabic = false}) =>
    GetMaterialApp(
      locale: Locale(arabic ? 'ar' : 'en'),
      translations: AppTranslations(),
      theme: arabic ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: child,
            ),
          ),
        ),
      ),
    );
Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextFormField),
);
Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String value) async {
  final target = _field(key);
  await tester.ensureVisible(target);
  await tester.enterText(target, value);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 800.0, 1920.0]) {
    for (final kind in ['education', 'experience', 'skills']) {
      testWidgets('$kind fits $width with Arabic large text', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final resumes = _prepare();
        resumes.currentResume.value!.education.add(
          Education(
            degree: 'بكالوريوس طويل في هندسة البرمجيات',
            institution: 'جامعة طويلة الاسم',
            year: '2024',
            description: 'وصف الشهادة',
          ),
        );
        resumes.currentResume.value!.experience.add(
          Experience(
            jobTitle: 'مهندس برمجيات ذو خبرة',
            company: 'شركة تقنية',
            startDate: '01/2024',
            isCurrent: true,
            description: 'تطوير تطبيقات وحلول برمجية.',
          ),
        );
        resumes.currentResume.value!.skills.add(
          Skill(name: 'مهارة طويلة في تطوير البرمجيات'),
        );
        await tester.pumpWidget(
          _host(
            switch (kind) {
              'education' => const EducationStep(),
              'experience' => const ExperienceStep(),
              _ => const SkillsStep(),
            },
            scale: 2,
            arabic: true,
          ),
        );
        await tester.pumpAndSettle();
        if (kind != 'skills') {
          await _tap(tester, 'add-$kind');
          await tester.ensureVisible(
            find.byKey(const ValueKey('save-resume-entry')),
          );
          await tester.pumpAndSettle();
          expect(
            tester
                .getSize(
                  find.byKey(const ValueKey('resume-form-dialog-surface')),
                )
                .width,
            lessThanOrEqualTo(
              width < 600
                  ? 500
                  : width < 1200
                  ? 600
                  : 650,
            ),
          );
        } else {
          await tester.ensureVisible(
            find.byKey(const ValueKey('delete-skill-0')),
          );
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('education add cancel edit and delete preserve descriptions', (
    tester,
  ) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const EducationStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-education');
    for (final entry in {
      'education-degree': 'BSc',
      'education-institution': 'University',
      'education-year': '٢٠٢٤',
      'education-grade': 'A',
      'education-description': 'Keep this description',
    }.entries) {
      await _type(tester, entry.key, entry.value);
    }
    await _tap(tester, 'save-resume-entry');
    expect(resumes.currentResume.value!.education.single.year, '2024');
    await _tap(tester, 'edit-education-0');
    await _type(tester, 'education-description', 'Cancelled edit');
    final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(
      resumes.currentResume.value!.education.single.description,
      'Keep this description',
    );
    await _tap(tester, 'edit-education-0');
    await _type(tester, 'education-degree', 'MSc');
    await _tap(tester, 'save-resume-entry');
    expect(resumes.currentResume.value!.education.single.degree, 'MSc');
    expect(
      resumes.currentResume.value!.education.single.description,
      'Keep this description',
    );
    await _tap(tester, 'delete-education-0');
    expect(resumes.currentResume.value!.education, isEmpty);
    expect(find.text('no_education_added'.tr), findsOneWidget);
  });
  testWidgets('education requires fields and a valid year', (tester) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const EducationStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-education');
    await _tap(tester, 'save-resume-entry');
    expect(resumes.currentResume.value!.education, isEmpty);
    await _type(tester, 'education-degree', 'BSc');
    await _type(tester, 'education-institution', 'University');
    await _type(tester, 'education-year', '20xx');
    await _tap(tester, 'save-resume-entry');
    expect(find.text('builder_invalid_year'.tr), findsOneWidget);
    expect(resumes.currentResume.value!.education, isEmpty);
  });
  testWidgets('experience add current job edit and delete retain description', (
    tester,
  ) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const ExperienceStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-experience');
    for (final entry in {
      'experience-title': 'Developer',
      'experience-company': 'Company',
      'experience-start': '١/٢٠٢٤',
      'experience-end': '12/2024',
      'experience-description': 'Developed applications',
    }.entries) {
      await _type(tester, entry.key, entry.value);
    }
    await _tap(tester, 'save-resume-entry');
    expect(resumes.currentResume.value!.experience.single.startDate, '01/2024');
    await _tap(tester, 'edit-experience-0');
    await _tap(tester, 'experience-current');
    expect(_field('experience-end'), findsNothing);
    await _type(tester, 'experience-title', 'Lead');
    await _tap(tester, 'save-resume-entry');
    final saved = resumes.currentResume.value!.experience.single;
    expect(saved.isCurrent, true);
    expect(saved.endDate, isNull);
    expect(saved.description, 'Developed applications');
    await _tap(tester, 'delete-experience-0');
    expect(resumes.currentResume.value!.experience, isEmpty);
  });
  testWidgets('invalid date range and future dates do not commit', (
    tester,
  ) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const ExperienceStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-experience');
    for (final entry in {
      'experience-title': 'Developer',
      'experience-company': 'Company',
      'experience-start': '02/2024',
      'experience-end': '01/2024',
    }.entries) {
      await _type(tester, entry.key, entry.value);
    }
    await _tap(tester, 'save-resume-entry');
    expect(find.text('invalid_date_range'.tr), findsOneWidget);
    await _type(tester, 'experience-end', '01/2099');
    await _tap(tester, 'save-resume-entry');
    expect(find.text('builder_future_date'.tr), findsOneWidget);
    await _type(tester, 'experience-start', '13/2024');
    await _tap(tester, 'save-resume-entry');
    expect(find.text('invalid_date'.tr), findsOneWidget);
    expect(resumes.currentResume.value!.experience, isEmpty);
  });
  testWidgets('skills add edit duplicate prevention cancel and delete', (
    tester,
  ) async {
    final resumes = _prepare();
    await tester.pumpWidget(_host(const SkillsStep()));
    await tester.pumpAndSettle();
    await _type(tester, 'skill-name', ' Flutter ');
    await tester.drag(
      find.byKey(const ValueKey('skill-level')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();
    await _tap(tester, 'save-skill');
    expect(resumes.currentResume.value!.skills.single.name, 'Flutter');
    expect(resumes.currentResume.value!.skills.single.level, 5);
    await _type(tester, 'skill-name', 'FLUTTER');
    await _tap(tester, 'save-skill');
    expect(find.text('builder_skill_duplicate'.tr), findsOneWidget);
    expect(resumes.currentResume.value!.skills, hasLength(1));
    await _tap(tester, 'edit-skill-0');
    await _type(tester, 'skill-name', 'Flutter Pro');
    await _tap(tester, 'save-skill');
    expect(resumes.currentResume.value!.skills.single.name, 'Flutter Pro');
    await _tap(tester, 'edit-skill-0');
    await _type(tester, 'skill-name', 'Cancelled');
    await _tap(tester, 'cancel-skill-edit');
    expect(resumes.currentResume.value!.skills.single.name, 'Flutter Pro');
    await _tap(tester, 'delete-skill-0');
    expect(resumes.currentResume.value!.skills, isEmpty);
  });
  testWidgets('editing a skill cannot overwrite a different selected resume', (
    tester,
  ) async {
    final resumes = _prepare();
    resumes.currentResume.value!.skills.add(Skill(name: 'Original'));
    await tester.pumpWidget(_host(const SkillsStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'edit-skill-0');
    resumes.currentResume.value = ResumeModel(
      skills: [Skill(name: 'Other resume')],
    );
    await tester.pumpAndSettle();
    await _tap(tester, 'save-skill');
    expect(find.text('builder_entry_changed'.tr), findsOneWidget);
    expect(resumes.currentResume.value!.skills.single.name, 'Other resume');
  });
}

```

## test/resume_builder/additional_entries_test.dart
```dart
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ResumeController _prepare() {
  final resumes = Get.put(ResumeController(repository: _Repository()));
  resumes.currentResume.value = ResumeModel(fullName: 'Draft');
  return resumes;
}

Widget _host(Widget child, {double scale = 1, bool arabic = false}) =>
    GetMaterialApp(
      locale: Locale(arabic ? 'ar' : 'en'),
      translations: AppTranslations(),
      theme: arabic ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: child,
            ),
          ),
        ),
      ),
    );
Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextFormField),
);
Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String value) async {
  final target = _field(key);
  await tester.ensureVisible(target);
  await tester.enterText(target, value);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  for (final kind in ['course', 'certificate', 'language']) {
    testWidgets('$kind CRUD preserves optional fields and cancels edits', (
      tester,
    ) async {
      final resumes = _prepare();
      await tester.pumpWidget(
        _host(switch (kind) {
          'course' => const CoursesStep(),
          'certificate' => const CertificatesStep(),
          _ => const LanguagesStep(),
        }),
      );
      await tester.pumpAndSettle();
      await _tap(tester, 'add-${kind}s');
      await _tap(tester, 'save-resume-entry');
      expect(find.byType(ResumeFormDialog), findsOneWidget);
      await _type(tester, '$kind-name', 'First');
      if (kind != 'language') {
        await _type(
          tester,
          kind == 'course' ? 'course-provider' : 'certificate-organization',
          'Provider',
        );
        await _type(tester, '$kind-year', '٢٠٢٤');
        await _type(
          tester,
          kind == 'course'
              ? 'course-certificateUrl'
              : 'certificate-credentialId',
          kind == 'course' ? 'https://example.com/cert' : 'ABC-123',
        );
      }
      await _tap(tester, 'save-resume-entry');
      expect(find.byType(ResumeFormDialog), findsNothing);
      final resume = resumes.currentResume.value!;
      if (kind == 'course') expect(resume.courses.single.year, '2024');
      if (kind == 'language') {
        resume.languages.single.level = 'CEFR C1';
        resumes.currentResume.refresh();
        await tester.pumpAndSettle();
      }
      await _tap(tester, 'edit-$kind-0');
      await _type(tester, '$kind-name', 'Changed');
      await _tap(tester, 'save-resume-entry');
      if (kind == 'course') {
        expect(resume.courses.single.name, 'Changed');
        expect(
          resume.courses.single.certificateUrl,
          'https://example.com/cert',
        );
      }
      if (kind == 'certificate') {
        expect(resume.certificates.single.name, 'Changed');
        expect(resume.certificates.single.credentialId, 'ABC-123');
      }
      if (kind == 'language') {
        expect(resume.languages.single.name, 'Changed');
        expect(resume.languages.single.level, 'CEFR C1');
      }
      await _tap(tester, 'edit-$kind-0');
      await _type(tester, '$kind-name', 'Discard');
      final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(find.text('Discard'), findsNothing);
      expect(find.text('Changed'), findsOneWidget);
      await _tap(tester, 'delete-$kind-0');
      expect(find.byType(ResumeEntryCard), findsNothing);
    });
  }
  testWidgets('course validates URL and year', (tester) async {
    _prepare();
    await tester.pumpWidget(_host(const CoursesStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-courses');
    await _type(tester, 'course-name', 'Flutter');
    await _type(tester, 'course-provider', 'School');
    await _type(tester, 'course-year', 'wrong');
    await _type(tester, 'course-certificateUrl', 'javascript:alert(1)');
    await _tap(tester, 'save-resume-entry');
    expect(find.byType(CourseDialog), findsOneWidget);
    await _type(tester, 'course-year', '2024');
    await _tap(tester, 'save-resume-entry');
    expect(find.byType(CourseDialog), findsOneWidget);
    await _type(tester, 'course-certificateUrl', 'https://example.com');
    await _tap(tester, 'save-resume-entry');
    expect(find.byType(CourseDialog), findsNothing);
  });
  for (final width in [320.0, 800.0, 1920.0]) {
    for (final kind in ['courses', 'certificates', 'languages']) {
      testWidgets('$kind Arabic scaled text at $width', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final r = _prepare().currentResume.value!;
        r.courses.add(
          Course(
            name: 'دورة طويلة في هندسة البرمجيات',
            provider: 'معهد التدريب والتطوير',
            year: '2024',
            certificateUrl: 'https://example.com/long/certificate',
          ),
        );
        r.certificates.add(
          Certificate(
            name: 'شهادة معتمدة في إدارة المشاريع',
            organization: 'منظمة الاختبارات والتطوير',
            year: '2024',
            credentialId: 'ABC-123',
          ),
        );
        r.languages.add(Language(name: 'اللغة العربية', level: 'CEFR C1'));
        await tester.pumpWidget(
          _host(
            switch (kind) {
              'courses' => const CoursesStep(),
              'certificates' => const CertificatesStep(),
              _ => const LanguagesStep(),
            },
            scale: 2,
            arabic: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _tap(tester, 'add-$kind');
        expect(tester.takeException(), isNull);
        final surface = find.byKey(
          const ValueKey('resume-form-dialog-surface'),
        );
        expect(
          tester.getSize(surface).width,
          lessThanOrEqualTo(
            width < 600
                ? 500
                : width < 1200
                ? 600
                : 650,
          ),
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('save-resume-entry')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}

```

## test/resume_builder/projects_achievements_interests_test.dart
```dart
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ResumeController _prepare() {
  final resumes = Get.put(ResumeController(repository: _Repository()));
  resumes.currentResume.value = ResumeModel(fullName: 'Draft');
  return resumes;
}

Widget _host(Widget child, {double scale = 1, bool arabic = false}) =>
    GetMaterialApp(
      locale: Locale(arabic ? 'ar' : 'en'),
      translations: AppTranslations(),
      theme: arabic ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: child,
            ),
          ),
        ),
      ),
    );
Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextFormField),
);
Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String value) async {
  final target = _field(key);
  await tester.ensureVisible(target);
  await tester.enterText(target, value);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  testWidgets('project validates range, edits all fields and cancels safely', (
    tester,
  ) async {
    final r = _prepare().currentResume.value!;
    await tester.pumpWidget(_host(const ProjectsStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-projects');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects, isEmpty);
    await _type(tester, 'project-title', 'App');
    await _type(tester, 'project-start', '٠٢/٢٠٢٤');
    await _type(tester, 'project-end', '01/2024');
    await _type(tester, 'project-description', 'Built app');
    await _type(tester, 'project-technologies', 'Dart\nFlutter, Web');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects, isEmpty);
    await _type(tester, 'project-end', '03/2024');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects.single.startDate, '02/2024');
    expect(r.projects.single.technologies, ['Dart', 'Flutter, Web']);
    await _tap(tester, 'edit-project-0');
    await _type(tester, 'project-title', 'Discard');
    final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(r.projects.single.name, 'App');
    await _tap(tester, 'edit-project-0');
    await _tap(tester, 'project-current');
    await _tap(tester, 'save-resume-entry');
    expect(r.projects.single.isCurrent, isTrue);
    expect(r.projects.single.endDate, isNull);
    expect(r.projects.single.technologies, ['Dart', 'Flutter, Web']);
    await _tap(tester, 'delete-project-0');
    expect(r.projects, isEmpty);
  });
  testWidgets('achievement preserves custom category and organization', (
    tester,
  ) async {
    final r = _prepare().currentResume.value!;
    await tester.pumpWidget(_host(const AchievementsStep()));
    await tester.pumpAndSettle();
    await _tap(tester, 'add-achievements');
    await _type(tester, 'achievement-name', 'Award');
    await _type(tester, 'achievement-description', 'Won award');
    await _type(tester, 'achievement-date', '٠١/٢٠٢٤');
    await _type(tester, 'achievement-category', 'Custom imported');
    await _type(tester, 'achievement-organization', 'University');
    await _tap(tester, 'save-resume-entry');
    expect(r.achievements.single.date, '01/2024');
    await _tap(tester, 'edit-achievement-0');
    await _type(tester, 'achievement-name', 'Updated');
    await _tap(tester, 'save-resume-entry');
    expect(r.achievements.single.category, 'Custom imported');
    expect(r.achievements.single.organization, 'University');
    expect(r.achievements.single.name, 'Updated');
    await _tap(tester, 'delete-achievement-0');
    expect(r.achievements, isEmpty);
  });
  testWidgets('interests add, deduplicate, edit, cancel, toggle and remove', (
    tester,
  ) async {
    final r = _prepare().currentResume.value!;
    await tester.pumpWidget(_host(const InterestsStep()));
    await tester.pumpAndSettle();
    await _type(tester, 'interest-name', 'Reading');
    await _tap(tester, 'add-interest');
    expect(r.interests, ['Reading']);
    await _type(tester, 'interest-name', ' reading ');
    await _tap(tester, 'add-interest');
    expect(r.interests, ['Reading']);
    await _tap(tester, 'edit-interest-0');
    await _type(tester, 'interest-name', 'Custom hobby');
    await _tap(tester, 'add-interest');
    expect(r.interests, ['Custom hobby']);
    await _tap(tester, 'edit-interest-0');
    await _type(tester, 'interest-name', 'Discard');
    await _tap(tester, 'cancel-interest');
    expect(r.interests, ['Custom hobby']);
    await _tap(tester, 'interest-suggestion-Reading');
    expect(r.interests, ['Custom hobby', 'Reading']);
    await _tap(tester, 'interest-suggestion-Reading');
    expect(r.interests, ['Custom hobby']);
    await _tap(tester, 'delete-interest-0');
    expect(r.interests, isEmpty);
  });
  for (final width in [320.0, 800.0, 1920.0]) {
    for (final kind in ['projects', 'achievements', 'interests']) {
      testWidgets('$kind Arabic scaled text at $width', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final r = _prepare().currentResume.value!;
        r.projects.add(
          Project(
            name: 'مشروع طويل في تطوير التطبيقات',
            description: 'تطوير حلول تقنية متقدمة ومتنوعة',
            startDate: '01/2024',
            isCurrent: true,
            technologies: ['Flutter', 'Dart'],
          ),
        );
        r.achievements.add(
          Achievement(
            name: 'إنجاز طويل في تطوير البرمجيات',
            description: 'وصف تفصيلي للإنجاز',
            date: '01/2024',
            category: 'تصنيف مخصص',
          ),
        );
        r.interests = ['اهتمام مخصص طويل في تطوير البرمجيات'];
        await tester.pumpWidget(
          _host(
            switch (kind) {
              'projects' => const ProjectsStep(),
              'achievements' => const AchievementsStep(),
              _ => const InterestsStep(),
            },
            scale: 2,
            arabic: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (kind != 'interests') {
          await _tap(tester, 'add-$kind');
          expect(tester.takeException(), isNull);
          final surface = find.byKey(
            const ValueKey('resume-form-dialog-surface'),
          );
          expect(
            tester.getSize(surface).width,
            lessThanOrEqualTo(
              width < 600
                  ? 500
                  : width < 1200
                  ? 600
                  : 650,
            ),
          );
          await tester.ensureVisible(
            find.byKey(const ValueKey('save-resume-entry')),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        } else {
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('edit-interest-0')),
            300,
            scrollable: find.byType(Scrollable).first,
          );
          await _tap(tester, 'edit-interest-0');
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}

```

## test/import_resume/redesign_import_dialogs_test.dart
```dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/import_resume/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Service extends ResumeImportService {
  Completer<ResumeModel?>? pending;
  int calls = 0;
  @override
  Future<ResumeModel?> pickAndImport(String extension) async {
    calls++;
    return pending?.future ??
        ResumeModel(
          fullName: 'Alex Morgan',
          email: 'alex@example.com',
          skills: [Skill(name: 'Flutter', level: 4)],
        );
  }
}

Widget _host(
  Widget child, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
  bool keyboard = false,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => RepaintBoundary(
    key: const ValueKey('import-dialog-capture'),
    child: MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
        disableAnimations: true,
        viewInsets: EdgeInsets.only(bottom: keyboard ? 280 : 0),
      ),
      child: child!,
    ),
  ),
  home: child,
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('import-dialog-capture')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'deliveries/ui_redesign/batch_09_$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Widget _dialogs() => Scaffold(
  appBar: AppBar(title: Text('education'.tr)),
  body: Builder(
    builder: (context) => TextButton(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => const EducationDialog(),
      ),
      child: Text('add_education'.tr),
    ),
  ),
);
void main() {
  setUpAll(() async {
    for (final entry in {
      'Poppins': 'assets/fonts/Poppins-Regular.ttf',
      'Cairo': 'assets/fonts/Cairo-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });
  tearDown(Get.reset);
  for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
    for (final arabic in [false, true]) {
      for (final dark in [false, true]) {
        testWidgets('import preview $width ar=$arabic dark=$dark scale2', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, width == 1024 ? 480 : 1200);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          Get.put(ResumeController(repository: _Repository()));
          final service = _Service();
          await tester.pumpWidget(
            _host(
              ImportResumeScreen(service: service),
              arabic: arabic,
              dark: dark,
              scale: 2,
            ),
          );
          await tester.pumpAndSettle();
          final json = tester.widget<ImportOptionCard>(
            find.byKey(const ValueKey('import-option-json')),
          );
          final pdf = tester.widget<ImportOptionCard>(
            find.byKey(const ValueKey('import-option-pdf')),
          );
          expect(json.recommended, isTrue);
          expect(pdf.warning, isTrue);
          await _tap(
            tester,
            find.text('import_select_file'.trParams({'format': 'JSON'})),
          );
          await tester.ensureVisible(
            find.byKey(const ValueKey('save-imported-resume')),
          );
          await tester.pumpAndSettle();
          expect(find.byType(ImportPreviewWidget), findsOneWidget);
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
              (width == 390 || width == 1920) &&
              arabic == dark) {
            await tester.pumpWidget(const SizedBox());
            await tester.pumpWidget(
              _host(
                ImportResumeScreen(service: service),
                arabic: arabic,
                dark: dark,
              ),
            );
            await tester.pumpAndSettle();
            await _capture(
              tester,
              'import_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
            );
            await _tap(
              tester,
              find.text('import_select_file'.trParams({'format': 'JSON'})),
            );
            await _capture(
              tester,
              'import_preview_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
            );
          }
        });
        testWidgets(
          'all entry dialogs $width ar=$arabic dark=$dark scale2 with keyboard',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, width == 1024 ? 480 : 1200);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final dialogs = <Widget>[
              const EducationDialog(),
              const ExperienceDialog(),
              const CourseDialog(),
              const CertificateDialog(),
              const ResumeLanguageDialog(),
              const ProjectDialog(),
              const AchievementDialog(),
            ];
            for (final dialog in dialogs) {
              await tester.pumpWidget(const SizedBox());
              await tester.pumpWidget(
                _host(
                  Scaffold(
                    body: Builder(
                      builder: (context) => TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => dialog,
                        ),
                        child: const Text('open-dialog'),
                      ),
                    ),
                  ),
                  arabic: arabic,
                  dark: dark,
                  scale: 2,
                  keyboard: true,
                ),
              );
              await tester.tap(find.text('open-dialog'));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await tester.ensureVisible(
                find.byKey(const ValueKey('save-resume-entry')),
              );
              await tester.pumpAndSettle();
              final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
              await _tap(tester, cancel);
              expect(find.byType(ResumeFormDialog), findsNothing);
              expect(tester.takeException(), isNull);
            }
            if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                (width == 390 || width == 1920) &&
                arabic == dark) {
              await tester.pumpWidget(const SizedBox());
              await tester.pumpWidget(
                _host(_dialogs(), arabic: arabic, dark: dark),
              );
              await tester.tap(find.text('add_education'.tr));
              await tester.pumpAndSettle();
              await _capture(
                tester,
                'education_dialog_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
              );
            }
          },
        );
      }
    }
  }
  testWidgets(
    'pending file picker shows loading and blocks duplicate selection',
    (tester) async {
      Get.put(ResumeController(repository: _Repository()));
      final service = _Service()..pending = Completer<ResumeModel?>();
      await tester.pumpWidget(_host(ImportResumeScreen(service: service)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('import_select_file'.trParams({'format': 'JSON'})),
      );
      await tester.pump();
      expect(find.byType(ImportLoadingWidget), findsOneWidget);
      for (final card in tester.widgetList<ImportOptionCard>(
        find.byType(ImportOptionCard),
      )) {
        expect(card.onSelect, isNull);
      }
      expect(service.calls, 1);
      service.pending!.complete(null);
      await tester.pumpAndSettle();
      expect(find.byType(ImportLoadingWidget), findsNothing);
      expect(find.byType(ImportPreviewWidget), findsNothing);
    },
  );
}

```


