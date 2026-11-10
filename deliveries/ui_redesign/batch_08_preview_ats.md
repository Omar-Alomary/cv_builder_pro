# UI/UX — Batch 8: Preview + ATS Checker
اكتملت إعادة تصميم المعاينة وفحص ATS ضمن طبقة العرض فقط. لم تتغير خدمات توليد PDF والتصدير أو محلل ATS أو المتحكمات أو النماذج أو المستودع أو الترجمات أو الاعتماديات.
المعاينة: إطار بزوايا 24 وحدود وخلفية مناسبة للوضعين، بطاقة للخيارات والإجراءات، وبطاقة للتخصيص مع عنوان موحد. أزرار تصدير PDF والطباعة والمشاركة تحمل أيقونات وتدرج الهوية. بقيت أدوات الجودة وتصدير JSON وفحص ATS ظاهرة، وتظهر لوحة التخصيص بجانب المستند على التابلت وسطح المكتب ومن زر التخصيص على الجوال. تستخدم حالات التوليد AppLoading المشترك مع Shimmer عند السماح بالحركة وبديل ثابت عند تقليلها؛ تبقى إعادة المحاولة ورسائل الخطأ فعالة.
حُفظ عزل خيارات التخصيص عن السيرة الأصلية، واسترجاعها وحفظها، وتأكيد التغييرات عند الخروج، وإلغاء نتائج التوليد الأقدم، وتصدير الإعدادات الحالية غير المحفوظة، والتعامل مع إلغاء الحفظ والطباعة والمشاركة. بقي قالب ATS ذا إعدادات ثابتة دون لوحة تخصيص. بقيت ألوان التخصيص السابقة نفسها لأنها خيارات محتوى للمستخدم.
فحص ATS: مؤشر CustomPaint دائري متدرج يتغير لونه بحسب النتيجة من الأحمر إلى البرتقالي والأصفر ثم الأخضر، مع قيمة رقمية ومكافئ مقروء بقارئ الشاشة. تظهر درجات الأقسام السبعة كأشرطة تقدم وقيم نصية فعلية، وتتكيف تسميات الأقسام مع تكبير النص. البطاقات مرتبة بالخطورة كما في السابق، مع أيقونات وألوان مستقلة للمشكلة الحرجة والتنبيه والمعلومة، وأزرار الانتقال للتحرير. الاقتراحات والكلمات المفقودة تستخدم سطح النظام الجديد. بقي اختيار السيرة والتحرير وإعادة الفحص وتطبيق قالب ATS والحفظ ورسائل الخطأ دون تغيير في المنطق.
التحقق: flutter analyze دون ملاحظات، وجميع اختبارات المشروع الـ518 ناجحة، ومنها اختبارات الإجراءات السابقة الـ23. عُدل محدد زر إلغاء منتقي اللون في اختبار واحد من TextButton إلى AppButton ليتوافق مع مظهر الإطار الجديد؛ لا يزال الاختبار يفتح النافذة ويلغيها ويتحقق من إغلاقها. أضيفت 46 حالة: 40 حالة للشاشتين عند عروض 320/390/600/1024/1920 مع اللغتين والوضعين وتكبير النص 200%، و5 حالات لحدود المؤشر ودلالاته عند عرض ضيق ونص كبير، وحالة تحميل PDF حتى اكتمال التوليد مع تقليل الحركة. يشمل عرض 1024 وضعاً أفقياً بارتفاع 480.
المعاينات: ولّد الاختبار ملفي PDF فعليين من PdfService بالعربية والإنجليزية، ثم حُولت الصفحة الأولى إلى صورة للمراجعة. تستخدم لقطات واجهة الاختبار هذه الصور داخل previewBuilder المتاح مسبقاً؛ لا تمثل اختباراً لمشغل PDF الأصلي أو نافذة الطباعة على الجهاز، ولا تتبدل الصورة الثابتة مع خيارات اختبار التخصيص. يبقى عرض التطبيق الإنتاجي عبر PdfPreview وprinting كما هو. لم يُكرر التشغيل على جهاز فعلي في هذه الدفعة.
## المعاينات
[preview — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_08_preview_light_en_390.png)
[preview — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_08_preview_light_en_1920.png)
[preview — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_08_preview_dark_ar_390.png)
[preview — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_08_preview_dark_ar_1920.png)
[ats — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_08_ats_light_en_390.png)
[ats — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_08_ats_light_en_1920.png)
[ats — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_08_ats_dark_ar_390.png)
[ats — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_08_ats_dark_ar_1920.png)
## إعادة توليد صور المراجعة فقط
الاختبارات العادية لا تحتاج صور PNG أو أداة التحويل. لتكرار الصور، نفذ من جذر المشروع:
```text
flutter test --no-pub test/pdf/redesign_preview_ats_test.dart --plain-name "write actual PDF fixtures" --dart-define=GENERATE_PDF_FIXTURES=true
pdftoppm -f 1 -singlefile -scale-to 1200 -png tmp/ui_redesign/batch_08_pdf_en.pdf tmp/ui_redesign/batch_08_pdf_en
pdftoppm -f 1 -singlefile -scale-to 1200 -png tmp/ui_redesign/batch_08_pdf_ar.pdf tmp/ui_redesign/batch_08_pdf_ar
flutter test --no-pub test/pdf/redesign_preview_ats_test.dart --dart-define=WRITE_UI_PREVIEWS=true
```
pdftoppm أداة مراجعة خارج التطبيق، وليست اعتمادية Flutter جديدة.
## الملفات كاملة
1. lib/features/resume_builder/presentation/pages/preview_screen.dart
2. lib/features/resume_builder/presentation/widgets/customization_panel.dart
3. lib/features/resume_builder/presentation/widgets/pdf_preview_view.dart
4. lib/features/ats_checker/presentation/pages/ats_checker_screen.dart
5. lib/features/ats_checker/presentation/widgets/ats_score_gauge.dart
6. lib/features/ats_checker/presentation/widgets/ats_issues_list.dart
7. lib/features/ats_checker/presentation/widgets/ats_suggestions_card.dart
8. test/pdf/preview_screen_test.dart
9. test/pdf/redesign_preview_ats_test.dart

