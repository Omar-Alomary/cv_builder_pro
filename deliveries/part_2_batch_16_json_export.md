# Part 2 — الدفعة السادسة عشرة: تصدير JSON
الملفات التالية كاملة ومطبقة في المشروع، ومنها legacy_app.dart كاملاً لأن الربط الحالي للمحرر والمعاينة ما زال فيه. لا اعتماديات جديدة.
تضيف الدفعة ResumeExportService لحفظ JSON ومشاركته، وزر تصدير موحد في شريطي المحرر والمعاينة. يلتقط الزر نسخة مستقلة من السيرة عند فتح الحوار، وتشمل نسخة المعاينة ألوانها وخطها وحجمه الحالي حتى قبل حفظ التخصيص. لا يتطلب التصدير حفظ المسودة في قاعدة البيانات.
الحفظ يستخدم FilePicker.saveFile مع بايتات UTF-8. على Android وiOS يتولى المنتقي حفظها؛ على سطح المكتب تُكتب إلى ملف مرحلي في مجلد الوجهة ثم تُنقل إلى المسار المختار. الإلغاء لا يعرض نجاحاً ولا يكتب ملفاً. تُعرض الأخطاء داخل الحوار مع إمكانية إعادة المحاولة، وتُمنع العمليات المتزامنة. المشاركة تستخدم SharePlus وXFile.fromData مع اسم JSON وموضع زر المشاركة للأجهزة اللوحية.
الملف يحفظ جميع حقول ResumeModel بما فيها المعرّف والمفضلة والتخصيص ومسار الصورة؛ المسار ليس صورة مضمّنة. عند الحفظ عبر شاشة الاستيراد يُنشأ معرّف محلي جديد وتُصفّر المفضلة ومسار الصورة، كما وُضح في الدفعة السابقة. يرفض التصدير ما يتجاوز حد الاستيراد 10 ميغابايت.
التحقق: اجتاز مجموع الاختبارات 149 اختباراً، منها 19 جديدة. شملت كتابة ملف حقيقي وإعادة استيراده، استبدال ملف موجود، الإلغاء، مسار الهاتف، أخطاء الكتابة، بيانات المشاركة، حدود الحجم، أخطاء JSON، نسخة المسودة المستقلة، منع تكرار الضغط، والتجاوب بالعربية مع تكبير النص. فحص المجلدات المطورة دون ملاحظات. فحص legacy_app.dart لا يحتوي أخطاء لكنه ما زال يحتوي 63 ملاحظة وتحذيراً من الكود القديم. لم تُفتح نافذة الحفظ أو المشاركة الأصلية على جهاز في هذه الاختبارات؛ جرى استبدال واجهتي المنتقي والمشاركة مع اختبار كتابة القرص فعلياً.

## lib/core/services/resume_export_service.dart

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/index.dart';
import '../constants/app_constants.dart';

/// Export failure with a stable, localized feedback key.
class ExportException implements Exception {
  const ExportException(this.messageKey);
  final String messageKey;
  @override
  String toString() => messageKey;
}

/// Saves and shares complete UTF-8 resume JSON compatible with the importer.
class ResumeExportService {
  ResumeExportService({
    FilePicker? picker,
    Future<ShareResult> Function(ShareParams)? share,
  }) : _picker = picker,
       _share = share;
  final FilePicker? _picker;
  final Future<ShareResult> Function(ShareParams)? _share;

  /// Mobile pickers write supplied bytes; desktop pickers return a destination.
  bool get pickerWritesBytes => Platform.isAndroid || Platform.isIOS;

  String fileName(ResumeModel resume) {
    var name = resume.fullName
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\u0600-\u06ff-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (name.length > 60) name = name.substring(0, 60);
    return 'cv_${name.isEmpty ? 'resume' : name}.json';
  }

  Uint8List toBytes(ResumeModel resume) {
    try {
      final bytes = Uint8List.fromList(utf8.encode(ResumeJson.encode(resume)));
      if (bytes.length > AppConstants.maxImportBytes) {
        throw const ExportException('export_json_too_large');
      }
      return bytes;
    } on ExportException {
      rethrow;
    } catch (_) {
      throw const ExportException('export_json_invalid');
    }
  }

  Future<String?> saveJson(ResumeModel resume) async {
    try {
      final bytes = toBytes(resume);
      final destination = await (_picker ?? FilePicker.platform).saveFile(
        fileName: fileName(resume),
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
        lockParentWindow: true,
      );
      if (destination == null) return null;
      if (!pickerWritesBytes) {
        if (!destination.toLowerCase().endsWith('.json')) {
          throw const ExportException('export_json_extension');
        }
        await _writeAtomically(File(destination), bytes);
      }
      return destination;
    } on ExportException {
      rethrow;
    } catch (_) {
      throw const ExportException('export_json_save_failed');
    }
  }

  Future<void> _writeAtomically(File destination, Uint8List bytes) async {
    Directory? staging;
    File? temporary;
    try {
      staging = await destination.parent.createTemp('.cv_export_');
      temporary = File('${staging.path}/resume.json');
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(destination.path);
    } catch (_) {
      throw const ExportException('export_json_save_failed');
    } finally {
      try {
        if (temporary != null && await temporary.exists()) {
          await temporary.delete();
        }
        if (staging != null && await staging.exists()) await staging.delete();
      } catch (_) {
        /* A cleanup failure must not misreport a completed export. */
      }
    }
  }

  Future<ShareResult> shareJson(
    ResumeModel resume, {
    required Rect origin,
  }) async {
    try {
      final bytes = toBytes(resume);
      final name = fileName(resume);
      final params = ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'application/json', name: name),
        ],
        fileNameOverrides: [name],
        subject: 'CV Builder Pro',
        sharePositionOrigin: origin,
      );
      return await (_share ?? SharePlus.instance.share)(params);
    } on ExportException {
      rethrow;
    } catch (_) {
      throw const ExportException('export_json_share_failed');
    }
  }
}

```

## lib/core/index.dart

```dart
export 'constants/app_constants.dart';
export 'services/storage_service.dart';
export 'services/settings_service.dart';
export 'services/resume_import_service.dart';
export 'services/resume_export_service.dart';
export 'services/ats_analyzer_service.dart';
export 'utils/ats_scorer.dart';
export 'constants/storage_keys.dart';
export 'extensions/context_extensions.dart';
export 'utils/app_snackbar.dart';
export 'utils/date_formatter.dart';
export 'utils/responsive.dart';
export 'utils/validators.dart';

```

## lib/features/resume_builder/presentation/widgets/resume_json_export_button.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/resume_export_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';

/// Reusable editor and preview export action using an independent draft copy.
class ResumeJsonExportButton extends StatefulWidget {
  const ResumeJsonExportButton({super.key, required this.resume, this.service});
  final ResumeModel? Function() resume;
  final ResumeExportService? service;
  @override
  State<ResumeJsonExportButton> createState() => _ResumeJsonExportButtonState();
}

class _ResumeJsonExportButtonState extends State<ResumeJsonExportButton> {
  bool _open = false;
  Future<void> _show() async {
    if (_open) return;
    setState(() => _open = true);
    try {
      final resume = widget.resume()?.copyWith();
      if (resume == null) {
        AppSnackbar.warning(context, 'export_no_resume'.tr);
        return;
      }
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ExportDialog(
          resume: resume,
          service: widget.service ?? ResumeExportService(),
        ),
      );
      if (!mounted) return;
      if (result == 'saved') {
        AppSnackbar.success(context, 'export_json_saved'.tr);
      }
      if (result == 'shared') {
        AppSnackbar.info(context, 'export_json_shared'.tr);
      }
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'export_json_invalid'.tr);
    } finally {
      if (mounted) setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'export_json'.tr,
    onPressed: _open ? null : _show,
    icon: const Icon(Icons.data_object),
  );
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({required this.resume, required this.service});
  final ResumeModel resume;
  final ResumeExportService service;
  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  bool _working = false;
  String? _error;
  Future<void> _run({required bool share, BuildContext? anchor}) async {
    if (_working) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      String? result;
      if (share) {
        final box = anchor!.findRenderObject() as RenderBox;
        final shared = await widget.service.shareJson(
          widget.resume,
          origin: box.localToGlobal(Offset.zero) & box.size,
        );
        if (shared.status != ShareResultStatus.dismissed) result = 'shared';
      } else {
        final saved = await widget.service.saveJson(widget.resume);
        if (saved != null) result = 'saved';
      }
      if (result != null && mounted) Navigator.of(context).pop(result);
    } on ExportException catch (error) {
      if (mounted) setState(() => _error = error.messageKey);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = share
              ? 'export_json_share_failed'
              : 'export_json_save_failed',
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_working,
    child: Dialog(
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
              AppSectionHeader(
                title: 'export_json'.tr,
                subtitle: 'export_json_description'.tr,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AppButton(
                key: const ValueKey('save-resume-json'),
                label: 'export_json_save'.tr,
                fullWidth: true,
                icon: Icons.save_alt,
                onPressed: _working ? null : () => _run(share: false),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (anchor) => AppButton(
                  key: const ValueKey('share-resume-json'),
                  label: 'export_json_share'.tr,
                  fullWidth: true,
                  icon: Icons.share_outlined,
                  variant: AppButtonVariant.outlined,
                  onPressed: _working
                      ? null
                      : () => _run(share: true, anchor: anchor),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'cancel'.tr,
                fullWidth: true,
                variant: AppButtonVariant.text,
                onPressed: _working ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

```

## lib/features/resume_builder/index.dart

```dart
export 'presentation/widgets/resume_json_export_button.dart';

```

## lib/features/index.dart

```dart
export 'splash/index.dart';
export 'language/index.dart';
export 'home/index.dart';
export 'templates/index.dart';
export 'favorites/index.dart';
export 'settings/index.dart';
export 'import_resume/index.dart';
export 'resume_builder/index.dart';

```

## lib/legacy_app.dart