## lib/features/resume_builder/presentation/pages/preview_screen.dart
```dart
import '../../../../app/theme/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../templates/pdf_template_options.dart';
import '../widgets/customization_panel.dart';
import '../widgets/pdf_preview_view.dart';
import '../widgets/resume_json_export_button.dart';

/// Responsive PDF workspace with isolated appearance drafts and guarded exports.
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, this.exportService, this.previewBuilder});
  final PdfExportService? exportService;
  final Widget Function(Uint8List)? previewBuilder;
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final _resumes = Get.find<ResumeController>();
  late final _export = widget.exportService ?? PdfExportService();
  late PdfTemplateOptions _options;
  late PdfTemplateOptions _baseline;
  PdfExportQuality _quality = PdfExportQuality.standard;
  Uint8List? _bytes;
  ResumeModel? _rendered;
  bool _generating = false;
  bool _working = false;
  bool _showCustomization = false;
  bool _allowPop = false;
  bool _leaving = false;
  int _generation = 0;
  String? _error;
  bool get _ats => _resumes.currentResume.value?.templateId == 'ats';
  bool get _dirty => !_ats && _options != _baseline;
  @override
  void initState() {
    super.initState();
    _loadOptions();
    unawaited(_refresh());
  }

  void _loadOptions() {
    _options = PdfTemplateOptions.fromJson(
      _resumes.currentResume.value?.customization,
    );
    _baseline = _options;
  }

  ResumeModel? _snapshot() {
    final resume = _resumes.currentResume.value;
    if (resume == null) return null;
    return _ats
        ? resume.copyWith()
        : resume.copyWith(
            customization: {...?resume.customization, ..._options.toJson()},
          );
  }

  Future<void> _refresh() async {
    final snapshot = _snapshot();
    final generation = ++_generation;
    if (snapshot == null) return;
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final bytes = await _export.generate(
        snapshot,
        locale: Get.locale?.languageCode ?? 'en',
        quality: _quality,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _bytes = bytes;
        _rendered = snapshot;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _bytes = null;
        _error = error is PdfExportException
            ? error.messageKey
            : 'pdf_generation_failed';
      });
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _generating = false);
      }
    }
  }

  Future<void> _save() async {
    if (_working || !_dirty) return;
    final original = _resumes.currentResume.value;
    final candidate = _snapshot();
    if (candidate == null) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      if (!await _resumes.saveResume(candidate)) {
        if (mounted) setState(() => _error = 'pdf_customization_save_failed');
        return;
      }
      if (!mounted || !identical(original, _resumes.currentResume.value)) {
        return;
      }
      _resumes.currentResume.value = candidate;
      _resumes.isEditing.value = candidate.id != null;
      setState(() => _baseline = _options);
      AppSnackbar.success(context, 'customization_saved'.tr);
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _error = 'pdf_customization_save_failed');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _reset() {
    setState(() {
      _options = _baseline;
      _error = null;
    });
    unawaited(_refresh());
  }

  Future<void> _leave() async {
    if (_working || _leaving || !Navigator.of(context).canPop()) return;
    _leaving = true;
    try {
      if (_dirty) {
        final choice = await showDialog<String>(
          context: context,
          builder: (context) => Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.icon),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('pdf_leave_changes'.tr),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      key: const ValueKey('preview-leave-save'),
                      label: 'save'.tr,
                      onPressed: () => Navigator.of(context).pop('save'),
                    ),
                    AppButton(
                      key: const ValueKey('preview-leave-discard'),
                      label: 'pdf_discard_changes'.tr,
                      variant: AppButtonVariant.text,
                      onPressed: () => Navigator.of(context).pop('discard'),
                    ),
                    AppButton(
                      label: 'cancel'.tr,
                      variant: AppButtonVariant.text,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        if (!mounted || choice == null) return;
        if (choice == 'save') {
          await _save();
          if (!mounted || _dirty) return;
        }
      }
      if (!mounted) return;
      setState(() => _allowPop = true);
      await Future<void>.delayed(Duration.zero);
      if (mounted) Navigator.of(context).pop();
    } finally {
      _leaving = false;
    }
  }

  Future<void> _atsCheck() async {
    final previous = _resumes.currentResume.value?.templateId;
    await Get.toNamed<void>(AppRoutes.atsChecker);
    if (!mounted) return;
    if (previous != _resumes.currentResume.value?.templateId) {
      setState(_loadOptions);
    }
    await _refresh();
  }

  Future<void> _output(String action, BuildContext anchor) async {
    if (_working || _generating) return;
    final snapshot = _snapshot();
    if (snapshot == null) return;
    final box = anchor.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final bytes = await _export.generate(
        snapshot,
        locale: Get.locale?.languageCode ?? 'en',
        quality: _quality,
      );
      if (!mounted) return;
      final name = _export.fileName(snapshot.fullName);
      String? message;
      if (action == 'save') {
        if (await _export.savePdf(bytes, name: name) != null) {
          message = 'pdf_saved';
        }
      } else if (action == 'print') {
        if (await _export.printPdf(bytes, name: name)) {
          message = 'pdf_print_submitted';
        }
      } else {
        final result = await _export.sharePdf(
          bytes,
          name: name,
          origin: origin,
        );
        if (result.status != ShareResultStatus.dismissed) {
          message = 'pdf_share_opened';
        }
      }
      if (mounted && message != null) AppSnackbar.info(context, message.tr);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is PdfExportException
              ? error.messageKey
              : 'pdf_export_failed',
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Widget _previewFrame() => Padding(
    padding: const EdgeInsets.all(AppSpacing.sm),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: _preview(),
      ),
    ),
  );
  Widget _preview() {
    if (_generating) return AppLoading(message: 'pdf_preview_loading'.tr);
    if (_bytes == null) {
      return AppEmptyState(
        title: (_error ?? 'failed_to_generate_preview').tr,
        actionLabel: 'retry'.tr,
        onAction: () {
          unawaited(_refresh());
        },
      );
    }
    return widget.previewBuilder?.call(_bytes!) ??
        PdfPreviewView(
          bytes: _bytes!,
          onRetry: () {
            unawaited(_refresh());
          },
        );
  }

  Widget _panel() => AppCard(
    padding: EdgeInsets.zero,
    child: CustomizationPanel(
      options: _options,
      enabled: !_working,
      dirty: _dirty,
      onChanged: (value) => setState(() => _options = value),
      onSave: _save,
      onReset: _reset,
      onPreview: _refresh,
    ),
  );
  @override
  Widget build(BuildContext context) {
    final missing = _resumes.currentResume.value == null;
    return PopScope(
      canPop: _allowPop || (!_dirty && !_working),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('preview'.tr),
          leading: BackButton(onPressed: _leave),
          actions: [
            if (!missing && !_ats && Responsive.isMobile(context))
              IconButton(
                key: const ValueKey('toggle-customization'),
                tooltip: 'customize_resume'.tr,
                icon: const Icon(Icons.tune),
                onPressed: _working
                    ? null
                    : () => setState(
                        () => _showCustomization = !_showCustomization,
                      ),
              ),
          ],
        ),
        body: SafeArea(
          child: Responsive.maxWidth(
            child: missing
                ? AppEmptyState(title: 'export_no_resume'.tr)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final actions = Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AppButton(
                              key: const ValueKey('preview-check-ats'),
                              label: 'ats_checker'.tr,
                              icon: Icons.fact_check_outlined,
                              onPressed: _working ? null : _atsCheck,
                            ),
                            ResumeJsonExportButton(
                              key: const ValueKey('preview-export-json'),
                              resume: _snapshot,
                            ),
                            for (final action in ['save', 'print', 'share'])
                              Builder(
                                builder: (anchor) => AppButton(
                                  key: ValueKey('preview-$action-pdf'),
                                  label:
                                      (action == 'save'
                                              ? 'export_pdf'
                                              : action == 'print'
                                              ? 'print_pdf'
                                              : 'share_pdf')
                                          .tr,
                                  icon: action == 'save'
                                      ? Icons.download_outlined
                                      : action == 'print'
                                      ? Icons.print_outlined
                                      : Icons.share_outlined,
                                  onPressed: _working || _generating
                                      ? null
                                      : () => _output(action, anchor),
                                ),
                              ),
                          ],
                        ),
                      );
                      final controls = Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              actions,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    Text('pdf_quality'.tr),
                                    for (final quality
                                        in PdfExportQuality.values)
                                      ChoiceChip(
                                        key: ValueKey(
                                          'pdf-quality-${quality.name}',
                                        ),
                                        label: Text(
                                          'pdf_quality_${quality.name}'.tr,
                                        ),
                                        selected: _quality == quality,
                                        onSelected: _working
                                            ? null
                                            : (_) {
                                                setState(
                                                  () => _quality = quality,
                                                );
                                                unawaited(_refresh());
                                              },
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Text(
                                  (_ats
                                          ? 'pdf_ats_fixed_note'
                                          : 'pdf_quality_note')
                                      .tr,
                                ),
                              ),
                              if (_rendered != null &&
                                  _rendered != _snapshot() &&
                                  !_generating)
                                Padding(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  child: Text('pdf_preview_outdated'.tr),
                                ),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  child: Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      _error!.tr,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                      if (Responsive.isTabletOrLarger(context)) {
                        return Row(
                          key: const ValueKey('preview-side-by-side'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: math.min(360, constraints.maxWidth * .44),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: controls,
                                    ),
                                  ),
                                  if (!_ats) Expanded(child: _panel()),
                                ],
                              ),
                            ),
                            Expanded(child: _previewFrame()),
                          ],
                        );
                      }
                      return SingleChildScrollView(
                        key: const ValueKey('preview-mobile-scroll'),
                        child: Column(
                          children: [
                            controls,
                            if (_showCustomization && !_ats)
                              SizedBox(
                                height: math.max(
                                  320,
                                  constraints.maxHeight * .65,
                                ),
                                child: _panel(),
                              ),
                            SizedBox(
                              height: math.max(320, constraints.maxHeight * .7),
                              child: _previewFrame(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }
}

```

## lib/features/resume_builder/presentation/widgets/customization_panel.dart
```dart
import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../../../../shared_widgets/index.dart';
import '../templates/pdf_template_options.dart';

/// Scrollable customization controls editing a draft instead of persisted data.
class CustomizationPanel extends StatelessWidget {
  const CustomizationPanel({
    super.key,
    required this.options,
    required this.onChanged,
    required this.onSave,
    required this.onReset,
    required this.onPreview,
    this.enabled = true,
    this.dirty = false,
  });
  final PdfTemplateOptions options;
  final ValueChanged<PdfTemplateOptions> onChanged;
  final Future<void> Function() onSave;
  final VoidCallback onReset;
  final Future<void> Function() onPreview;
  final bool enabled;
  final bool dirty;
  Future<void> _choose(BuildContext context, bool primary) async {
    var color = Color(primary ? options.primaryColor : options.secondaryColor);
    final result = await showDialog<Color>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text((primary ? 'primary_color' : 'secondary_color').tr),
                ColorPicker(
                  pickerColor: color,
                  onColorChanged: (value) => color = value,
                  enableAlpha: false,
                  colorPickerWidth:
                      MediaQuery.sizeOf(context).width.clamp(240, 400) - 64,
                ),
                AppButton(
                  label: 'save'.tr,
                  onPressed: () => Navigator.of(context).pop(color),
                ),
                AppButton(
                  label: 'cancel'.tr,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && context.mounted) {
      onChanged(
        primary
            ? options.copyWith(primaryColor: result.toARGB32())
            : options.copyWith(secondaryColor: result.toARGB32()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const ValueKey('customization-scroll'),
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: 'customize_resume'.tr),
        const SizedBox(height: AppSpacing.lg),
        for (final primary in [true, false]) ...[
          Text((primary ? 'primary_color' : 'secondary_color').tr),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final color in [
                0xff1565c0,
                0xff00695c,
                0xff6a1b9a,
                0xff212121,
              ])
                IconButton(
                  key: ValueKey(
                    'color-${primary ? 'primary' : 'secondary'}-$color',
                  ),
                  tooltip:
                      '${(primary ? 'primary_color' : 'secondary_color').tr} #${color.toRadixString(16).substring(2)}',
                  isSelected:
                      color ==
                      (primary ? options.primaryColor : options.secondaryColor),
                  icon: Icon(Icons.circle, color: Color(color)),
                  selectedIcon: Icon(Icons.check_circle, color: Color(color)),
                  onPressed: enabled
                      ? () => onChanged(
                          primary
                              ? options.copyWith(primaryColor: color)
                              : options.copyWith(secondaryColor: color),
                        )
                      : null,
                ),
            ],
          ),
          AppButton(
            key: ValueKey('custom-color-${primary ? 'primary' : 'secondary'}'),
            label: 'pdf_custom_color'.tr,
            variant: AppButtonVariant.outlined,
            onPressed: enabled ? () => _choose(context, primary) : null,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text('font_family'.tr),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final family in ['Cairo', 'Sukar', 'Poppins'])
              ChoiceChip(
                key: ValueKey('font-$family'),
                label: Text(family),
                selected: options.fontFamily == family,
                onSelected: enabled
                    ? (_) => onChanged(options.copyWith(fontFamily: family))
                    : null,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('pdf_arabic_font_note'.tr),
        const SizedBox(height: AppSpacing.lg),
        Text('${'font_size'.tr}: ${options.fontSize.toStringAsFixed(0)}'),
        Slider(
          key: const ValueKey('preview-font-size'),
          value: options.fontSize.clamp(8, 16),
          min: 8,
          max: 16,
          divisions: 8,
          label: options.fontSize.toStringAsFixed(0),
          onChanged: enabled
              ? (value) => onChanged(options.copyWith(fontSize: value))
              : null,
        ),
        if (dirty) Text('pdf_unsaved_changes'.tr),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          key: const ValueKey('update-pdf-preview'),
          label: 'update_preview'.tr,
          icon: Icons.refresh,
          fullWidth: true,
          onPressed: enabled ? onPreview : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          key: const ValueKey('save-customization'),
          label: 'save'.tr,
          icon: Icons.save_outlined,
          fullWidth: true,
          onPressed: enabled && dirty ? onSave : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          key: const ValueKey('reset-customization'),
          label: 'pdf_revert_changes'.tr,
          fullWidth: true,
          variant: AppButtonVariant.secondary,
          onPressed: enabled && dirty ? onReset : null,
        ),
      ],
    ),
  );
}

```