```dart
//10
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'data/index.dart';
import 'controllers/index.dart';
import 'features/resume_builder/presentation/widgets/resume_json_export_button.dart';

import 'core/utils/app_snackbar.dart';
import 'core/utils/validators.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:intl/intl.dart';

// ==================== MODELS ====================

// ==================== VALIDATORS ====================

// ==================== WIDGETS ====================

// ==================== RESUME BUILDER SCREENS ====================
class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final TemplateController templateController = Get.find<TemplateController>();
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final GlobalKey<AdditionalInfoStepState> _additionalInfoKey =
      GlobalKey<AdditionalInfoStepState>();

  int get totalSteps {
    final templateId =
        resumeController.currentResume.value?.templateId ?? 'modern';
    final fields = templateController.getFieldsForTemplate(templateId);
    int steps = 4;
    final hasAdditional =
        fields.showCourses ||
        fields.showCertificates ||
        fields.showLanguages ||
        fields.showProjects ||
        fields.showAchievements ||
        fields.showInterests;
    if (hasAdditional) steps = 5;
    return steps;
  }

  bool get isInAdditionalStep => _currentStep == 4 && totalSteps > 4;
  bool get isAdditionalComplete =>
      isInAdditionalStep &&
      (_additionalInfoKey.currentState?.isLastTab ?? false);
  bool get isLastStep => isInAdditionalStep
      ? isAdditionalComplete
      : _currentStep == totalSteps - 1;

  @override
  void initState() {
    super.initState();
    resumeController.startAutoSave();
    _initResume();
  }

  void _initResume() {
    if (Get.arguments != null) {
      if (Get.arguments is ResumeModel) {
        resumeController.currentResume.value = Get.arguments;
        resumeController.isEditing.value = true;
      } else {
        final templateId = Get.arguments as String;
        resumeController.currentResume.value = ResumeModel(
          fullName: '',
          email: '',
          phone: '',
          education: [],
          experience: [],
          skills: [],
          courses: [],
          certificates: [],
          languages: [],
          projects: [],
          achievements: [],

          templateId: templateId,
          createdAt: DateTime.now(),
        );
        resumeController.isEditing.value = false;
      }
    } else {
      resumeController.currentResume.value = ResumeModel(
        fullName: '',
        email: '',
        phone: '',
        education: [],
        experience: [],
        skills: [],
        courses: [],
        certificates: [],
        languages: [],
        projects: [],
        achievements: [],
        templateId: 'modern',
        createdAt: DateTime.now(),
      );
      resumeController.isEditing.value = false;
    }
  }

  @override
  void dispose() {
    resumeController.stopAutoSave();
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (isInAdditionalStep) {
      final state = _additionalInfoKey.currentState;
      if (state != null && !state.isLastTab) {
        state.nextTab();
        setState(() {});
        return;
      }
      _finishResume();
      return;
    }
    if (_currentStep < totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishResume();
    }
  }

  void _finishResume() async {
    final saved = await resumeController.saveResume(
      resumeController.currentResume.value!,
    );
    if (saved && mounted) Get.to(const PreviewScreen());
  }

  @override
  Widget build(BuildContext context) {
    final templateId =
        resumeController.currentResume.value?.templateId ?? 'modern';
    final fields = templateController.getFieldsForTemplate(templateId);
    final hasAdditional =
        fields.showCourses ||
        fields.showCertificates ||
        fields.showLanguages ||
        fields.showProjects ||
        fields.showAchievements ||
        fields.showInterests;
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          resumeController.isEditing.value
              ? 'edit_resume'.tr
              : 'create_resume'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        actions: [
          ResumeJsonExportButton(
            key: const ValueKey('builder-export-json'),
            resume: () => resumeController.currentResume.value,
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () => Get.to(() => const PreviewScreen()),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: () async {
                final saved = await resumeController.saveResume(
                  resumeController.currentResume.value!,
                );
                if (saved && mounted) Get.back();
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Step Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildModernStepIndicator(0, 'personal_info'.tr, Icons.person),
                _buildStepConnector(),
                _buildModernStepIndicator(1, 'education'.tr, Icons.school),
                _buildStepConnector(),
                _buildModernStepIndicator(2, 'experience'.tr, Icons.work),
                _buildStepConnector(),
                _buildModernStepIndicator(3, 'skills'.tr, Icons.code),
                if (hasAdditional) ...[
                  _buildStepConnector(),
                  _buildModernStepIndicator(
                    4,
                    'additional_info'.tr,
                    Icons.info,
                  ),
                ],
              ],
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                const PersonalInfoStep(),
                const EducationStep(),
                const ExperienceStep(),
                const SkillsStep(),
                if (hasAdditional) AdditionalInfoStep(key: _additionalInfoKey),
              ],
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (isInAdditionalStep)
                          _additionalInfoKey.currentState?.resetToFirstTab();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: Text('previous'.tr),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _goToNext,
                    icon: Icon(
                      isLastStep ? Icons.check : Icons.arrow_forward,
                      size: 18,
                    ),
                    label: Text(isLastStep ? 'finish'.tr : 'next'.tr),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: isLastStep
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    final color = isActive || isCompleted
        ? Theme.of(Get.context!).primaryColor
        : Colors.grey[400];

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive || isCompleted
                  ? LinearGradient(colors: [Colors.blue, Colors.blue])
                  : null,
              color: !isActive && !isCompleted ? Colors.grey[200] : null,
              boxShadow: isActive
                  ? [BoxShadow(color: Colors.blue, blurRadius: 8)]
                  : [],
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : Icon(
                    icon,
                    color: isActive ? Colors.white : Colors.grey[500],
                    size: 20,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Theme.of(Get.context!).primaryColor
                  : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() =>
      Container(width: 20, height: 2, color: Colors.grey[300]);
}

// ==================== IMPROVED PERSONAL INFO STEP ====================
class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({super.key});
  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final TemplateController templateController = Get.find<TemplateController>();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController fullNameController,
      emailController,
      phoneController,
      addressController,
      summaryController,
      linkedinController,
      githubController,
      websiteController,
      portfolioController;

  @override
  void initState() {
    super.initState();
    final resume = resumeController.currentResume.value!;
    fullNameController = TextEditingController(text: resume.fullName);
    emailController = TextEditingController(text: resume.email);
    phoneController = TextEditingController(text: resume.phone);
    addressController = TextEditingController(text: resume.address ?? '');
    summaryController = TextEditingController(text: resume.summary ?? '');
    linkedinController = TextEditingController(text: resume.linkedin ?? '');
    githubController = TextEditingController(text: resume.github ?? '');
    websiteController = TextEditingController(text: resume.website ?? '');
    portfolioController = TextEditingController(text: resume.portfolio ?? '');

    fullNameController.addListener(_updateResume);
    emailController.addListener(_updateResume);
    phoneController.addListener(_updateResume);
    addressController.addListener(_updateResume);
    summaryController.addListener(_updateResume);
    linkedinController.addListener(_updateResume);
    githubController.addListener(_updateResume);
    websiteController.addListener(_updateResume);
    portfolioController.addListener(_updateResume);
  }

  void _updateResume() {
    final resume = resumeController.currentResume.value!;
    resume.fullName = fullNameController.text;
    resume.email = emailController.text;
    resume.phone = phoneController.text;
    resume.address = addressController.text.isEmpty
        ? null
        : addressController.text;
    resume.summary = summaryController.text.isEmpty
        ? null
        : summaryController.text;
    resume.linkedin = linkedinController.text.isEmpty
        ? null
        : linkedinController.text;
    resume.github = githubController.text.isEmpty
        ? null
        : githubController.text;
    resume.website = websiteController.text.isEmpty
        ? null
        : websiteController.text;
    resume.portfolio = portfolioController.text.isEmpty
        ? null
        : portfolioController.text;
    resumeController.currentResume.value = resume;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final resume = resumeController.currentResume.value!;
      resume.profilePicture = image.path;
      resumeController.currentResume.value = resume;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final templateId =
        resumeController.currentResume.value?.templateId ?? 'classic';
    final fields = templateController.getFieldsForTemplate(templateId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (fields.showProfilePicture)
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      final imagePath =
                          resumeController.currentResume.value?.profilePicture;
                      return CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: imagePath != null
                            ? FileImage(File(imagePath))
                            : null,
                        child: imagePath == null
                            ? Icon(
                                Icons.person,
                                size: 55,
                                color: Colors.grey[400],
                              )
                            : null,
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _buildTextField(
              fullNameController,
              'full_name'.tr,
              Icons.person,
              validator: (v) => Validators.validateRequired(v, 'full_name'.tr),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              emailController,
              'email'.tr,
              Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              phoneController,
              'phone'.tr,
              Icons.phone,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            if (fields.showAddress) ...[
              const SizedBox(height: 16),
              _buildTextField(
                addressController,
                'address'.tr,
                Icons.location_on,
              ),
            ],
            if (fields.showLinkedin) ...[
              const SizedBox(height: 16),
              _buildTextField(
                linkedinController,
                'linkedin'.tr,
                Icons.link,
                hint: 'https://linkedin.com/in/username',
              ),
            ],
            if (fields.showGithub) ...[
              const SizedBox(height: 16),
              _buildTextField(
                githubController,
                'github'.tr,
                Icons.code,
                hint: 'https://github.com/username',
              ),
            ],
            if (fields.showWebsite) ...[
              const SizedBox(height: 16),
              _buildTextField(
                websiteController,
                'website'.tr,
                Icons.language,
                hint: 'https://yourwebsite.com',
              ),
            ],
            if (fields.showPortfolio) ...[
              const SizedBox(height: 16),
              _buildTextField(
                portfolioController,
                'portfolio'.tr,
                Icons.no_photography,
                hint: 'https://yourportfolio.com',
              ),
            ],
            if (fields.showSummary) ...[
              const SizedBox(height: 16),
              _buildTextField(
                summaryController,
                'summary'.tr,
                Icons.description,
                maxLines: 4,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    summaryController.dispose();
    linkedinController.dispose();
    githubController.dispose();
    websiteController.dispose();
    portfolioController.dispose();
    super.dispose();
  }
}

// ==================== IMPROVED EDUCATION STEP ====================
class EducationStep extends StatefulWidget {
  const EducationStep({super.key});
  @override
  State<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends State<EducationStep> {
  final ResumeController resumeController = Get.find<ResumeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final educationList =
          resumeController.currentResume.value?.education ?? [];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddButton(
            'add_education'.tr,
            Icons.school,
            _showAddEducationDialog,
          ),
          const SizedBox(height: 16),
          if (educationList.isEmpty)
            _buildEmptyState(Icons.school_outlined, 'no_education_added'.tr)
          else
            ...educationList.asMap().entries.map(
              (entry) => _buildEducationCard(entry.key, entry.value),
            ),
        ],
      );
    });
  }

  Widget _buildEducationCard(int index, Education education) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.school, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          education.degree,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(education.institution),
            Text(education.year),
            if (education.grade != null) Text('Grade: ${education.grade}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteEducation(index),
        ),
        onTap: () => _showEditEducationDialog(index, education),
      ),
    );
  }

  void _showAddEducationDialog() => showDialog(
    context: context,
    builder: (context) => _EducationDialog(
      onSave: (education) {
        final resume = resumeController.currentResume.value!;
        resume.education.add(education);
        resumeController.currentResume.value = resume;
      },
    ),
  );
  void _showEditEducationDialog(int index, Education education) => showDialog(
    context: context,
    builder: (context) => _EducationDialog(
      education: education,
      onSave: (updated) {
        final resume = resumeController.currentResume.value!;
        resume.education[index] = updated;
        resumeController.currentResume.value = resume;
      },
    ),
  );
  void _deleteEducation(int index) {
    final resume = resumeController.currentResume.value!;
    resume.education.removeAt(index);
    resumeController.currentResume.value = resume;
  }
}

// Helper Widgets
Widget _buildAddButton(String label, IconData icon, VoidCallback onPressed) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

Widget _buildEmptyState(IconData icon, String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
}

// ==================== IMPROVED EXPERIENCE STEP ====================
class ExperienceStep extends StatefulWidget {
  const ExperienceStep({super.key});
  @override
  State<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends State<ExperienceStep> {
  final ResumeController resumeController = Get.find<ResumeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final experienceList =
          resumeController.currentResume.value?.experience ?? [];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddButton(
            'add_experience'.tr,
            Icons.work,
            _showAddExperienceDialog,
          ),
          const SizedBox(height: 16),
          if (experienceList.isEmpty)
            _buildEmptyState(Icons.work_outline, 'no_experience_added'.tr)
          else
            ...experienceList.asMap().entries.map(
              (entry) => _buildExperienceCard(entry.key, entry.value),
            ),
        ],
      );
    });
  }

  Widget _buildExperienceCard(int index, Experience experience) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.work, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          experience.jobTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(experience.company),
            Text(
              '${experience.startDate} - ${experience.isCurrent ? 'Present' : experience.endDate}',
            ),
            if (experience.description != null)
              Text(
                experience.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteExperience(index),
        ),
        onTap: () => _showEditExperienceDialog(index, experience),
      ),
    );
  }

  void _showAddExperienceDialog() => showDialog(
    context: context,
    builder: (context) => _ExperienceDialog(
      onSave: (experience) {
        final resume = resumeController.currentResume.value!;
        resume.experience.add(experience);
        resumeController.currentResume.value = resume;
      },
    ),
  );
  void _showEditExperienceDialog(int index, Experience experience) =>
      showDialog(
        context: context,
        builder: (context) => _ExperienceDialog(
          experience: experience,
          onSave: (updated) {
            final resume = resumeController.currentResume.value!;
            resume.experience[index] = updated;
            resumeController.currentResume.value = resume;
          },
        ),
      );
  void _deleteExperience(int index) {
    final resume = resumeController.currentResume.value!;
    resume.experience.removeAt(index);
    resumeController.currentResume.value = resume;
  }
}

// ==================== IMPROVED SKILLS STEP ====================
class SkillsStep extends StatefulWidget {
  const SkillsStep({super.key});
  @override
  State<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<SkillsStep> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final TextEditingController _skillController = TextEditingController();
  int _selectedLevel = 3;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final skills = resumeController.currentResume.value?.skills ?? [];
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Skill Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _skillController,
                      decoration: InputDecoration(
                        labelText: 'skill_name'.tr,
                        prefixIcon: const Icon(Icons.code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., Flutter, Python, Project Management',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'skill_level'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Slider(
                            value: _selectedLevel.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _getLevelText(_selectedLevel),
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) =>
                                setState(() => _selectedLevel = value.toInt()),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getLevelText(_selectedLevel),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addSkill,
                        icon: const Icon(Icons.add),
                        label: Text('add_skill'.tr),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Skills List Header
            if (skills.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'my_skills'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Skills List
            if (skills.isEmpty)
              _buildEmptyState(Icons.psychology_outlined, 'no_skills_added'.tr)
            else
              ...skills.asMap().entries.map(
                (entry) => _buildSkillCard(entry.key, entry.value),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSkillCard(int index, Skill skill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${skill.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: skill.level / 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getLevelText(skill.level),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteSkill(index),
            ),
          ],
        ),
      ),
    );
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      final skill = Skill(
        name: _skillController.text.trim(),
        level: _selectedLevel,
      );
      final resume = resumeController.currentResume.value!;
      resume.skills.add(skill);
      resumeController.currentResume.value = resume;
      _skillController.clear();
      setState(() => _selectedLevel = 3);
    }
  }

  void _deleteSkill(int index) {
    final resume = resumeController.currentResume.value!;
    resume.skills.removeAt(index);
    resumeController.currentResume.value = resume;
  }

  String _getLevelText(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Basic';
      case 3:
        return 'Intermediate';
      case 4:
        return 'Advanced';
      case 5:
        return 'Expert';
      default:
        return 'Intermediate';
    }
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }
}

// ==================== IMPROVED COURSES STEP ====================
class CoursesStep extends StatefulWidget {
  const CoursesStep({super.key});
  @override
  State<CoursesStep> createState() => _CoursesStepState();
}

class _CoursesStepState extends State<CoursesStep> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final courses = resumeController.currentResume.value?.courses ?? [];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddButton('add_course'.tr, Icons.add, _showAddDialog),
          const SizedBox(height: 16),
          if (courses.isEmpty)
            _buildEmptyState(Icons.school_outlined, 'no_courses_added'.tr)
          else
            ...courses.asMap().entries.map(
              (entry) => _buildCourseCard(entry.key, entry.value),
            ),
        ],
      );
    });
  }

  Widget _buildCourseCard(int index, Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.school, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          course.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(course.provider), Text(course.year)],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteCourse(index),
        ),
        onTap: () => _showEditDialog(index, course),
      ),
    );
  }

  void _showAddDialog() => showDialog(
    context: context,
    builder: (context) => _CourseDialog(
      onSave: (course) {
        final resume = resumeController.currentResume.value!;
        resume.courses.add(course);
        resumeController.currentResume.value = resume;
      },
    ),
  );
  void _showEditDialog(int index, Course course) => showDialog(
    context: context,
    builder: (context) => _CourseDialog(
      course: course,
      onSave: (updated) {
        final resume = resumeController.currentResume.value!;
        resume.courses[index] = updated;
        resumeController.currentResume.value = resume;
      },
    ),
  );
  void _deleteCourse(int index) {
    final resume = resumeController.currentResume.value!;
    resume.courses.removeAt(index);
    resumeController.currentResume.value = resume;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}

// ==================== IMPROVED CERTIFICATES STEP ====================
class CertificatesStep extends StatefulWidget {
  const CertificatesStep({super.key});
  @override
  State<CertificatesStep> createState() => _CertificatesStepState();
}

class _CertificatesStepState extends State<CertificatesStep> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final certificates =
          resumeController.currentResume.value?.certificates ?? [];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddButton('add_certificate'.tr, Icons.add, _showAddDialog),
          const SizedBox(height: 16),
          if (certificates.isEmpty)
            _buildEmptyState(
              Icons.verified_outlined,
              'no_certificates_added'.tr,
            )
          else
            ...certificates.asMap().entries.map(
              (entry) => _buildCertificateCard(entry.key, entry.value),
            ),
        ],
      );
    });
  }

  Widget _buildCertificateCard(int index, Certificate cert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.verified, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          cert.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(cert.organization), Text(cert.year)],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteCertificate(index),
        ),
        onTap: () => _showEditDialog(index, cert),
      ),
    );
  }

  void _showAddDialog() => showDialog(
    context: context,
    builder: (context) => _CertificateDialog(
      onSave: (cert) {
        final resume = resumeController.currentResume.value!;
        resume.certificates.add(cert);
        resumeController.currentResume.value = resume;
      },
    ),
  );
  void _showEditDialog(int index, Certificate cert) => showDialog(
    context: context,
    builder: (context) => _CertificateDialog(
      certificate: cert,
      onSave: (updated) {
        final resume = resumeController.currentResume.value!;
        resume.certificates[index] = updated;
        resumeController.currentResume.value = resume;
      },
    ),
  );
  void _deleteCertificate(int index) {
    final resume = resumeController.currentResume.value!;
    resume.certificates.removeAt(index);
    resumeController.currentResume.value = resume;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}

// ==================== IMPROVED LANGUAGES STEP ====================
class LanguagesStep extends StatefulWidget {
  const LanguagesStep({super.key});
  @override
  State<LanguagesStep> createState() => _LanguagesStepState();
}

class _LanguagesStepState extends State<LanguagesStep> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final TextEditingController _nameController = TextEditingController();
  String _selectedLevel = 'Intermediate';
  final List<String> levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Fluent',
    'Native',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final languages = resumeController.currentResume.value?.languages ?? [];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddButton('add_language'.tr, Icons.add, _showAddDialog),
          const SizedBox(height: 16),
          if (languages.isEmpty)
            _buildEmptyState(Icons.language_outlined, 'no_languages_added'.tr)
          else
            ...languages.asMap().entries.map(
              (entry) => _buildLanguageCard(entry.key, entry.value),
            ),
        ],
      );
    });
  }

  Widget _buildLanguageCard(int index, Language lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              lang.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          lang.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_getLevelText(lang.level)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteLanguage(index),
        ),
        onTap: () => _showEditDialog(index, lang),
      ),
    );
  }

  String _getLevelText(String level) {
    switch (level) {
      case 'Beginner':
        return 'Beginner 🌱';
      case 'Intermediate':
        return 'Intermediate 📚';
      case 'Advanced':
        return 'Advanced 🚀';
      case 'Fluent':
        return 'Fluent 💬';
      case 'Native':
        return 'Native 🌟';
      default:
        return level;
    }
  }

  void _showAddDialog() => showDialog(
    context: context,
    builder: (context) => _LanguageDialog(
      onSave: (lang) {
        final resume = resumeController.currentResume.value!;
        resume.languages.add(lang);
        resumeController.currentResume.value = resume;
      },
    ),
  );
  void _showEditDialog(int index, Language lang) => showDialog(
    context: context,
    builder: (context) => _LanguageDialog(
      language: lang,
      onSave: (updated) {
        final resume = resumeController.currentResume.value!;
        resume.languages[index] = updated;
        resumeController.currentResume.value = resume;
      },
    ),
  );
  void _deleteLanguage(int index) {
    final resume = resumeController.currentResume.value!;
    resume.languages.removeAt(index);
    resumeController.currentResume.value = resume;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// ==================== IMPROVED PROJECTS STEP ====================

class ProjectsStep extends StatefulWidget {
  const ProjectsStep({super.key});
  @override
  State<ProjectsStep> createState() => _ProjectsStepState();
}

class _ProjectsStepState extends State<ProjectsStep> {
  final ResumeController resumeController = Get.find<ResumeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final projects = resumeController.currentResume.value?.projects ?? [];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddButton('add_project'.tr, Icons.code, _showAddProjectDialog),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            _buildEmptyState(Icons.code_off, 'no_projects_added'.tr)
          else
            ...projects.asMap().entries.map(
              (entry) => _buildProjectCard(entry.key, entry.value),
            ),
        ],
      );
    });
  }

  Widget _buildProjectCard(int index, Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.code, color: Colors.white),
        ),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(project.startDate),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditProjectDialog(index, project),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProject(index),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.description, project.description),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.calendar_today,
                  '${project.startDate} - ${project.isCurrent ? 'Present' : project.endDate ?? ''}',
                ),
                if (project.technologies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: project.technologies
                        .map(
                          (tech) => Chip(
                            label: Text(tech),
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  void _showAddProjectDialog() => showDialog(
    context: context,
    builder: (context) => _ProjectDialog(
      onSave: (project) {
        final resume = resumeController.currentResume.value!;
        resume.projects.add(project);
        resumeController.currentResume.value = resume;
      },
    ),
  );

  void _showEditProjectDialog(int index, Project project) => showDialog(
    context: context,
    builder: (context) => _ProjectDialog(
      project: project,
      onSave: (updated) {
        final resume = resumeController.currentResume.value!;
        resume.projects[index] = updated;
        resumeController.currentResume.value = resume;
      },
    ),
  );

  void _deleteProject(int index) {
    final resume = resumeController.currentResume.value!;
    resume.projects.removeAt(index);
    resumeController.currentResume.value = resume;
  }
}

//last one
// نفس الشيء لـ AchievementsStep
class AchievementsStep extends StatefulWidget {
  const AchievementsStep({super.key});
  @override
  State<AchievementsStep> createState() => _AchievementsStepState();
}

class _AchievementsStepState extends State<AchievementsStep> {
  final ResumeController resumeController = Get.find<ResumeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final achievements =
          resumeController.currentResume.value?.achievements ?? [];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddButton(
            'add_achievement'.tr,
            Icons.emoji_events,
            _showAddAchievementDialog,
          ),
          const SizedBox(height: 16),
          if (achievements.isEmpty)
            _buildEmptyState(
              Icons.emoji_events_outlined,
              'no_achievements_added'.tr,
            )
          else
            ...achievements.asMap().entries.map(
              (entry) => _buildAchievementCard(entry.key, entry.value),
            ),
        ],
      );
    });
  }

  Widget _buildAchievementCard(int index, Achievement achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.amber),
        ),
        title: Text(
          achievement.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(achievement.date),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditAchievementDialog(index, achievement),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAchievement(index),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (achievement.category != null)
                  _buildDetailRow(Icons.category, achievement.category!),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.description, achievement.description),
                if (achievement.organization != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.business, achievement.organization!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  void _showAddAchievementDialog() => showDialog(
    context: context,
    builder: (context) => _AchievementDialog(
      onSave: (achievement) {
        final resume = resumeController.currentResume.value!;
        resume.achievements.add(achievement);
        resumeController.currentResume.value = resume;
      },
    ),
  );

  void _showEditAchievementDialog(int index, Achievement achievement) =>
      showDialog(
        context: context,
        builder: (context) => _AchievementDialog(
          achievement: achievement,
          onSave: (updated) {
            final resume = resumeController.currentResume.value!;
            resume.achievements[index] = updated;
            resumeController.currentResume.value = resume;
          },
        ),
      );

  void _deleteAchievement(int index) {
    final resume = resumeController.currentResume.value!;
    resume.achievements.removeAt(index);
    resumeController.currentResume.value = resume;
  }
}

// ==================== PROJECT DIALOG WITH FULL FIELDS ====================
class _ProjectDialog extends StatefulWidget {
  final Project? project;
  final Function(Project) onSave;
  const _ProjectDialog({this.project, required this.onSave});

  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late bool _isCurrent;
  late List<String> _technologies;
  final TextEditingController _techController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );
    _startDateController = TextEditingController(
      text: widget.project?.startDate ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.project?.endDate ?? '',
    );
    _isCurrent = widget.project?.isCurrent ?? false;
    _technologies = widget.project?.technologies ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.code,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.project == null
                            ? 'add_project'.tr
                            : 'edit_project'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Project Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'project_name'.tr,
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: isArabic
                        ? 'مثال: تطبيق إدارة المهام'
                        : 'e.g., Task Management App',
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'project_name_required'.tr
                      : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'description'.tr,
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: isArabic
                        ? 'وصف المشروع والميزات الرئيسية...'
                        : 'Project description and key features...',
                  ),
                  maxLines: 4,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'description_required'.tr : null,
                ),
                const SizedBox(height: 16),

                // Start Date
                TextFormField(
                  controller: _startDateController,
                  decoration: InputDecoration(
                    labelText: 'start_date'.tr,
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: isArabic ? 'شهر/سنة' : 'MM/YYYY',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'start_date_required'.tr : null,
                ),
                const SizedBox(height: 16),

                // Current Project Checkbox and End Date
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: Text('current_project'.tr),
                        value: _isCurrent,
                        onChanged: (v) =>
                            setState(() => _isCurrent = v ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    if (!_isCurrent)
                      Expanded(
                        child: TextFormField(
                          controller: _endDateController,
                          decoration: InputDecoration(
                            labelText: 'end_date'.tr,
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: isArabic ? 'شهر/سنة' : 'MM/YYYY',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Technologies Used
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'technologies_used'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _techController,
                            decoration: InputDecoration(
                              hintText: isArabic
                                  ? 'مثال: Flutter, Firebase'
                                  : 'e.g., Flutter, Firebase',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addTechnology,
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                          tooltip: 'add_technology'.tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _technologies
                          .map(
                            (tech) => Chip(
                              label: Text(tech),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeTechnology(tech),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text('save'.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addTechnology() {
    if (_techController.text.trim().isNotEmpty) {
      setState(() {
        _technologies.add(_techController.text.trim());
        _techController.clear();
      });
    }
  }

  void _removeTechnology(String tech) {
    setState(() {
      _technologies.remove(tech);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Project(
          name: _nameController.text,
          description: _descriptionController.text,
          startDate: _startDateController.text,
          endDate: _isCurrent ? null : _endDateController.text,
          isCurrent: _isCurrent,
          technologies: _technologies,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _techController.dispose();
    super.dispose();
  }
}

// ==================== ACHIEVEMENT DIALOG WITH FULL FIELDS ====================
class _AchievementDialog extends StatefulWidget {
  final Achievement? achievement;
  final Function(Achievement) onSave;
  const _AchievementDialog({this.achievement, required this.onSave});

  @override
  State<_AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<_AchievementDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _organizationController;
  late String _selectedCategory;
  final _formKey = GlobalKey<FormState>();

  final List<String> _categories = [
    'Award',
    'Certification',
    'Recognition',
    'Publication',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.achievement?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.achievement?.description ?? '',
    );
    _dateController = TextEditingController(
      text: widget.achievement?.date ?? '',
    );
    _organizationController = TextEditingController(
      text: widget.achievement?.organization ?? '',
    );
    _selectedCategory = widget.achievement?.category ?? _categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.achievement == null
                            ? 'add_achievement'.tr
                            : 'edit_achievement'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Achievement Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'achievement_name'.tr,
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: isArabic
                        ? 'مثال: أفضل موظف في السنة'
                        : 'e.g., Employee of the Year',
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'achievement_name_required'.tr
                      : null,
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'category'.tr,
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 16),

                // Organization
                TextFormField(
                  controller: _organizationController,
                  decoration: InputDecoration(
                    labelText: 'organization'.tr,
                    prefixIcon: const Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: isArabic
                        ? 'الجهة المانحة'
                        : 'Awarding organization',
                  ),
                ),
                const SizedBox(height: 16),

                // Date
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'date'.tr,
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: isArabic ? 'شهر/سنة' : 'MM/YYYY',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'date_required'.tr : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'description'.tr,
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: isArabic
                        ? 'وصف الإنجاز...'
                        : 'Achievement description...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text('save'.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Achievement(
          name: _nameController.text,
          description: _descriptionController.text,
          date: _dateController.text,
          organization: _organizationController.text.isEmpty
              ? null
              : _organizationController.text,
          category: _selectedCategory,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _organizationController.dispose();
    super.dispose();
  }
}

// ==================== IMPROVED INTERESTS STEP ====================
class InterestsStep extends StatefulWidget {
  const InterestsStep({super.key});
  @override
  State<InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends State<InterestsStep> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final List<String> commonInterests = [
    'Reading',
    'Travel',
    'Music',
    'Sports',
    'Photography',
    'Coding',
    'Art',
    'Gaming',
    'Cooking',
    'Yoga',
    'Chess',
    'Volunteering',
    'Writing',
    'Dancing',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final interests = resumeController.currentResume.value?.interests ?? [];
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Your Interests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your hobbies and interests to make your resume more personal',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: commonInterests.map((interest) {
                    return FilterChip(
                      label: Text(interest),
                      selected: interests.contains(interest),
                      onSelected: (selected) {
                        final resume = resumeController.currentResume.value!;
                        resume.interests ??= [];
                        if (selected) {
                          resume.interests!.add(interest);
                        } else {
                          resume.interests!.remove(interest);
                        }
                        resumeController.currentResume.value = resume;
                      },
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                      avatar: Icon(
                        Icons.favorite,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  }).toList(),
                ),
                if (interests.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'your_selected_interests'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: interests
                              .map(
                                (interest) => Chip(
                                  label: Text(interest),
                                  onDeleted: () {
                                    final resume =
                                        resumeController.currentResume.value!;
                                    resume.interests!.remove(interest);
                                    resumeController.currentResume.value =
                                        resume;
                                  },
                                  deleteIcon: const Icon(Icons.close, size: 14),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ==================== IMPROVED DIALOGS ====================
class _EducationDialog extends StatefulWidget {
  final Education? education;
  final Function(Education) onSave;
  const _EducationDialog({this.education, required this.onSave});

  @override
  State<_EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<_EducationDialog> {
  late TextEditingController degreeController,
      institutionController,
      yearController,
      gradeController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    degreeController = TextEditingController(
      text: widget.education?.degree ?? '',
    );
    institutionController = TextEditingController(
      text: widget.education?.institution ?? '',
    );
    yearController = TextEditingController(text: widget.education?.year ?? '');
    gradeController = TextEditingController(
      text: widget.education?.grade ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.education == null ? 'add_education'.tr : 'edit_education'.tr,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                degreeController,
                'degree'.tr,
                Icons.school,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                institutionController,
                'institution'.tr,
                Icons.business,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                yearController,
                'graduation_year'.tr,
                Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                gradeController,
                'grade'.tr,
                Icons.grade,
                optional: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(onPressed: _save, child: Text('save'.tr)),
      ],
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool optional = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: optional
          ? null
          : (v) => v == null || v.isEmpty ? '$label ${'is_required'.tr}' : null,
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Education(
          degree: degreeController.text,
          institution: institutionController.text,
          year: yearController.text,
          grade: gradeController.text.isEmpty ? null : gradeController.text,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    degreeController.dispose();
    institutionController.dispose();
    yearController.dispose();
    gradeController.dispose();
    super.dispose();
  }
}

class _ExperienceDialog extends StatefulWidget {
  final Experience? experience;
  final Function(Experience) onSave;
  const _ExperienceDialog({this.experience, required this.onSave});

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  late TextEditingController jobTitleController,
      companyController,
      startDateController,
      endDateController,
      descriptionController;
  late bool isCurrent;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    jobTitleController = TextEditingController(
      text: widget.experience?.jobTitle ?? '',
    );
    companyController = TextEditingController(
      text: widget.experience?.company ?? '',
    );
    startDateController = TextEditingController(
      text: widget.experience?.startDate ?? '',
    );
    endDateController = TextEditingController(
      text: widget.experience?.endDate ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.experience?.description ?? '',
    );
    isCurrent = widget.experience?.isCurrent ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.experience == null ? 'add_experience'.tr : 'edit_experience'.tr,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                jobTitleController,
                'job_title'.tr,
                Icons.work,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                companyController,
                'company'.tr,
                Icons.business,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                startDateController,
                'start_date'.tr,
                Icons.calendar_today,
                hint: 'MM/YYYY',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('current_job'.tr),
                      value: isCurrent,
                      onChanged: (v) => setState(() => isCurrent = v ?? false),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (!isCurrent)
                    Expanded(
                      child: _buildDialogTextField(
                        endDateController,
                        'end_date'.tr,
                        Icons.calendar_today,
                        hint: 'MM/YYYY',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                descriptionController,
                'description'.tr,
                Icons.description,
                maxLines: 3,
                optional: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(onPressed: _save, child: Text('save'.tr)),
      ],
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    String? hint,
    bool optional = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: maxLines,
      validator: optional
          ? null
          : (v) => v == null || v.isEmpty ? '$label ${'is_required'.tr}' : null,
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Experience(
          jobTitle: jobTitleController.text,
          company: companyController.text,
          startDate: startDateController.text,
          endDate: isCurrent ? null : endDateController.text,
          isCurrent: isCurrent,
          description: descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    jobTitleController.dispose();
    companyController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

// Similar simplified dialogs for Course, Certificate, Language
class _CourseDialog extends StatefulWidget {
  final Course? course;
  final Function(Course) onSave;
  const _CourseDialog({this.course, required this.onSave});

  @override
  State<_CourseDialog> createState() => _CourseDialogState();
}

class _CourseDialogState extends State<_CourseDialog> {
  late TextEditingController nameController, providerController, yearController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.course?.name ?? '');
    providerController = TextEditingController(
      text: widget.course?.provider ?? '',
    );
    yearController = TextEditingController(text: widget.course?.year ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.course == null ? 'add_course'.tr : 'edit_course'.tr),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameController, 'course_name'.tr, Icons.school),
            const SizedBox(height: 12),
            _buildTextField(providerController, 'provider'.tr, Icons.business),
            const SizedBox(height: 12),
            _buildTextField(
              yearController,
              'year'.tr,
              Icons.calendar_today,
              hint: '2024',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(onPressed: _save, child: Text('save'.tr)),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? '$label ${'is_required'.tr}' : null,
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Course(
          name: nameController.text,
          provider: providerController.text,
          year: yearController.text,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    providerController.dispose();
    yearController.dispose();
    super.dispose();
  }
}

class _CertificateDialog extends StatefulWidget {
  final Certificate? certificate;
  final Function(Certificate) onSave;
  const _CertificateDialog({this.certificate, required this.onSave});

  @override
  State<_CertificateDialog> createState() => _CertificateDialogState();
}

class _CertificateDialogState extends State<_CertificateDialog> {
  late TextEditingController nameController, orgController, yearController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.certificate?.name ?? '',
    );
    orgController = TextEditingController(
      text: widget.certificate?.organization ?? '',
    );
    yearController = TextEditingController(
      text: widget.certificate?.year ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.certificate == null
            ? 'add_certificate'.tr
            : 'edit_certificate'.tr,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              nameController,
              'certificate_name'.tr,
              Icons.verified,
            ),
            const SizedBox(height: 12),
            _buildTextField(orgController, 'organization'.tr, Icons.business),
            const SizedBox(height: 12),
            _buildTextField(
              yearController,
              'year'.tr,
              Icons.calendar_today,
              hint: '2024',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(onPressed: _save, child: Text('save'.tr)),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? '$label ${'is_required'.tr}' : null,
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Certificate(
          name: nameController.text,
          organization: orgController.text,
          year: yearController.text,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    orgController.dispose();
    yearController.dispose();
    super.dispose();
  }
}

class _LanguageDialog extends StatefulWidget {
  final Language? language;
  final Function(Language) onSave;
  const _LanguageDialog({this.language, required this.onSave});

  @override
  State<_LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<_LanguageDialog> {
  late TextEditingController nameController;
  late String selectedLevel;
  final _formKey = GlobalKey<FormState>();
  final List<String> levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Fluent',
    'Native',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.language?.name ?? '');
    selectedLevel = widget.language?.level ?? 'Intermediate';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.language == null ? 'add_language'.tr : 'edit_language'.tr,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'language_name'.tr,
                prefixIcon: const Icon(Icons.language),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'e.g., English, Arabic, French',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'language_name_required'.tr : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedLevel,
              decoration: InputDecoration(
                labelText: 'proficiency_level'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: levels
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(_getLevelDisplay(level)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedLevel = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(onPressed: _save, child: Text('save'.tr)),
      ],
    );
  }

  String _getLevelDisplay(String level) {
    switch (level) {
      case 'Beginner':
        return 'Beginner 🌱';
      case 'Intermediate':
        return 'Intermediate 📚';
      case 'Advanced':
        return 'Advanced 🚀';
      case 'Fluent':
        return 'Fluent 💬';
      case 'Native':
        return 'Native 🌟';
      default:
        return level;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(Language(name: nameController.text, level: selectedLevel));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}

// ==================== ADDITIONAL INFO STEP ====================
class AdditionalInfoStep extends StatefulWidget {
  const AdditionalInfoStep({super.key});

  @override
  State<AdditionalInfoStep> createState() => AdditionalInfoStepState();
}

class AdditionalInfoStepState extends State<AdditionalInfoStep> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final TemplateController templateController = Get.find<TemplateController>();
  int _selectedTab = 0;
  List<MapEntry<String, Widget>> _activeTabs = [];

  bool get isLastTab => _selectedTab == _activeTabs.length - 1;

  void nextTab() {
    if (_selectedTab < _activeTabs.length - 1) {
      setState(() {
        _selectedTab++;
      });
    }
  }

  void resetToFirstTab() {
    setState(() {
      _selectedTab = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateTabs();
  }

  void _updateTabs() {
    final templateId =
        resumeController.currentResume.value?.templateId ?? 'classic';
    final fields = templateController.getFieldsForTemplate(templateId);

    _activeTabs.clear();
    if (fields.showCourses)
      _activeTabs.add(MapEntry('courses'.tr, const CoursesStep()));
    if (fields.showCertificates)
      _activeTabs.add(MapEntry('certificates'.tr, const CertificatesStep()));
    if (fields.showLanguages)
      _activeTabs.add(MapEntry('languages'.tr, const LanguagesStep()));
    if (fields.showProjects)
      _activeTabs.add(MapEntry('projects'.tr, const ProjectsStep()));
    if (fields.showAchievements)
      _activeTabs.add(MapEntry('achievements'.tr, const AchievementsStep()));
    if (fields.showInterests)
      _activeTabs.add(MapEntry('interests'.tr, const InterestsStep()));

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant AdditionalInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTabs();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeTabs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'no_additional_sections'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final currentWidget = _activeTabs[_selectedTab].value;
    final currentTitle = _activeTabs[_selectedTab];

    return Column(
      children: [
        // شريط التبويبات (عرض فقط)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Column(
            children: [
              Text(
                currentTitle.key,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedTab + 1} / ${_activeTabs.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        // محتوى التبويب الحالي
        Expanded(child: currentWidget),
      ],
    );
  }
}

// ==================== PREVIEW SCREEN ====================
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final ResumeController resumeController = Get.find<ResumeController>();
  final TemplateController templateController = Get.find<TemplateController>();

  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.grey;
  String _fontFamily = 'Poppins';
  double _fontSize = 12;
  bool _showCustomization = false;
  Uint8List? _cachedPDF;
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    _loadCustomization();
    _generatePDFAndCache();
  }

  void _loadCustomization() {
    final customization = resumeController.currentResume.value?.customization;
    if (customization != null) {
      _primaryColor = Color(customization['primaryColor'] ?? Colors.blue.value);
      _secondaryColor = Color(
        customization['secondaryColor'] ?? Colors.grey.value,
      );
      _fontFamily = customization['fontFamily'] ?? 'Poppins';
      _fontSize = customization['fontSize'] ?? 12.0;
    }
  }

  Future<void> _generatePDFAndCache() async {
    setState(() => _isGeneratingPDF = true);
    try {
      _cachedPDF = await _generatePDF();
    } catch (e) {
      print('Error generating PDF: $e');
      _cachedPDF = null;
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  Future<Uint8List> _generatePDF() async {
    final resume = resumeController.currentResume.value!;
    final isArabic = Get.locale?.languageCode == 'ar';
    final pdf = pw.Document();

    // Load fonts
    pw.Font? headerFont;
    pw.Font? bodyFont;
    try {
      final headerFontData = await rootBundle.load(
        'assets/fonts/SukarBlack.ttf',
      );
      headerFont = pw.Font.ttf(headerFontData);
      final bodyFontData = await rootBundle.load(
        'assets/fonts/Cairo-Regular.ttf',
      );
      bodyFont = pw.Font.ttf(bodyFontData);
    } catch (e) {
      print('Font loading error: $e');
    }

    final textDirection = isArabic
        ? pw.TextDirection.rtl
        : pw.TextDirection.ltr;

    final titles = {
      'summary': isArabic ? 'الملخص المهني' : 'Professional Summary',
      'education': isArabic ? 'التعليم' : 'Education',
      'experience': isArabic ? 'الخبرات العملية' : 'Work Experience',
      'skills': isArabic ? 'المهارات' : 'Skills',
      'courses': isArabic ? 'الدورات التدريبية' : 'Courses',
      'certificates': isArabic ? 'الشهادات' : 'Certificates',
      'languages': isArabic ? 'اللغات' : 'Languages',
      'projects': isArabic ? 'المشاريع' : 'Projects',
      'achievements': isArabic ? 'الإنجازات' : 'Achievements',
      'interests': isArabic ? 'الاهتمامات' : 'Interests',
      'present': isArabic ? 'حالياً' : 'Present',
      'grade': isArabic ? 'التقدير' : 'Grade',
    };

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          List<pw.Widget> widgets = [];

          // Header
          widgets.add(
            _buildHeader(
              resume,
              titles,
              textDirection,
              isArabic,
              headerFont,
              bodyFont,
            ),
          );
          widgets.add(pw.SizedBox(height: 16));
          widgets.add(pw.Divider(color: PdfColor.fromInt(_primaryColor.value)));

          // Summary
          if (resume.summary != null && resume.summary!.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(titles['summary']!, headerFont, textDirection),
            );
            widgets.add(pw.SizedBox(height: 8));
            widgets.add(
              pw.Text(
                resume.summary!,
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
            );
          }

          // Education
          if (resume.education.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['education']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var edu in resume.education) {
              widgets.add(
                _buildEducationItem(
                  edu,
                  titles,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Experience
          if (resume.experience.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['experience']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var exp in resume.experience) {
              widgets.add(
                _buildExperienceItem(
                  exp,
                  titles,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Skills
          if (resume.skills.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(titles['skills']!, headerFont, textDirection),
            );
            widgets.add(pw.SizedBox(height: 8));
            widgets.add(
              _buildSkillsSection(
                resume.skills,
                textDirection,
                isArabic,
                bodyFont,
              ),
            );
          }

          // Courses
          if (resume.courses.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(titles['courses']!, headerFont, textDirection),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var course in resume.courses) {
              widgets.add(
                _buildCourseItem(
                  course,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Certificates
          if (resume.certificates.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['certificates']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var cert in resume.certificates) {
              widgets.add(
                _buildCertificateItem(
                  cert,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Languages
          if (resume.languages.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['languages']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var lang in resume.languages) {
              widgets.add(
                _buildLanguageItem(
                  lang,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }
          // Projects Section with full details
          if (resume.projects.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['projects']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var project in resume.projects) {
              widgets.add(
                _buildProjectItem(
                  project,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Achievements Section with full details
          if (resume.achievements.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['achievements']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (var achievement in resume.achievements) {
              widgets.add(
                _buildAchievementItem(
                  achievement,
                  textDirection,
                  isArabic,
                  headerFont,
                  bodyFont,
                ),
              );
            }
          }

          // Interests
          if (resume.interests != null && resume.interests!.isNotEmpty) {
            widgets.add(
              _buildSectionTitle(
                titles['interests']!,
                headerFont,
                textDirection,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
            widgets.add(
              _buildInterestsSection(
                resume.interests!,
                textDirection,
                bodyFont,
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    ResumeModel resume,
    Map<String, String> titles,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (resume.profilePicture != null &&
            File(resume.profilePicture!).existsSync())
          pw.Container(
            width: 80,
            height: 80,
            margin: const pw.EdgeInsets.only(right: 16),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              image: pw.DecorationImage(
                image: pw.MemoryImage(
                  File(resume.profilePicture!).readAsBytesSync(),
                ),
                fit: pw.BoxFit.cover,
              ),
            ),
          ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: isArabic
                ? pw.CrossAxisAlignment.end
                : pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                resume.fullName.isEmpty
                    ? (isArabic ? 'الاسم الكامل' : 'Full Name')
                    : resume.fullName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(_primaryColor.value),
                  font: headerFont,
                ),
                textDirection: textDirection,
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${titles['email']}: ${resume.email.isEmpty ? 'email@example.com' : resume.email}',
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
              pw.Text(
                '${titles['phone']}: ${resume.phone.isEmpty ? '+1234567890' : resume.phone}',
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
              if (resume.address != null && resume.address!.isNotEmpty)
                pw.Text(
                  '${titles['address']}: ${resume.address!}',
                  style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                  textDirection: textDirection,
                ),
              if (resume.linkedin != null && resume.linkedin!.isNotEmpty)
                pw.Text(
                  '${titles['linkedin']}: ${resume.linkedin!}',
                  style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                  textDirection: textDirection,
                ),
              if (resume.github != null && resume.github!.isNotEmpty)
                pw.Text(
                  '${titles['github']}: ${resume.github!}',
                  style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                  textDirection: textDirection,
                ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(
    String title,
    pw.Font? headerFont,
    pw.TextDirection textDirection,
  ) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromInt(_primaryColor.value),
        font: headerFont,
      ),
      textDirection: textDirection,
    );
  }

  pw.Widget _buildEducationItem(
    Education edu,
    Map<String, String> titles,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            edu.degree.isEmpty ? (isArabic ? 'الشهادة' : 'Degree') : edu.degree,
            style: pw.TextStyle(
              fontSize: _fontSize + 2,
              fontWeight: pw.FontWeight.bold,
              font: headerFont,
            ),
            textDirection: textDirection,
          ),
          pw.Text(
            edu.institution.isEmpty
                ? (isArabic ? 'المؤسسة' : 'Institution')
                : edu.institution,
            style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
            textDirection: textDirection,
          ),
          pw.Text(
            edu.year.isEmpty ? (isArabic ? 'السنة' : 'Year') : edu.year,
            style: pw.TextStyle(
              fontSize: _fontSize - 1,
              color: PdfColors.grey600,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
          if (edu.grade != null && edu.grade!.isNotEmpty)
            pw.Text(
              '${titles['grade']}: ${edu.grade}',
              style: pw.TextStyle(fontSize: _fontSize - 1, font: bodyFont),
              textDirection: textDirection,
            ),
        ],
      ),
    );
  }

  pw.Widget _buildExperienceItem(
    Experience exp,
    Map<String, String> titles,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            exp.jobTitle.isEmpty
                ? (isArabic ? 'المسمى الوظيفي' : 'Job Title')
                : exp.jobTitle,
            style: pw.TextStyle(
              fontSize: _fontSize + 2,
              fontWeight: pw.FontWeight.bold,
              font: headerFont,
            ),
            textDirection: textDirection,
          ),
          pw.Text(
            exp.company.isEmpty
                ? (isArabic ? 'الشركة' : 'Company')
                : exp.company,
            style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
            textDirection: textDirection,
          ),
          pw.Text(
            '${exp.startDate.isEmpty ? (isArabic ? 'تاريخ البدء' : 'Start Date') : exp.startDate} - ${exp.isCurrent ? titles['present'] : (exp.endDate?.isEmpty ?? true ? (isArabic ? 'تاريخ الانتهاء' : 'End Date') : exp.endDate)}',
            style: pw.TextStyle(
              fontSize: _fontSize - 1,
              color: PdfColors.grey600,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
          if (exp.description != null && exp.description!.isNotEmpty)
            pw.Text(
              exp.description!,
              style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
              textDirection: textDirection,
            ),
        ],
      ),
    );
  }

  pw.Widget _buildSkillsSection(
    List<Skill> skills,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? bodyFont,
  ) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 4,
      children: skills.map((skill) {
        String levelText = '';
        switch (skill.level) {
          case 1:
            levelText = isArabic ? 'مبتدئ' : 'Beginner';
            break;
          case 2:
            levelText = isArabic ? 'أساسي' : 'Basic';
            break;
          case 3:
            levelText = isArabic ? 'متوسط' : 'Intermediate';
            break;
          case 4:
            levelText = isArabic ? 'متقدم' : 'Advanced';
            break;
          case 5:
            levelText = isArabic ? 'خبير' : 'Expert';
            break;
        }
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(_primaryColor.value),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            '${skill.name} ${levelText.isNotEmpty ? '($levelText)' : ''}',
            style: pw.TextStyle(
              fontSize: _fontSize,
              color: PdfColors.white,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildCourseItem(
    Course course,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            course.name.isEmpty
                ? (isArabic ? 'اسم الدورة' : 'Course Name')
                : course.name,
            style: pw.TextStyle(
              fontSize: _fontSize,
              fontWeight: pw.FontWeight.bold,
              font: headerFont,
            ),
            textDirection: textDirection,
          ),
          pw.Text(
            course.provider.isEmpty
                ? (isArabic ? 'مقدم الدورة' : 'Provider')
                : course.provider,
            style: pw.TextStyle(fontSize: _fontSize - 1, font: bodyFont),
            textDirection: textDirection,
          ),
          pw.Text(
            course.year.isEmpty ? (isArabic ? 'السنة' : 'Year') : course.year,
            style: pw.TextStyle(
              fontSize: _fontSize - 1,
              color: PdfColors.grey600,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCertificateItem(
    Certificate cert,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cert.name.isEmpty
                ? (isArabic ? 'اسم الشهادة' : 'Certificate Name')
                : cert.name,
            style: pw.TextStyle(
              fontSize: _fontSize,
              fontWeight: pw.FontWeight.bold,
              font: headerFont,
            ),
            textDirection: textDirection,
          ),
          pw.Text(
            cert.organization.isEmpty
                ? (isArabic ? 'الجهة المانحة' : 'Organization')
                : cert.organization,
            style: pw.TextStyle(fontSize: _fontSize - 1, font: bodyFont),
            textDirection: textDirection,
          ),
          pw.Text(
            cert.year.isEmpty ? (isArabic ? 'السنة' : 'Year') : cert.year,
            style: pw.TextStyle(
              fontSize: _fontSize - 1,
              color: PdfColors.grey600,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLanguageItem(
    Language lang,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    String levelDisplay = '';
    switch (lang.level) {
      case 'Beginner':
        levelDisplay = isArabic ? 'مبتدئ' : 'Beginner';
        break;
      case 'Intermediate':
        levelDisplay = isArabic ? 'متوسط' : 'Intermediate';
        break;
      case 'Advanced':
        levelDisplay = isArabic ? 'متقدم' : 'Advanced';
        break;
      case 'Fluent':
        levelDisplay = isArabic ? 'طليق' : 'Fluent';
        break;
      case 'Native':
        levelDisplay = isArabic ? 'لغة أم' : 'Native';
        break;
      default:
        levelDisplay = lang.level;
    }
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              lang.name.isEmpty ? (isArabic ? 'لغة' : 'Language') : lang.name,
              style: pw.TextStyle(
                fontSize: _fontSize,
                fontWeight: pw.FontWeight.bold,
                font: headerFont,
              ),
              textDirection: textDirection,
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(_primaryColor.value),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              levelDisplay,
              style: pw.TextStyle(
                fontSize: _fontSize - 2,
                color: PdfColors.white,
                font: bodyFont,
              ),
              textDirection: textDirection,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectItem(
    Project project,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          // Project Name
          pw.Row(
            children: [
              // pw.Icon(
              //   pw.IconData(0xe3c9),
              //   size: 12,
              //   color: PdfColor.fromInt(_primaryColor.value),
              // ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(
                  project.name,
                  style: pw.TextStyle(
                    fontSize: _fontSize + 2,
                    fontWeight: pw.FontWeight.bold,
                    font: headerFont,
                  ),
                  textDirection: textDirection,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),

          // Date Range
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Text(
              '${project.startDate} - ${project.isCurrent ? (isArabic ? 'حالياً' : 'Present') : project.endDate ?? ''}',
              style: pw.TextStyle(
                fontSize: _fontSize - 1,
                color: PdfColors.grey600,
                font: bodyFont,
              ),
              textDirection: textDirection,
            ),
          ),
          pw.SizedBox(height: 4),

          // Description
          if (project.description.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                project.description,
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
            ),

          // Technologies
          if (project.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Wrap(
                spacing: 4,
                runSpacing: 4,
                children: project.technologies
                    .map(
                      (tech) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(_primaryColor.value),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          tech,
                          style: pw.TextStyle(
                            fontSize: _fontSize - 2,
                            color: PdfColors.white,
                            font: bodyFont,
                          ),
                          textDirection: textDirection,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildAchievementItem(
    Achievement achievement,
    pw.TextDirection textDirection,
    bool isArabic,
    pw.Font? headerFont,
    pw.Font? bodyFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: isArabic
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          // Achievement Name with Icon
          pw.Row(
            children: [
              // pw.Icon(
              //   pw.IconData(0xe8b5),
              //   size: 12,
              //   color: PdfColor.fromInt(_primaryColor.value),
              // ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(
                  achievement.name,
                  style: pw.TextStyle(
                    fontSize: _fontSize + 2,
                    fontWeight: pw.FontWeight.bold,
                    font: headerFont,
                  ),
                  textDirection: textDirection,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),

          // Date
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Text(
              achievement.date,
              style: pw.TextStyle(
                fontSize: _fontSize - 1,
                color: PdfColors.grey600,
                font: bodyFont,
              ),
              textDirection: textDirection,
            ),
          ),

          // Organization
          if (achievement.organization != null &&
              achievement.organization!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                achievement.organization!,
                style: pw.TextStyle(fontSize: _fontSize - 1, font: bodyFont),
                textDirection: textDirection,
              ),
            ),

          // Category
          if (achievement.category != null && achievement.category!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(_primaryColor.value),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  achievement.category!,
                  style: pw.TextStyle(
                    fontSize: _fontSize - 2,
                    color: PdfColors.white,
                    font: bodyFont,
                  ),
                  textDirection: textDirection,
                ),
              ),
            ),

          // Description
          if (achievement.description.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                achievement.description,
                style: pw.TextStyle(fontSize: _fontSize, font: bodyFont),
                textDirection: textDirection,
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildInterestsSection(
    List<String> interests,
    pw.TextDirection textDirection,
    pw.Font? bodyFont,
  ) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 4,
      children: interests.map((interest) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(_primaryColor.value),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            interest,
            style: pw.TextStyle(
              fontSize: _fontSize,
              color: PdfColors.white,
              font: bodyFont,
            ),
            textDirection: textDirection,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveCustomization() async {
    final resume = resumeController.currentResume.value;
    if (resume != null) {
      resume.customization = {
        'primaryColor': _primaryColor.value,
        'secondaryColor': _secondaryColor.value,
        'fontFamily': _fontFamily,
        'fontSize': _fontSize,
      };
      resumeController.currentResume.value = resume;
      final saved = await resumeController.saveResume(resume);
      if (!saved || !mounted) return;
      await _generatePDFAndCache();
      Get.snackbar(
        'success'.tr,
        'customization_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _exportPDF() async {
    try {
      final pdfBytes = await _generatePDF();
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Check out my resume!');
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_export'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'preview'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        actions: [
          ResumeJsonExportButton(
            key: const ValueKey('preview-export-json'),
            resume: () => resumeController.currentResume.value?.copyWith(
              customization: {
                ...?resumeController.currentResume.value?.customization,
                'primaryColor': _primaryColor.toARGB32(),
                'secondaryColor': _secondaryColor.toARGB32(),
                'fontFamily': _fontFamily,
                'fontSize': _fontSize,
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                _showCustomization ? Icons.preview : Icons.edit,
                color: _showCustomization ? Colors.green : null,
              ),
              onPressed: () =>
                  setState(() => _showCustomization = !_showCustomization),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportPDF,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          if (_showCustomization)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveCustomization,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
        ],
      ),
      body: _showCustomization
          ? _buildCustomizationPanel()
          : _buildPDFPreview(),
    );
  }

  Widget _buildPDFPreview() {
    if (_isGeneratingPDF) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating preview...'),
          ],
        ),
      );
    }
    if (_cachedPDF == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('failed_to_generate_preview'.tr),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _generatePDFAndCache();
                setState(() {});
              },
              child: Text('retry'.tr),
            ),
          ],
        ),
      );
    }
    return PdfPreview(
      build: (format) async => _cachedPDF!,
      allowPrinting: true,
      allowSharing: true,
      previewPageMargin: const EdgeInsets.all(8),
      initialPageFormat: PdfPageFormat.a4,
    );
  }

  Widget _buildCustomizationPanel() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.color_lens),
                const SizedBox(width: 8),
                Text(
                  'customize_resume'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildColorCard(),
                const SizedBox(height: 16),
                _buildFontFamilyCard(),
                const SizedBox(height: 16),
                _buildFontSizeCard(),
                const SizedBox(height: 16),
                _buildLivePreviewCard(),
                const SizedBox(height: 16),
                _buildUpdateButton(),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildColorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Primary Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildColorOption(
                    Colors.blue,
                    () => setState(() => _primaryColor = Colors.blue),
                  ),
                  _buildColorOption(
                    Colors.green,
                    () => setState(() => _primaryColor = Colors.green),
                  ),
                  _buildColorOption(
                    Colors.red,
                    () => setState(() => _primaryColor = Colors.red),
                  ),
                  _buildColorOption(
                    Colors.purple,
                    () => setState(() => _primaryColor = Colors.purple),
                  ),
                  _buildColorOption(
                    Colors.orange,
                    () => setState(() => _primaryColor = Colors.orange),
                  ),
                  _buildColorOption(
                    Colors.teal,
                    () => setState(() => _primaryColor = Colors.teal),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _showCustomColorPicker(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.colorize,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontFamilyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Font Family',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFontOption('Poppins', 'Modern'),
                const SizedBox(width: 12),
                _buildFontOption('Cairo', 'Arabic'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Font Size',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.format_size),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 8,
                    max: 16,
                    divisions: 8,
                    label: '${_fontSize.toInt()}',
                    onChanged: (value) => setState(() => _fontSize = value),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_fontSize.toInt()}',
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    return Card(
      color: _primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: _primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Live Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primaryColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resumeController.currentResume.value!.fullName.isEmpty
                        ? 'Your Name'
                        : resumeController.currentResume.value!.fullName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sample text with $_fontFamily font',
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 4, color: _primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await _generatePDFAndCache();
          setState(() => _showCustomization = false);
          Get.snackbar(
            'success'.tr,
            'preview_updated'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        icon: const Icon(Icons.refresh),
        label: Text('update_preview'.tr),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showCustomization = false),
              icon: const Icon(Icons.close),
              label: Text('cancel'.tr),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _saveCustomization();
                setState(() => _showCustomization = false);
              },
              icon: const Icon(Icons.check),
              label: Text(
                'apply_changes'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color, VoidCallback onTap) {
    final isSelected = _primaryColor == color;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildFontOption(String fontFamily, String displayName) {
    final isSelected = _fontFamily == fontFamily;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _fontFamily = fontFamily),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? _primaryColor.withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _primaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: fontFamily,
                  color: isSelected ? _primaryColor : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? _primaryColor : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('choose_color'.tr),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _primaryColor,
            onColorChanged: (color) => setState(() => _primaryColor = color),
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }
}

// ==================== MAIN ====================

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
  'change_profile_image': 'Change profile photo',
  'profile_image_failed':
      'Could not select or save the profile photo. Please try again.',
  'settings_data_description':
      'Delete all saved resumes, favorites, profile and preferences.',
  'settings_exit_confirmation':
      'Exit the app and clear the current draft and profile photo preference? Saved resumes will remain.',
  'share_app_message': 'Create professional resumes with CV Builder Pro.',
  'import_discard': 'Discard preview',
  'import_edit_json': 'Editable resume JSON',
  'import_empty': 'The file contains no text.',
  'import_extension_mismatch':
      'The selected file does not match the requested format.',
  'import_invalid_json':
      'Invalid resume JSON. Use an object with fullName as text and correctly typed resume fields.',
  'import_invalid_pdf': 'This PDF is damaged or unsupported.',
  'import_json_description':
      'Preserves every resume section. Select a UTF-8 or UTF-16 JSON file, up to 10 MB.',
  'import_json_title': 'JSON — recommended',
  'import_loading': 'Reading and checking your resume…',
  'import_name_required': 'Enter a full name before saving.',
  'import_paste_json': 'Or paste resume JSON',
  'import_pdf_description':
      'Supports simple ASCII text PDFs, including Flate streams. Scans, encrypted PDFs and encoded fonts are unsupported. Review the extracted content.',
  'import_pdf_encrypted': 'Password-protected PDF files cannot be imported.',
  'import_pdf_font_unsupported':
      'This PDF uses unsupported font encoding. Import JSON or copy its text to a UTF-8 TXT file.',
  'import_pdf_no_text':
      'No supported PDF text was found. Scanned PDFs require OCR; use JSON or TXT instead.',
  'import_pdf_title': 'PDF — basic text only',
  'import_preview': 'Preview import',
  'import_preview_description':
      'Edit any field in the full JSON below, then save a new copy and continue editing. Foreign IDs, favorites and image paths are reset.',
  'import_preview_empty': 'Your import preview appears here',
  'import_preview_empty_description':
      'Choose a file or paste JSON. Nothing is saved until you confirm.',
  'import_read_failed':
      'Could not read the file. Check access permissions and try again.',
  'import_resume': 'Import resume',
  'import_save_edit': 'Save and continue editing',
  'import_section_counts':
      'Education: @education • Experience: @experience • Skills: @skills',
  'import_select_file': 'Select @format file',
  'import_text_encoding': 'Save the text file using UTF-8 or UTF-16 encoding.',
  'import_too_large':
      'The file is larger than 10 MB or its decompressed content exceeds the safe limit.',
  'import_txt_description':
      'Extracts name, email, phone, links and comma-separated skills. Keeps the complete text in Summary for manual review.',
  'import_txt_title': 'TXT',
  'import_unsupported': 'Choose a JSON, PDF or TXT file.',
  'export_json_description':
      'Save or share a complete JSON copy, including all sections and customization. You can import it again later. Photo paths are references, not embedded images.',
  'export_json_extension': 'Choose a filename ending in .json.',
  'export_json_invalid':
      'The resume contains data that cannot be exported as JSON.',
  'export_json_save': 'Save JSON file',
  'export_json_save_failed':
      'Could not save JSON. Check the selected location and available space.',
  'export_json_saved': 'JSON file saved successfully.',
  'export_json_share': 'Share JSON file',
  'export_json_share_failed':
      'Could not share JSON. Check that a sharing application is available.',
  'export_json_shared': 'JSON file sent to the share panel.',
  'export_json_too_large':
      'This JSON exceeds the 10 MB import limit. Reduce its content before exporting.',
  'export_no_resume': 'Open or create a resume before exporting.',
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
  'change_profile_image': 'تغيير الصورة الشخصية',
  'profile_image_failed': 'تعذر اختيار الصورة الشخصية أو حفظها. حاول مرة أخرى.',
  'settings_data_description':
      'حذف جميع السير المحفوظة والمفضلة والصورة الشخصية والتفضيلات.',
  'settings_exit_confirmation':
      'هل تريد الخروج ومسح المسودة الحالية وتفضيل الصورة الشخصية؟ ستبقى السير المحفوظة.',
  'share_app_message': 'أنشئ سيراً ذاتية احترافية باستخدام CV Builder Pro.',
  'import_discard': 'تجاهل المعاينة',
  'import_edit_json': 'JSON السيرة القابل للتعديل',
  'import_empty': 'لا يحتوي الملف على نص.',
  'import_extension_mismatch': 'لا يطابق الملف المختار التنسيق المطلوب.',
  'import_invalid_json':
      'JSON السيرة غير صالح. استخدم كائناً يحتوي fullName كنص وحقول السيرة بأنواع صحيحة.',
  'import_invalid_pdf': 'ملف PDF تالف أو غير مدعوم.',
  'import_json_description':
      'يحفظ جميع أقسام السيرة. اختر ملف JSON بترميز UTF-8 أو UTF-16، بحد أقصى 10 ميغابايت.',
  'import_json_title': 'JSON — موصى به',
  'import_loading': 'جارٍ قراءة السيرة والتحقق منها…',
  'import_name_required': 'أدخل الاسم الكامل قبل الحفظ.',
  'import_paste_json': 'أو الصق JSON السيرة',
  'import_pdf_description':
      'يدعم ملفات PDF النصية البسيطة بأحرف ASCII، ومنها تدفقات Flate. لا يدعم الصور أو التشفير أو الخطوط المرمّزة. راجع المحتوى المستخرج.',
  'import_pdf_encrypted': 'لا يمكن استيراد PDF المحمي بكلمة مرور.',
  'import_pdf_font_unsupported':
      'يستخدم PDF ترميز خطوط غير مدعوم. استورد JSON أو انسخ نصه إلى ملف TXT بترميز UTF-8.',
  'import_pdf_no_text':
      'لم يُعثر على نص PDF مدعوم. الملفات المصوّرة تحتاج OCR؛ استخدم JSON أو TXT بدلاً منها.',
  'import_pdf_title': 'PDF — نص بسيط فقط',
  'import_preview': 'معاينة الاستيراد',
  'import_preview_description':
      'عدّل أي حقل في JSON الكامل أدناه، ثم احفظ نسخة جديدة وأكمل التعديل. يُعاد ضبط المعرّف والمفضلة ومسار الصورة المستوردة.',
  'import_preview_empty': 'ستظهر معاينة الاستيراد هنا',
  'import_preview_empty_description':
      'اختر ملفاً أو الصق JSON. لن تُحفظ بيانات قبل تأكيدك.',
  'import_read_failed':
      'تعذرت قراءة الملف. تحقق من صلاحية الوصول وحاول مرة أخرى.',
  'import_resume': 'استيراد سيرة',
  'import_save_edit': 'حفظ ومتابعة التعديل',
  'import_section_counts':
      'التعليم: @education • الخبرة: @experience • المهارات: @skills',
  'import_select_file': 'اختيار ملف @format',
  'import_text_encoding': 'احفظ الملف النصي بترميز UTF-8 أو UTF-16.',
  'import_too_large':
      'يتجاوز الملف 10 ميغابايت أو يتجاوز محتواه بعد فك الضغط الحد الآمن.',
  'import_txt_description':
      'يستخرج الاسم والبريد والهاتف والروابط والمهارات المفصولة بفواصل، ويحفظ النص الكامل في الملخص للمراجعة اليدوية.',
  'import_txt_title': 'TXT',
  'import_unsupported': 'اختر ملف JSON أو PDF أو TXT.',
  'export_json_description':
      'احفظ أو شارك نسخة JSON كاملة تشمل الأقسام والتخصيص، ويمكن استيرادها لاحقاً. مسار الصورة مرجع محلي وليس صورة مضمّنة.',
  'export_json_extension': 'اختر اسم ملف ينتهي بالامتداد .json.',
  'export_json_invalid': 'تحتوي السيرة على بيانات لا يمكن تصديرها بصيغة JSON.',
  'export_json_save': 'حفظ ملف JSON',
  'export_json_save_failed':
      'تعذر حفظ JSON. تحقق من موقع الحفظ والمساحة المتاحة.',
  'export_json_saved': 'تم حفظ ملف JSON بنجاح.',
  'export_json_share': 'مشاركة ملف JSON',
  'export_json_share_failed': 'تعذرت مشاركة JSON. تحقق من توفر تطبيق للمشاركة.',
  'export_json_shared': 'تم تمرير ملف JSON إلى نافذة المشاركة.',
  'export_json_too_large':
      'يتجاوز JSON حد الاستيراد البالغ 10 ميغابايت. قلّل المحتوى قبل التصدير.',
  'export_no_resume': 'افتح سيرة أو أنشئ واحدة قبل التصدير.',
};

```