## lib/features/resume_builder/presentation/widgets/pdf_preview_view.dart
```dart
import '../../../../app/theme/index.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../shared_widgets/index.dart';

/// A4 preview with native actions delegated to the guarded export service.
class PdfPreviewView extends StatelessWidget {
  const PdfPreviewView({super.key, required this.bytes, required this.onRetry});
  final Uint8List bytes;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => PdfPreview(
    build: (_) async => bytes,
    initialPageFormat: PdfPageFormat.a4,
    canChangePageFormat: false,
    canChangeOrientation: false,
    canDebug: false,
    useActions: false,
    allowPrinting: false,
    allowSharing: false,
    previewPageMargin: const EdgeInsets.all(AppSpacing.sm),
    loadingWidget: AppLoading(message: 'pdf_preview_loading'.tr),
    onError: (_, error) => AppEmptyState(
      title: 'failed_to_generate_preview'.tr,
      actionLabel: 'retry'.tr,
      onAction: onRetry,
    ),
  );
}

```

## lib/features/ats_checker/presentation/pages/ats_checker_screen.dart
```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/ats_controller.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/ats_scorer.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/ats_score_gauge.dart';
import '../widgets/ats_issues_list.dart';
import '../widgets/ats_suggestions_card.dart';

/// Checks the current draft or a selected saved resume without mutating it.
class ATSCheckerScreen extends StatefulWidget {
  const ATSCheckerScreen({super.key});
  @override
  State<ATSCheckerScreen> createState() => _ATSCheckerScreenState();
}

class _ATSCheckerScreenState extends State<ATSCheckerScreen> {
  final _ats = Get.find<AtsController>();
  final _resumes = Get.find<ResumeController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ats.analyze();
    });
  }

  Future<void> _edit() async {
    await _ats.editResume();
    if (mounted) _ats.analyze();
  }

  Future<void> _choose() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.value<double>(
              context: dialogContext,
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
                Text(
                  'ats_choose_resume'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_resumes.resumes.isEmpty) Text('no_resumes_found'.tr),
                      for (final resume in _resumes.getRecentResumes(
                        limit: _resumes.resumes.length,
                      ))
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppButton(
                            key: ValueKey('ats-select-${resume.id}'),
                            label: resume.fullName.trim().isEmpty
                                ? 'untitled_resume'.tr
                                : resume.fullName,
                            fullWidth: true,
                            onPressed: () {
                              _resumes.currentResume.value = resume.copyWith();
                              _ats.analyze();
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'cancel'.tr,
                  variant: AppButtonVariant.text,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Scaffold(
      appBar: AppBar(
        title: Text('ats_checker'.tr),
        toolbarHeight:
            AppSpacing.touchTarget +
            AppSpacing.sm +
            math.max(0, scale - 1) * AppSpacing.xxl,
      ),
      body: SafeArea(
        child: Responsive.maxWidth(
          child: SingleChildScrollView(
            key: const ValueKey('ats-scroll'),
            padding: Responsive.pagePadding(context),
            child: Obx(() {
              final resume = _resumes.currentResume.value;
              final result = _ats.result.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    key: const ValueKey('ats-choose-resume'),
                    label: 'ats_choose_resume'.tr,
                    icon: Icons.folder_open,
                    onPressed: _ats.isApplyingTemplate.value ? null : _choose,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('ats_guidance'.tr),
                  const SizedBox(height: AppSpacing.sm),
                  Text('ats_formatting_note'.tr),
                  if (resume != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      resume.fullName.trim().isEmpty
                          ? 'untitled_resume'.tr
                          : resume.fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                  if (_ats.errorMessage.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _ats.errorMessage.value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  if (_ats.isAnalyzing.value)
                    AppLoading(message: 'ats_checking'.tr)
                  else if (result != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Builder(
                      builder: (context) {
                        final summary = AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AtsScoreGauge(score: result.overallScore),
                              const SizedBox(height: AppSpacing.xl),
                              for (final entry in result.sectionScores.entries)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.lg,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        spacing: AppSpacing.sm,
                                        runSpacing: AppSpacing.xs,
                                        children: [
                                          Text(
                                            'ats_section_${entry.key}'.tr,
                                            style: AppTextStyles.resolve(
                                              context,
                                              AppTextStyles.bodySmall,
                                            ),
                                          ),
                                          Text(
                                            '${entry.value}/${AtsScorer.sectionMaximums[entry.key]}',
                                            style: AppTextStyles.resolve(
                                              context,
                                              AppTextStyles.label,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      LinearProgressIndicator(
                                        key: ValueKey(
                                          'ats-section-progress-${entry.key}',
                                        ),
                                        value:
                                            (entry.value /
                                                    (AtsScorer
                                                            .sectionMaximums[entry
                                                            .key] ??
                                                        1))
                                                .clamp(0.0, 1.0),
                                        minHeight: AppSpacing.sm,
                                        borderRadius: AppRadii.chip,
                                        semanticsLabel:
                                            'ats_section_${entry.key}'.tr,
                                        semanticsValue:
                                            '${entry.value}/${AtsScorer.sectionMaximums[entry.key]}',
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                        final issues = AtsIssuesList(
                          issues: result.issues,
                          onEdit: _edit,
                        );
                        if (Responsive.isTabletOrLarger(context)) {
                          return Row(
                            key: const ValueKey('ats-wide-layout'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: summary),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(flex: 2, child: issues),
                            ],
                          );
                        }
                        return Column(
                          key: const ValueKey('ats-mobile-layout'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            summary,
                            const SizedBox(height: AppSpacing.lg),
                            issues,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AtsSuggestionsCard(
                      suggestions: result.suggestions,
                      missingKeywords: result.missingKeywords,
                      onEdit: _edit,
                    ),
                  ],
                  if (resume == null)
                    AppEmptyState(
                      title: 'ats_no_resume'.tr,
                      actionLabel: 'create_resume'.tr,
                      onAction: () async {
                        await Get.toNamed<void>(AppRoutes.resumeBuilder);
                        if (mounted) _ats.analyze();
                      },
                    ),
                  if (resume != null) ...[
                    const SizedBox(height: AppSpacing.icon),
                    AppButton(
                      key: const ValueKey('ats-recheck'),
                      label: 'ats_recheck'.tr,
                      icon: Icons.refresh,
                      fullWidth: true,
                      onPressed: _ats.isApplyingTemplate.value
                          ? null
                          : () {
                              _ats.analyze();
                            },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: const ValueKey('ats-use-template'),
                      label: 'ats_use_template'.tr,
                      icon: Icons.description_outlined,
                      fullWidth: true,
                      isLoading: _ats.isApplyingTemplate.value,
                      onPressed: () async {
                        final saved = await _ats.useAtsTemplate();
                        if (saved && context.mounted) {
                          AppSnackbar.success(
                            context,
                            'ats_template_applied'.tr,
                          );
                        }
                      },
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

```

## lib/features/ats_checker/presentation/widgets/ats_score_gauge.dart
```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';

/// Gradient score ring with a readable numeric and spoken equivalent.
class AtsScoreGauge extends StatelessWidget {
  const AtsScoreGauge({super.key, required this.score});
  final int score;
  @override
  Widget build(BuildContext context) {
    final value = score.clamp(0, 100);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'ats_score_out_of'.trParams({'score': '$value'}),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ats_score'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.resolve(context, AppTextStyles.h4),
            ),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = math.min(
                  AppSpacing.xxxl * 5,
                  constraints.maxWidth,
                );
                return SizedBox.square(
                  dimension: width,
                  child: CustomPaint(
                    painter: _GaugePainter(value, scheme.outlineVariant),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$value',
                            style: AppTextStyles.resolve(
                              context,
                              AppTextStyles.display,
                            ).copyWith(color: scheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'ats_score_out_of'.trParams({'score': '$value'}),
              textAlign: TextAlign.center,
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.bodySmall,
              ).copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter(this.score, this.background);
  final int score;
  final Color background;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(AppSpacing.md);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.md
      ..strokeCap = StrokeCap.round
      ..color = background;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, paint);
    if (score <= 0) return;
    final orange = Color.lerp(AppColors.error, AppColors.accent, .5)!;
    final tone = score < 25
        ? Color.lerp(AppColors.error, orange, score / 25)!
        : score < 50
        ? Color.lerp(orange, AppColors.accent, (score - 25) / 25)!
        : Color.lerp(
            AppColors.accent,
            AppColors.success,
            ((score - 50) / 25).clamp(0.0, 1.0),
          )!;
    paint.shader = SweepGradient(
      transform: const GradientRotation(-math.pi / 2),
      colors: [tone, Color.lerp(tone, AppColors.lightSurface, .2)!, tone],
    ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * score / 100, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      score != oldDelegate.score || background != oldDelegate.background;
}

```