## test/export_resume/export_service_test.dart

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cv_builder_pro/core/services/resume_export_service.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/data/index.dart';

class _Picker extends FilePicker {
  String? destination;
  Uint8List? received;
  String? proposedName;
  bool fail = false;
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    if (fail) throw Exception('picker failure');
    received = bytes;
    proposedName = fileName;
    expect(type, FileType.custom);
    expect(allowedExtensions, ['json']);
    return destination;
  }
}

class _MobileService extends ResumeExportService {
  _MobileService(FilePicker picker) : super(picker: picker);
  @override
  bool get pickerWritesBytes => true;
}

Matcher _error(String key) => throwsA(
  isA<ExportException>().having((error) => error.messageKey, 'messageKey', key),
);

void main() {
  late Directory directory;
  late _Picker picker;
  late ResumeExportService service;
  final resume = ResumeModel(
    fullName: 'عمر',
    id: 12,
    email: 'omer@example.com',
    phone: '+966500000000',
    profilePicture: '/local/photo.jpg',
    summary: 'ملخص',
    isFavorite: true,
    templateId: 'ats',
    education: [
      Education(degree: 'BSc', institution: 'University', year: '2024'),
    ],
    experience: [
      Experience(
        jobTitle: 'Developer',
        company: 'Company',
        startDate: '01/2024',
      ),
    ],
    skills: [Skill(name: 'Dart')],
    courses: [
      Course.fromJson({'name': 'Course'}),
    ],
    certificates: [
      Certificate.fromJson({'name': 'Certificate'}),
    ],
    languages: [
      Language.fromJson({'name': 'English', 'level': 'Advanced'}),
    ],
    projects: [
      Project.fromJson({'name': 'App'}),
    ],
    achievements: [
      Achievement.fromJson({'title': 'Award'}),
    ],
    interests: ['قراءة'],
    linkedin: 'https://linkedin.com/in/test',
    github: 'https://github.com/test',
    website: 'https://example.com',
    portfolio: 'https://example.com/work',
    customization: {'fontSize': 14, 'primaryColor': 4278190080},
  );
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('cv_export_test_');
    picker = _Picker();
    service = ResumeExportService(picker: picker);
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('actual JSON file imports with every field and UTF8 intact', () async {
    picker.destination = '${directory.path}/resume.json';
    final result = await service.saveJson(resume);
    expect(result, picker.destination);
    final bytes = await File(result!).readAsBytes();
    expect(ResumeImportService().fromBytes(bytes, 'json'), resume);
    expect(utf8.decode(bytes), contains('عمر'));
    expect(directory.listSync().whereType<Directory>(), isEmpty);
  });
  test(
    'confirmed destination replaces existing JSON without staging leftovers',
    () async {
      final file = File('${directory.path}/resume.json');
      await file.writeAsString('old data');
      picker.destination = file.path;
      await service.saveJson(resume);
      expect(ResumeJson.decode(await file.readAsString()), resume);
      expect(directory.listSync(), hasLength(1));
    },
  );
  test('picker cancellation writes nothing', () async {
    expect(await service.saveJson(resume), isNull);
    expect(directory.listSync(), isEmpty);
  });
  test(
    'mobile picker receives bytes and content URI is not treated as file path',
    () async {
      picker.destination = 'content://documents/resume';
      final mobile = _MobileService(picker);
      expect(await mobile.saveJson(resume), picker.destination);
      expect(ResumeImportService().fromBytes(picker.received!, 'json'), resume);
    },
  );
  test('picker failure and write failure expose localized errors', () async {
    picker.fail = true;
    await expectLater(
      service.saveJson(resume),
      _error('export_json_save_failed'),
    );
    picker.fail = false;
    final target = await Directory('${directory.path}/occupied.json').create();
    picker.destination = target.path;
    await expectLater(
      service.saveJson(resume),
      _error('export_json_save_failed'),
    );
    expect(await target.exists(), true);
    expect(directory.listSync(), hasLength(1));
  });
  test('desktop export requires JSON extension before writing', () async {
    picker.destination = '${directory.path}/wrong.txt';
    await expectLater(
      service.saveJson(resume),
      _error('export_json_extension'),
    );
    expect(directory.listSync(), isEmpty);
  });
  test(
    'filenames cannot contain paths reserved characters or unbounded names',
    () {
      expect(
        service.fileName(ResumeModel(fullName: '../../CON: / name?')),
        'cv_CON-name.json',
      );
      expect(service.fileName(ResumeModel()), 'cv_resume.json');
      expect(
        service.fileName(ResumeModel(fullName: 'a' * 1000)).length,
        lessThan(80),
      );
      expect(service.fileName(resume), contains('عمر'));
    },
  );
  test(
    'sharing uses actual JSON file bytes filename and iPad origin',
    () async {
      ShareParams? captured;
      final sharer = ResumeExportService(
        share: (params) async {
          captured = params;
          return const ShareResult('ok', ShareResultStatus.success);
        },
      );
      final result = await sharer.shareJson(
        resume,
        origin: const Rect.fromLTWH(10, 10, 100, 48),
      );
      expect(result.status, ShareResultStatus.success);
      expect(captured!.fileNameOverrides, [service.fileName(resume)]);
      expect(captured!.sharePositionOrigin!.width, 100);
      expect(
        ResumeImportService().fromBytes(
          await captured!.files!.single.readAsBytes(),
          'json',
        ),
        resume,
      );
    },
  );
  test('sharing cancellation is preserved and failures are wrapped', () async {
    final cancelled = ResumeExportService(
      share: (_) async => const ShareResult('', ShareResultStatus.dismissed),
    );
    expect(
      (await cancelled.shareJson(resume, origin: Rect.zero)).status,
      ShareResultStatus.dismissed,
    );
    final failed = ResumeExportService(
      share: (_) async => throw Exception('unavailable'),
    );
    await expectLater(
      failed.shareJson(resume, origin: Rect.zero),
      _error('export_json_share_failed'),
    );
  });
  test('oversized and non JSON customization data fail before writing', () {
    expect(
      () => service.toBytes(ResumeModel(summary: 'a' * (10 * 1024 * 1024))),
      _error('export_json_too_large'),
    );
    expect(
      () => service.toBytes(ResumeModel(customization: {'value': double.nan})),
      _error('export_json_invalid'),
    );
  });
}