## lib/features/ats_checker/presentation/widgets/ats_issues_list.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/ats_score_model.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Findings sorted by severity, each with a direct editing action.
class AtsIssuesList extends StatelessWidget {
  const AtsIssuesList({super.key, required this.issues, required this.onEdit});
  final List<AtsIssue> issues;
  final Future<void> Function() onEdit;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color severityColor(String severity) => switch (severity) {
      'critical' => scheme.error,
      'warning' =>
        Theme.of(context).brightness == Brightness.dark
            ? AppColors.accent
            : AppColors.warningForeground,
      _ => scheme.primary,
    };
    final sorted = [
      for (final severity in AtsIssue.severities)
        ...issues.where((issue) => issue.severity == severity),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: 'ats_issues'.tr),
        const SizedBox(height: AppSpacing.md),
        if (sorted.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('ats_no_issues'.tr),
          ),
        for (var index = 0; index < sorted.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              key: ValueKey('ats-issue-$index'),
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Icon(
                          sorted[index].severity == 'critical'
                              ? Icons.error_outline
                              : sorted[index].severity == 'warning'
                              ? Icons.warning_amber_outlined
                              : Icons.info_outline,
                          color: severityColor(sorted[index].severity),
                        ),
                        Text(
                          'ats_severity_${sorted[index].severity}'.tr,
                          style: TextStyle(
                            color: severityColor(sorted[index].severity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('ats_section_${sorted[index].category}'.tr),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(sorted[index].description),
                    const SizedBox(height: AppSpacing.sm),
                    Text(sorted[index].suggestion),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: ValueKey('ats-edit-issue-$index'),
                      label: 'ats_edit_resume'.tr,
                      icon: Icons.edit_outlined,
                      fullWidth: true,
                      variant: AppButtonVariant.secondary,
                      onPressed: onEdit,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

```

## lib/features/ats_checker/presentation/widgets/ats_suggestions_card.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared_widgets/index.dart';
import '../../../../app/theme/index.dart';

/// Improvement checklist and missing keyword labels from the current analysis.
class AtsSuggestionsCard extends StatelessWidget {
  const AtsSuggestionsCard({
    super.key,
    required this.suggestions,
    required this.missingKeywords,
    required this.onEdit,
  });
  final List<String> suggestions;
  final List<String> missingKeywords;
  final Future<void> Function() onEdit;
  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: 'ats_suggestions'.tr),
          if (suggestions.isEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('ats_no_issues'.tr),
          ],
          for (final suggestion in suggestions)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text('• $suggestion'),
            ),
          if (missingKeywords.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.icon),
            Text(
              'ats_missing_keywords'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: missingKeywords
                  .map((word) => Chip(label: Text(word)))
                  .toList(),
            ),
          ],
          if (suggestions.isNotEmpty || missingKeywords.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'ats_edit_resume'.tr,
              fullWidth: true,
              onPressed: onEdit,
            ),
          ],
        ],
      ),
    ),
  );
}

```

## test/pdf/preview_screen_test.dart
```dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/core/services/pdf_export_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';

class _Repository implements ResumeRepository {
  bool fail = false;
  int saves = 0;
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw StateError('disk full');
    saves++;
    return resume.copyWith(id: resume.id ?? 1, updatedAt: DateTime(2026, 1, 1));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Export extends PdfExportService {
  bool hold = false;
  bool fail = false;
  bool cancel = false;
  int saves = 0, prints = 0, shares = 0;
  final calls = <ResumeModel>[];
  final pending = <Completer<Uint8List>>[];
  @override
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    PdfExportQuality quality = PdfExportQuality.standard,
  }) async {
    calls.add(resume.copyWith());
    if (fail) throw const PdfExportException('pdf_generation_failed');
    if (hold) {
      final next = Completer<Uint8List>();
      pending.add(next);
      return next.future;
    }
    return Uint8List.fromList([1]);
  }

  @override
  Future<String?> savePdf(Uint8List bytes, {required String name}) async {
    saves++;
    return cancel ? null : 'cv.pdf';
  }

  @override
  Future<bool> printPdf(Uint8List bytes, {required String name}) async {
    prints++;
    return !cancel;
  }

  @override
  Future<ShareResult> sharePdf(
    Uint8List bytes, {
    required String name,
    required Rect origin,
  }) async {
    shares++;
    expect(origin.width, greaterThan(0));
    return ShareResult(
      '',
      cancel ? ShareResultStatus.dismissed : ShareResultStatus.success,
    );
  }
}

ResumeController _prepare(
  _Repository repository, {
  String template = 'modern',
}) {
  final resumes = Get.put(ResumeController(repository: repository));
  resumes.currentResume.value = ResumeModel(
    fullName: 'Draft',
    templateId: template,
    customization: {
      'fontFamily': 'Cairo',
      'fontSize': 11.0,
      'primaryColor': 0xff1565c0,
      'secondaryColor': 0xff546e7a,
      'customExtension': 'retained',
    },
  );
  return resumes;
}

Widget _screen(_Export export) => PreviewScreen(
  exportService: export,
  previewBuilder: (bytes) => Center(child: Text('preview-${bytes.first}')),
);
Widget _host(
  _Export export, {
  bool arabic = false,
  double scale = 1,
  bool navigation = false,
  VoidCallback? applyAts,
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
  home: navigation
      ? Scaffold(
          body: TextButton(
            onPressed: () => Get.toNamed<void>(AppRoutes.preview),
            child: const Text('OPEN'),
          ),
        )
      : _screen(export),
  getPages: [
    GetPage(name: AppRoutes.preview, page: () => _screen(export)),
    GetPage(
      name: AppRoutes.atsChecker,
      page: () => Scaffold(
        body: TextButton(
          onPressed: () {
            applyAts?.call();
            Get.back<void>();
          },
          child: const Text('APPLY ATS'),
        ),
      ),
    ),
  ],
);
Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  testWidgets('appearance is isolated, reverts and saves all extensions', (
    tester,
  ) async {
    final repository = _Repository();
    final resumes = _prepare(repository);
    final original = resumes.currentResume.value!.copyWith();
    final export = _Export();
    await tester.pumpWidget(_host(export));
    await tester.pumpAndSettle();
    await _tap(tester, 'font-Sukar');
    expect(resumes.currentResume.value, original);
    final json = tester.widget<ResumeJsonExportButton>(
      find.byType(ResumeJsonExportButton),
    );
    expect(json.resume()!.customization!['fontFamily'], 'Sukar');
    await _tap(tester, 'reset-customization');
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('font-Cairo')))
          .selected,
      isTrue,
    );
    await _tap(tester, 'font-Poppins');
    await _tap(tester, 'save-customization');
    expect(repository.saves, 1);
    expect(resumes.isEditing.value, isTrue);
    expect(
      resumes.currentResume.value!.customization!['fontFamily'],
      'Poppins',
    );
    expect(
      resumes.currentResume.value!.customization!['customExtension'],
      'retained',
    );
  });
  testWidgets('failed save keeps current resume unchanged and allows retry', (
    tester,
  ) async {
    final repository = _Repository()..fail = true;
    final resumes = _prepare(repository);
    final original = resumes.currentResume.value!.copyWith();
    final export = _Export();
    await tester.pumpWidget(_host(export));
    await tester.pumpAndSettle();
    await _tap(tester, 'font-Sukar');
    await _tap(tester, 'save-customization');
    expect(resumes.currentResume.value, original);
    expect(find.text('pdf_customization_save_failed'.tr), findsOneWidget);
    repository.fail = false;
    await _tap(tester, 'save-customization');
    expect(resumes.currentResume.value!.customization!['fontFamily'], 'Sukar');
  });
  testWidgets('new generation wins when earlier request finishes later', (
    tester,
  ) async {
    _prepare(_Repository());
    final export = _Export()..hold = true;
    await tester.pumpWidget(_host(export));
    await tester.pumpAndSettle();
    expect(export.pending.length, 1);
    await _tap(tester, 'pdf-quality-high');
    expect(export.pending.length, 2);
    export.pending[1].complete(Uint8List.fromList([2]));
    await tester.pumpAndSettle();
    expect(find.text('preview-2'), findsOneWidget);
    export.pending[0].complete(Uint8List.fromList([1]));
    await tester.pumpAndSettle();
    expect(find.text('preview-2'), findsOneWidget);
    expect(find.text('preview-1'), findsNothing);
  });
  testWidgets('generation failure exposes retry', (tester) async {
    _prepare(_Repository());
    final export = _Export()..fail = true;
    await tester.pumpWidget(_host(export));
    await tester.pumpAndSettle();
    expect(find.text('pdf_generation_failed'.tr), findsWidgets);
    export.fail = false;
    await tester.tap(find.text('retry'.tr));
    await tester.pumpAndSettle();
    expect(find.text('preview-1'), findsOneWidget);
  });
  testWidgets(
    'save, print and share use current unsaved settings and handle cancellation',
    (tester) async {
      final resumes = _prepare(_Repository());
      final export = _Export()..cancel = true;
      await tester.pumpWidget(_host(export));
      await tester.pumpAndSettle();
      await _tap(tester, 'font-Poppins');
      await _tap(tester, 'preview-save-pdf');
      await _tap(tester, 'preview-print-pdf');
      await _tap(tester, 'preview-share-pdf');
      expect(export.saves, 1);
      expect(export.prints, 1);
      expect(export.shares, 1);
      expect(export.calls.last.customization!['fontFamily'], 'Poppins');
      expect(
        resumes.currentResume.value!.customization!['fontFamily'],
        'Cairo',
      );
      expect(find.text('pdf_saved'.tr), findsNothing);
      expect(find.text('pdf_print_submitted'.tr), findsNothing);
      expect(find.text('pdf_share_opened'.tr), findsNothing);
    },
  );
  testWidgets('ATS conversion reloads fixed template controls', (tester) async {
    final resumes = _prepare(_Repository());
    final export = _Export();
    await tester.pumpWidget(
      _host(
        export,
        applyAts: () => resumes.currentResume.value = resumes
            .currentResume
            .value!
            .copyWith(templateId: 'ats'),
      ),
    );
    await tester.pumpAndSettle();
    await _tap(tester, 'preview-check-ats');
    await tester.tap(find.text('APPLY ATS'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomizationPanel), findsNothing);
    expect(export.calls.last.templateId, 'ats');
    expect(find.text('pdf_ats_fixed_note'.tr), findsOneWidget);
  });
  testWidgets(
    'back supports cancel and explicit discard without changing resume',
    (tester) async {
      final resumes = _prepare(_Repository());
      final export = _Export();
      await tester.pumpWidget(_host(export, navigation: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();
      await _tap(tester, 'font-Sukar');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('cancel'.tr));
      await tester.pumpAndSettle();
      expect(find.byType(PreviewScreen), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await _tap(tester, 'preview-leave-discard');
      expect(find.text('OPEN'), findsOneWidget);
      expect(
        resumes.currentResume.value!.customization!['fontFamily'],
        'Cairo',
      );
    },
  );
  testWidgets('empty selection has a useful state', (tester) async {
    final resumes = _prepare(_Repository());
    resumes.currentResume.value = null;
    await tester.pumpWidget(_host(_Export()));
    await tester.pumpAndSettle();
    expect(find.text('export_no_resume'.tr), findsOneWidget);
  });
  for (final width in [320.0, 800.0, 1920.0]) {
    testWidgets('preview and customization fit Arabic text scale 2 at $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      _prepare(_Repository());
      await tester.pumpWidget(_host(_Export(), arabic: true, scale: 2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (width == 320) {
        await _tap(tester, 'toggle-customization');
      } else {
        expect(
          find.byKey(const ValueKey('preview-side-by-side')),
          findsOneWidget,
        );
      }
      await _tap(tester, 'font-Sukar');
      expect(tester.takeException(), isNull);
      await _tap(tester, 'update-pdf-preview');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('custom color dialog remains reachable on small Arabic screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    _prepare(_Repository());
    await tester.pumpWidget(_host(_Export(), arabic: true, scale: 2));
    await tester.pumpAndSettle();
    await _tap(tester, 'toggle-customization');
    await _tap(tester, 'custom-color-primary');
    expect(tester.takeException(), isNull);
    final cancel = find.widgetWithText(AppButton, 'cancel'.tr);
    await tester.ensureVisible(cancel);
    await tester.pumpAndSettle();
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}

```

## test/pdf/redesign_preview_ats_test.dart
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
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/core/services/pdf_service.dart';
import 'package:cv_builder_pro/core/services/pdf_export_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/features/ats_checker/index.dart';
import 'package:cv_builder_pro/shared_widgets/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

final _pdfImages = <String, ui.Image>{};

ResumeModel _sample(bool arabic) => ResumeModel(
  id: 1,
  fullName: arabic ? 'عمر أحمد' : 'Alex Morgan',
  email: 'alex@example.com',
  phone: '+15551234567',
  address: arabic ? 'الرياض، السعودية' : 'Riyadh, Saudi Arabia',
  summary: arabic
      ? 'مطور تطبيقات متخصص في بناء تطبيقات سهلة الاستخدام وتحسين الأداء والعمل الجماعي.'
      : 'Flutter developer building accessible applications. Developed reliable products through teamwork and communication.',
  education: [
    Education(
      degree: arabic ? 'بكالوريوس علوم الحاسب' : 'BSc Computer Science',
      institution: 'University',
      year: '2020',
    ),
  ],
  experience: [
    Experience(
      jobTitle: arabic ? 'مطور تطبيقات' : 'Mobile Developer',
      company: 'Product Studio',
      startDate: '01/2021',
      isCurrent: true,
      description:
          'Developed reliable Flutter applications. Increased delivery speed by 30%.',
    ),
  ],
  skills: [
    Skill(name: 'Flutter', level: 5),
    Skill(name: 'Dart', level: 4),
    Skill(name: 'Communication', level: 4),
    Skill(name: 'Teamwork', level: 5),
    Skill(name: 'Problem-solving', level: 4),
  ],
  languages: [
    Language(name: 'English', level: 'advanced'),
    Language(name: 'العربية', level: 'native'),
  ],
  projects: [
    Project(
      name: 'CV Builder Pro',
      description: 'Accessible resume builder',
      startDate: '01/2024',
      isCurrent: true,
      technologies: ['Flutter', 'Dart'],
    ),
  ],
  linkedin: 'https://linkedin.com/in/alex',
  github: 'https://github.com/alex',
  website: 'https://example.com',
  portfolio: 'https://example.com/work',
);

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Export extends PdfExportService {
  Completer<Uint8List>? pending;
  @override
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    PdfExportQuality quality = PdfExportQuality.standard,
  }) async => pending?.future ?? Uint8List.fromList([1]);
}

void _prepare(bool arabic) {
  final resumes = Get.put(ResumeController(repository: _Repository()));
  resumes.currentResume.value = _sample(arabic);
  Get.put(AtsController(resumeController: resumes));
}

Widget _host(
  bool ats, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
  _Export? export,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: RepaintBoundary(
    key: const ValueKey('workspace-capture'),
    child: ats
        ? const ATSCheckerScreen()
        : PreviewScreen(
            exportService: export ?? _Export(),
            previewBuilder: (_) =>
                const bool.fromEnvironment('WRITE_UI_PREVIEWS')
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: RawImage(
                      image: _pdfImages[arabic ? 'ar' : 'en'],
                      fit: BoxFit.contain,
                    ),
                  )
                : const Center(child: Icon(Icons.description_outlined)),
          ),
  ),
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('workspace-capture')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'deliveries/ui_redesign/batch_08_$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
  setUpAll(() async {
    if (!const bool.fromEnvironment('WRITE_UI_PREVIEWS')) return;
    for (final locale in ['ar', 'en']) {
      final codec = await ui.instantiateImageCodec(
        await File('tmp/ui_redesign/batch_08_pdf_$locale.png').readAsBytes(),
      );
      _pdfImages[locale] = (await codec.getNextFrame()).image;
      codec.dispose();
    }
  });
  tearDownAll(() {
    for (final image in _pdfImages.values) {
      image.dispose();
    }
  });
  tearDown(Get.reset);
  if (const bool.fromEnvironment('GENERATE_PDF_FIXTURES')) {
    test('write actual PDF fixtures', () async {
      for (final arabic in [false, true]) {
        final bytes = await PdfService().generate(
          _sample(arabic),
          locale: arabic ? 'ar' : 'en',
        );
        await File(
          'tmp/ui_redesign/batch_08_pdf_${arabic ? 'ar' : 'en'}.pdf',
        ).writeAsBytes(bytes);
      }
    });
  }
  for (final ats in [false, true]) {
    for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
      for (final arabic in [false, true]) {
        for (final dark in [false, true]) {
          testWidgets(
            '${ats ? 'ATS' : 'preview'} $width ar=$arabic dark=$dark scale2',
            (tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = Size(
                width,
                width == 1024 ? 480 : 1200,
              );
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              _prepare(arabic);
              await tester.pumpWidget(
                _host(ats, arabic: arabic, dark: dark, scale: 2),
              );
              await tester.pumpAndSettle();
              if (ats) {
                expect(find.byType(LinearProgressIndicator), findsNWidgets(7));
                await tester.ensureVisible(
                  find.byKey(const ValueKey('ats-use-template')),
                );
                await tester.pumpAndSettle();
              } else {
                if (width < 600) await _tap(tester, 'toggle-customization');
                await _tap(tester, 'font-Poppins');
                await _tap(tester, 'update-pdf-preview');
              }
              expect(tester.takeException(), isNull);
              if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                  (width == 390 || width == 1920) &&
                  arabic == dark) {
                await tester.pumpWidget(const SizedBox());
                await tester.pumpWidget(_host(ats, arabic: arabic, dark: dark));
                await tester.pumpAndSettle();
                await _capture(
                  tester,
                  '${ats ? 'ats' : 'preview'}_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
                );
              }
            },
          );
        }
      }
    }
  }
  for (final score in [-10, 0, 50, 100, 150]) {
    testWidgets(
      'gauge $score keeps numeric semantics and fits narrow large text',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            GetMaterialApp(
              locale: const Locale('en'),
              translations: AppTranslations(),
              theme: AppTheme.dark,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: Scaffold(
                body: SizedBox(width: 160, child: AtsScoreGauge(score: score)),
              ),
            ),
          );
          expect(
            find.bySemanticsLabel('${score.clamp(0, 100)} out of 100'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }
  testWidgets('PDF loading respects reduced motion and resolves to preview', (
    tester,
  ) async {
    _prepare(false);
    final export = _Export()..pending = Completer<Uint8List>();
    await tester.pumpWidget(_host(false, export: export));
    await tester.pump();
    expect(find.byType(AppLoading), findsOneWidget);
    export.pending!.complete(Uint8List.fromList([1]));
    await tester.pumpAndSettle();
    expect(find.byType(AppLoading), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

```