```

## test/export_resume/export_button_test.dart

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/core/services/resume_export_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Service extends ResumeExportService {
  ResumeModel? captured;
  String? path = '/saved/resume.json';
  int saves = 0;
  bool fail = false;
  Completer<String?>? pending;
  ShareResultStatus status = ShareResultStatus.success;
  @override
  Future<String?> saveJson(ResumeModel resume) async {
    saves++;
    captured = resume;
    if (fail) throw const ExportException('export_json_save_failed');
    return pending == null ? path : pending!.future;
  }

  @override
  Future<ShareResult> shareJson(
    ResumeModel resume, {
    required Rect origin,
  }) async {
    captured = resume;
    expect(origin.width, greaterThan(0));
    return ShareResult('', status);
  }
}

Widget _host(
  _Service service,
  ResumeModel? resume, {
  double scale = 1,
  bool arabic = false,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: arabic ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: Scaffold(
    appBar: AppBar(
      actions: [ResumeJsonExportButton(resume: () => resume, service: service)],
    ),
  ),
);
Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byTooltip('export_json'.tr));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 800.0, 1920.0]) {
    testWidgets('export dialog fits $width with Arabic large text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        _host(_Service(), ResumeModel(fullName: 'عمر'), scale: 2, arabic: true),
      );
      await _open(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('share-resume-json')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('save exports a snapshot including unpersisted edits', (
    tester,
  ) async {
    final resume = ResumeModel(
      fullName: 'Draft',
      skills: [Skill(name: 'Dart')],
    );
    final service = _Service();
    await tester.pumpWidget(_host(service, resume));
    await _open(tester);
    resume.fullName = 'Changed later';
    resume.skills.clear();
    await _tap(tester, 'save-resume-json');
    expect(service.captured!.fullName, 'Draft');
    expect(service.captured!.skills.single.name, 'Dart');
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('export_json_saved'.tr), findsOneWidget);
  });
  testWidgets('cancelled picker keeps dialog open without success message', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_Service()..path = null, ResumeModel()));
    await _open(tester);
    await _tap(tester, 'save-resume-json');
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('export_json_saved'.tr), findsNothing);
  });
  testWidgets('errors appear inside dialog and retry succeeds', (tester) async {
    final service = _Service()..fail = true;
    await tester.pumpWidget(_host(service, ResumeModel()));
    await _open(tester);
    await _tap(tester, 'save-resume-json');
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('export_json_save_failed'.tr),
      ),
      findsOneWidget,
    );
    service.fail = false;
    await _tap(tester, 'save-resume-json');
    expect(find.byType(Dialog), findsNothing);
  });
  testWidgets('sharing dismiss stays open and success closes dialog', (
    tester,
  ) async {
    final service = _Service()..status = ShareResultStatus.dismissed;
    await tester.pumpWidget(_host(service, ResumeModel()));
    await _open(tester);
    await _tap(tester, 'share-resume-json');
    expect(find.byType(Dialog), findsOneWidget);
    service.status = ShareResultStatus.success;
    await _tap(tester, 'share-resume-json');
    expect(find.byType(Dialog), findsNothing);
  });
  testWidgets('no resume reports feedback without opening export', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_Service(), null));
    await _open(tester);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('export_no_resume'.tr), findsOneWidget);
  });
  testWidgets('pending export blocks duplicate save and other actions', (
    tester,
  ) async {
    final service = _Service()..pending = Completer<String?>();
    await tester.pumpWidget(_host(service, ResumeModel()));
    await _open(tester);
    await tester.tap(find.byKey(const ValueKey('save-resume-json')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('save-resume-json')));
    await tester.pump();
    expect(service.saves, 1);
    final share = tester.widget<OutlinedButton>(
      find.descendant(
        of: find.byKey(const ValueKey('share-resume-json')),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(share.onPressed, isNull);
    service.pending!.complete('/saved/resume.json');
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}

```
