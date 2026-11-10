# Part 2 — الدفعة الثالثة والعشرون: المعاينة والتخصيص وتصدير PDF
طُبقت الملفات كاملة داخل المشروع، وربط مسار المعاينة بالشاشة المستقلة. حُذف lib/legacy_app.dart بعد نقل جميع مسؤولياته. لم تُضف أي اعتمادية Flutter جديدة.
المعاينة: عرض A4 لجميع الصفحات، حالات تحميل وفشل وإعادة محاولة، منع استبدال نتيجة أحدث بطلب توليد أقدم، زر ATS وتصدير JSON، وإظهار أن المعاينة تحتاج إلى تحديث عندما تختلف إعداداتها. تستخدم عمليات تصدير PDF وJSON الإعدادات الحالية حتى قبل حفظ التخصيص.
التخصيص: ألوان جاهزة ومنتقي لون مخصص، Cairo/Sukar/Poppins، حجم 8–16، تحديث المعاينة وحفظ والتراجع. التخصيص مسودة لا تغيّر السيرة الأصلية قبل نجاح الحفظ؛ فشل الحفظ يحتفظ بالمسودة ويتيح إعادة المحاولة. الرجوع مع تغييرات يتيح الحفظ أو التجاهل أو الإلغاء. تبقى مفاتيح التخصيص الإضافية المستوردة محفوظة. عند استخدام ATS تبقى ضوابطه الثابتة دون تخصيص زخرفي.
التصدير: حفظ PDF عبر file_picker مع كتابة آمنة على سطح المكتب، والطباعة عبر printing، والمشاركة عبر share_plus مع موضع مرجعي للنوافذ المنبثقة. إلغاء الحفظ أو الطباعة أو المشاركة لا يُعرض كنجاح. تُحوّل الإخفاقات إلى رسائل مترجمة مفيدة.
الجودة تطبق دقة قصوى للصورة الشخصية: 96 بكسل للحجم الصغير، 256 للقياسية، 768 للعالية، مع الحفاظ على النسبة وعدم تكبير الصور الصغيرة. النص يظل متجهياً وقابلاً للتحديد دائماً؛ لذلك لا يتغير وضوح النص أو حجم الملف بالضرورة إذا لم تتضمن السيرة صورة. ATS لا يضمّن صورة في جميع الخيارات.
التجاوب: شاشة واحدة متتابعة على الجوال مع إظهار/إخفاء التخصيص، ومعاينة ولوحة جانبية على التابلت وسطح المكتب. اختُبرت العربية والوضع الليلي وتكبير النص إلى الضعف عند 320×900 و800×400 و1920×900، بما فيها قابلية الوصول إلى حوار الألوان والأزرار بالتمرير.
التحقق: flutter analyze للمشروع كاملاً دون ملاحظات. نجحت الاختبارات الـ257، منها 19 اختباراً جديداً: 7 لخدمة التصدير و12 للشاشة. شملت كتابة ملف فعلي، الإلغاء، أخطاء الخدمة، تمرير بايتات الملف إلى الطباعة والمشاركة، قياس أبعاد الصورة المضمنة في PDF، حفظ مسودة التخصيص والتراجع عنها وفشل الحفظ والتوليد المتداخل والتجاوب.
حدود التحقق: نوافذ الطباعة والمشاركة وحوار اختيار وجهة الحفظ حُوكيت في الاختبارات؛ لم تُختبر على جهاز فعلي بعد. لا تُعد هذه الدفعة تأكيداً لعمل جميع المنصات. القيود المعروفة لاستيراد PDF ما زالت قائمة: الاستيراد يدعم ملفات النص ASCII البسيطة والتدفقات المضغوطة المدعومة، ولا يدعم OCR أو التشفير أو ترميزات خطوط PDF المعقدة. يُفضّل JSON للاستيراد الكامل دون فقد حقول.
المتبقي: المراجعة النهائية وPart 3 للتشغيل واختبار الجهاز والميزات المتكاملة، مع توثيق ما اختُبر وما لم يُختبر.
## الملفات
1. lib/core/services/pdf_export_service.dart
2. lib/core/services/pdf_service.dart
3. lib/features/resume_builder/presentation/templates/pdf_template_options.dart
4. lib/features/resume_builder/presentation/pages/preview_screen.dart
5. lib/features/resume_builder/presentation/widgets/customization_panel.dart
6. lib/features/resume_builder/presentation/widgets/pdf_preview_view.dart
7. lib/app/routes/app_pages.dart
8. lib/features/resume_builder/index.dart
9. lib/core/index.dart
10. lib/translations/en_us.dart
11. lib/translations/ar_sa.dart
12. test/pdf/pdf_export_service_test.dart
13. test/pdf/preview_screen_test.dart
14. ملف محذوف: lib/legacy_app.dart (لم يعد هناك أي استيراد له).

## lib/core/services/pdf_export_service.dart
```dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/resume_model.dart';
import 'pdf_service.dart';

/// Image resolution choices; PDF text remains vector content at every quality.
enum PdfExportQuality { compact, standard, high }

/// Export failure exposing a stable translation key to the presentation layer.
class PdfExportException implements Exception {
  const PdfExportException(this.messageKey);
  final String messageKey;
  @override
  String toString() => messageKey;
}

/// Generates complete PDFs and handles native saving, printing and sharing.
class PdfExportService {
  PdfExportService({
    PdfService? pdfService,
    FilePicker? picker,
    Future<bool> Function(Uint8List, String)? print,
    Future<ShareResult> Function(ShareParams)? share,
  }) : _pdf = pdfService ?? PdfService(),
       _picker = picker,
       _print = print,
       _share = share;
  final PdfService _pdf;
  final FilePicker? _picker;
  final Future<bool> Function(Uint8List, String)? _print;
  final Future<ShareResult> Function(ShareParams)? _share;
  bool get pickerWritesBytes => Platform.isAndroid || Platform.isIOS;
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    PdfExportQuality quality = PdfExportQuality.standard,
  }) async {
    try {
      return await _pdf.generate(
        resume.copyWith(),
        locale: locale,
        photoMaxDimension: switch (quality) {
          PdfExportQuality.compact => 96,
          PdfExportQuality.standard => 256,
          PdfExportQuality.high => 768,
        },
      );
    } catch (_) {
      throw const PdfExportException('pdf_generation_failed');
    }
  }

  String fileName(String fullName) {
    var name = fullName.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9_\u0600-\u06ff-]+'),
      '-',
    );
    if (name.length > 60) name = name.substring(0, 60);
    return 'cv_${name.isEmpty ? 'resume' : name}.pdf';
  }

  void _validate(Uint8List bytes) {
    if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const PdfExportException('pdf_invalid_data');
    }
  }

  Future<String?> savePdf(Uint8List bytes, {required String name}) async {
    Directory? staging;
    try {
      _validate(bytes);
      final path = await (_picker ?? FilePicker.platform).saveFile(
        fileName: name,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: bytes,
        lockParentWindow: true,
      );
      if (path == null) return null;
      if (!pickerWritesBytes) {
        if (!path.toLowerCase().endsWith('.pdf')) {
          throw const PdfExportException('pdf_extension_required');
        }
        final destination = File(path);
        staging = await destination.parent.createTemp('.cv_pdf_');
        final temporary = File('${staging.path}/resume.pdf');
        await temporary.writeAsBytes(bytes, flush: true);
        await temporary.rename(path);
      }
      return path;
    } on PdfExportException {
      rethrow;
    } catch (_) {
      throw const PdfExportException('pdf_save_failed');
    } finally {
      try {
        if (staging != null && await staging.exists()) {
          final temporary = File('${staging.path}/resume.pdf');
          if (await temporary.exists()) await temporary.delete();
          await staging.delete();
        }
      } catch (_) {
        /* Cleanup must not hide the export result. */
      }
    }
  }

  Future<bool> printPdf(Uint8List bytes, {required String name}) async {
    try {
      _validate(bytes);
      if (_print != null) return await _print(bytes, name);
      return await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: name,
        format: PdfPageFormat.a4,
        dynamicLayout: false,
      );
    } on PdfExportException {
      rethrow;
    } catch (_) {
      throw const PdfExportException('pdf_print_failed');
    }
  }

  Future<ShareResult> sharePdf(
    Uint8List bytes, {
    required String name,
    required Rect origin,
  }) async {
    try {
      _validate(bytes);
      return await (_share ?? SharePlus.instance.share)(
        ShareParams(
          files: [
            XFile.fromData(bytes, mimeType: 'application/pdf', name: name),
          ],
          fileNameOverrides: [name],
          subject: 'CV Builder Pro',
          sharePositionOrigin: origin,
        ),
      );
    } on PdfExportException {
      rethrow;
    } catch (_) {
      throw const PdfExportException('pdf_share_failed');
    }
  }
}

```

## lib/core/services/pdf_service.dart
```dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/resume_model.dart';
import '../../features/resume_builder/presentation/templates/ats_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/base_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/modern_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/classic_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/business_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/technical_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/pdf_template_options.dart';

/// Loads local fonts and photos and dispatches immutable drafts to PDF layouts.
class PdfService {
  PdfService({AssetBundle? assets}) : _assets = assets ?? rootBundle;
  final AssetBundle _assets;
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    int? photoMaxDimension,
  }) async {
    final snapshot = resume.copyWith();
    if (snapshot.templateId == 'ats') {
      return generateAts(snapshot, locale: locale);
    }
    try {
      if (![
        'modern',
        'classic',
        'business',
        'technical',
      ].contains(snapshot.templateId)) {
        throw ArgumentError.value(
          snapshot.templateId,
          'templateId',
          'Unknown PDF template',
        );
      }
      final options = PdfTemplateOptions.fromJson(snapshot.customization);
      final cairo = pw.Font.ttf(
        await _assets.load('assets/fonts/Cairo-Regular.ttf'),
      );
      final isArabic = locale.startsWith('ar');
      final fontPath = switch (options.fontFamily) {
        'Poppins' => 'assets/fonts/Poppins-Regular.ttf',
        'Sukar' => 'assets/fonts/SukarRegular.ttf',
        _ => 'assets/fonts/Cairo-Regular.ttf',
      };
      final font = isArabic || options.fontFamily == 'Cairo'
          ? cairo
          : pw.Font.ttf(await _assets.load(fontPath));
      Uint8List? photo;
      final path = snapshot.profilePicture;
      if (path != null && path.trim().isNotEmpty) {
        try {
          final file = File(path);
          if (await file.exists()) {
            photo = await file.readAsBytes();
            if (photoMaxDimension != null) {
              photo = await _resizePhoto(photo, photoMaxDimension);
            }
          }
        } catch (error) {
          throw StateError('Unable to read profile photo: $error');
        }
      }
      final BasePdfTemplate template = switch (snapshot.templateId) {
        'classic' => ClassicPdfTemplate(
          options: options,
          fallbackFont: cairo,
          photo: photo,
        ),
        'business' => BusinessPdfTemplate(
          options: options,
          fallbackFont: cairo,
          photo: photo,
        ),
        'technical' => TechnicalPdfTemplate(
          options: options,
          fallbackFont: cairo,
          photo: photo,
        ),
        _ => ModernPdfTemplate(
          options: options,
          fallbackFont: cairo,
          photo: photo,
        ),
      };
      return await template.build(
        resume: snapshot,
        font: font,
        isArabic: isArabic,
      );
    } catch (error) {
      throw StateError('Unable to generate ${snapshot.templateId} PDF: $error');
    }
  }

  Future<Uint8List> _resizePhoto(Uint8List bytes, int dimension) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final maximum = dimension.clamp(32, 2048);
      final scale = math.min(
        1.0,
        maximum / math.max(descriptor.width, descriptor.height),
      );
      codec = await descriptor.instantiateCodec(
        targetWidth: math.max(1, (descriptor.width * scale).round()),
        targetHeight: math.max(1, (descriptor.height * scale).round()),
      );
      image = (await codec.getNextFrame()).image;
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Unable to encode profile photo');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  }

  Future<Uint8List> generateAts(
    ResumeModel resume, {
    String locale = 'en',
  }) async {
    try {
      final snapshot = resume.copyWith();
      final data = await _assets.load('assets/fonts/Cairo-Regular.ttf');
      return await const AtsPdfTemplate().build(
        resume: snapshot,
        font: pw.Font.ttf(data),
        isArabic: locale.startsWith('ar'),
      );
    } catch (error) {
      throw StateError('Unable to generate ATS PDF: $error');
    }
  }
}

```

## lib/features/resume_builder/presentation/templates/pdf_template_options.dart
```dart
import 'package:pdf/pdf.dart';

/// Validated appearance settings retaining the existing customization schema.
class PdfTemplateOptions {
  const PdfTemplateOptions({
    this.primaryColor = 0xff1565c0,
    this.secondaryColor = 0xff546e7a,
    this.fontFamily = 'Cairo',
    this.fontSize = 11,
  });
  final int primaryColor;
  final int secondaryColor;
  final String fontFamily;
  final double fontSize;
  PdfColor get primary => PdfColor.fromInt(primaryColor);
  PdfColor get secondary => PdfColor.fromInt(secondaryColor);
  Map<String, dynamic> toJson() => {
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'fontFamily': fontFamily,
    'fontSize': fontSize,
  };
  PdfTemplateOptions copyWith({
    int? primaryColor,
    int? secondaryColor,
    String? fontFamily,
    double? fontSize,
  }) => PdfTemplateOptions(
    primaryColor: primaryColor ?? this.primaryColor,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    fontFamily: fontFamily ?? this.fontFamily,
    fontSize: fontSize ?? this.fontSize,
  );
  @override
  bool operator ==(Object other) =>
      other is PdfTemplateOptions &&
      primaryColor == other.primaryColor &&
      secondaryColor == other.secondaryColor &&
      fontFamily == other.fontFamily &&
      fontSize == other.fontSize;
  @override
  int get hashCode =>
      Object.hash(primaryColor, secondaryColor, fontFamily, fontSize);
  factory PdfTemplateOptions.fromJson(Map<String, dynamic>? json) {
    int color(String key, int fallback) {
      final value = json?[key];
      return value is int && value >= 0 && value <= 0xffffffff
          ? value
          : fallback;
    }

    final size = json?['fontSize'];
    final family = json?['fontFamily'];
    return PdfTemplateOptions(
      primaryColor: color('primaryColor', 0xff1565c0),
      secondaryColor: color('secondaryColor', 0xff546e7a),
      fontFamily: ['Cairo', 'Sukar', 'Poppins'].contains(family)
          ? family as String
          : 'Cairo',
      fontSize: size is num && size.isFinite
          ? size.toDouble().clamp(8, 16)
          : 11,
    );
  }
}

```

## lib/features/resume_builder/presentation/pages/preview_screen.dart
```dart
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('pdf_leave_changes'.tr),
                    const SizedBox(height: 16),
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

  Widget _panel() => CustomizationPanel(
    options: _options,
    enabled: !_working,
    dirty: _dirty,
    onChanged: (value) => setState(() => _options = value),
    onSave: _save,
    onReset: _reset,
    onPreview: _refresh,
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
                        padding: const EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
                                  variant: AppButtonVariant.outlined,
                                  onPressed: _working || _generating
                                      ? null
                                      : () => _output(action, anchor),
                                ),
                              ),
                          ],
                        ),
                      );
                      final controls = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          actions,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text('pdf_quality'.tr),
                                for (final quality in PdfExportQuality.values)
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
                                            setState(() => _quality = quality);
                                            unawaited(_refresh());
                                          },
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              (_ats ? 'pdf_ats_fixed_note' : 'pdf_quality_note')
                                  .tr,
                            ),
                          ),
                          if (_rendered != null &&
                              _rendered != _snapshot() &&
                              !_generating)
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('pdf_preview_outdated'.tr),
                            ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  _error!.tr,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                            Expanded(child: _preview()),
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
                              child: _preview(),
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
            padding: const EdgeInsets.all(16),
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
                  variant: AppButtonVariant.text,
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
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'customize_resume'.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        for (final primary in [true, false]) ...[
          Text((primary ? 'primary_color' : 'secondary_color').tr),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
          const SizedBox(height: 16),
        ],
        Text('font_family'.tr),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
        const SizedBox(height: 8),
        Text('pdf_arabic_font_note'.tr),
        const SizedBox(height: 16),
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
        const SizedBox(height: 12),
        AppButton(
          key: const ValueKey('update-pdf-preview'),
          label: 'update_preview'.tr,
          icon: Icons.refresh,
          fullWidth: true,
          onPressed: enabled ? onPreview : null,
        ),
        const SizedBox(height: 8),
        AppButton(
          key: const ValueKey('save-customization'),
          label: 'save'.tr,
          icon: Icons.save_outlined,
          fullWidth: true,
          onPressed: enabled && dirty ? onSave : null,
        ),
        const SizedBox(height: 8),
        AppButton(
          key: const ValueKey('reset-customization'),
          label: 'pdf_revert_changes'.tr,
          fullWidth: true,
          variant: AppButtonVariant.text,
          onPressed: enabled && dirty ? onReset : null,
        ),
      ],
    ),
  );
}

```

## lib/features/resume_builder/presentation/widgets/pdf_preview_view.dart
```dart
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
    previewPageMargin: const EdgeInsets.all(8),
    loadingWidget: AppLoading(message: 'pdf_preview_loading'.tr),
    onError: (_, error) => AppEmptyState(
      title: 'failed_to_generate_preview'.tr,
      actionLabel: 'retry'.tr,
      onAction: onRetry,
    ),
  );
}

```

## lib/app/routes/app_pages.dart
```dart
import 'package:get/get.dart';
import '../../features/resume_builder/presentation/pages/preview_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/language/presentation/pages/language_selection_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/templates/presentation/pages/templates_screen.dart';
import '../../features/favorites/presentation/pages/favorites_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/import_resume/presentation/pages/import_resume_screen.dart';
import '../../features/ats_checker/presentation/pages/ats_checker_screen.dart';
import '../../features/resume_builder/presentation/pages/resume_builder_screen.dart';
import 'app_routes.dart';

/// Registers the independent feature screens.
abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.root, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.atsChecker, page: () => const ATSCheckerScreen()),
    GetPage(
      name: AppRoutes.importResume,
      page: () => const ImportResumeScreen(),
    ),
    GetPage(name: AppRoutes.templates, page: () => const TemplatesScreen()),
    GetPage(name: AppRoutes.favorites, page: () => const FavoritesScreen()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () => const ResumeBuilderScreen(),
    ),
    GetPage(name: AppRoutes.preview, page: () => const PreviewScreen()),
  ];
}

```

## lib/features/resume_builder/index.dart
```dart
export 'presentation/widgets/resume_json_export_button.dart';
export 'presentation/templates/base_pdf_template.dart';
export 'presentation/templates/ats_pdf_template.dart';
export 'presentation/pages/resume_builder_screen.dart';
export 'presentation/steps/personal_info_step.dart';
export 'presentation/steps/additional_info_step.dart';
export 'presentation/widgets/step_indicator.dart';
export 'presentation/widgets/navigation_buttons.dart';
export 'presentation/steps/education_step.dart';
export 'presentation/steps/experience_step.dart';
export 'presentation/steps/skills_step.dart';
export 'presentation/dialogs/education_dialog.dart';
export 'presentation/dialogs/experience_dialog.dart';
export 'presentation/widgets/resume_form_dialog.dart';
export 'presentation/widgets/resume_entry_card.dart';
export 'presentation/steps/courses_step.dart';
export 'presentation/steps/certificates_step.dart';
export 'presentation/steps/languages_step.dart';
export 'presentation/dialogs/course_dialog.dart';
export 'presentation/dialogs/certificate_dialog.dart';
export 'presentation/dialogs/language_dialog.dart';
export 'presentation/steps/projects_step.dart';
export 'presentation/steps/achievements_step.dart';
export 'presentation/steps/interests_step.dart';
export 'presentation/dialogs/project_dialog.dart';
export 'presentation/dialogs/achievement_dialog.dart';
export 'presentation/templates/modern_pdf_template.dart';
export 'presentation/templates/classic_pdf_template.dart';
export 'presentation/templates/business_pdf_template.dart';
export 'presentation/templates/technical_pdf_template.dart';
export 'presentation/templates/pdf_template_options.dart';
export 'presentation/pages/preview_screen.dart';
export 'presentation/widgets/customization_panel.dart';
export 'presentation/widgets/pdf_preview_view.dart';

```

## lib/core/index.dart
```dart
export 'constants/app_constants.dart';
export 'services/storage_service.dart';
export 'services/settings_service.dart';
export 'services/resume_import_service.dart';
export 'services/resume_export_service.dart';
export 'services/pdf_service.dart';
export 'services/ats_analyzer_service.dart';
export 'utils/ats_scorer.dart';
export 'constants/storage_keys.dart';
export 'extensions/context_extensions.dart';
export 'utils/app_snackbar.dart';
export 'utils/date_formatter.dart';
export 'utils/responsive.dart';
export 'utils/validators.dart';
export 'services/pdf_export_service.dart';

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
  'ats_choose_resume': 'Choose a saved resume',
  'builder_fix_personal':
      'Check your name, email, phone and any profile links before continuing.',
  'builder_new_draft': 'New draft',
  'builder_remove_photo': 'Remove photo',
  'builder_save_close': 'Save and close',
  'builder_saved': 'Saved',
  'builder_section_position': 'Section @current of @total',
  'builder_unsaved': 'Changes waiting to be saved',
  'builder_entry_changed':
      'The resume changed while editing. Cancel this edit and select the entry again.',
  'builder_future_date': 'The date cannot be later than the current month.',
  'builder_invalid_year':
      'Enter a four-digit year from 1900 to ten years from now.',
  'builder_present': 'Present',
  'builder_skill_duplicate': 'This skill is already listed.',
  'builder_skill_level_1': 'Beginner',
  'builder_skill_level_2': 'Basic',
  'builder_skill_level_3': 'Intermediate',
  'builder_skill_level_4': 'Advanced',
  'builder_skill_level_5': 'Expert',
  'builder_skill_required': 'Enter a skill name.',
  'builder_certificate_url': 'Certificate URL (optional)',
  'builder_credential_id': 'Credential ID (optional)',
  'builder_language_beginner': 'Beginner',
  'builder_language_intermediate': 'Intermediate',
  'builder_language_advanced': 'Advanced',
  'builder_language_fluent': 'Fluent',
  'builder_language_native': 'Native',
  'builder_technology_lines': 'One technology per line.',
  'builder_interest_name': 'Interest',
  'builder_interest_required': 'Enter an interest.',
  'builder_interest_duplicate': 'This interest is already added.',
  'builder_add_interest': 'Add interest',
  'builder_interest_suggestions': 'Suggested interests',
  'builder_no_interests': 'No interests added',
  'builder_interest_reading': 'Reading',
  'builder_interest_travel': 'Travel',
  'builder_interest_music': 'Music',
  'builder_interest_sports': 'Sports',
  'builder_interest_photography': 'Photography',
  'builder_interest_coding': 'Coding',
  'builder_interest_art': 'Art',
  'builder_interest_gaming': 'Gaming',
  'builder_interest_cooking': 'Cooking',
  'builder_interest_yoga': 'Yoga',
  'builder_interest_chess': 'Chess',
  'builder_interest_volunteering': 'Volunteering',
  'builder_interest_writing': 'Writing',
  'builder_interest_dancing': 'Dancing',
  'pdf_preview_loading': 'Generating preview…',
  'pdf_custom_color': 'Custom color',
  'pdf_arabic_font_note': 'Arabic text uses Cairo for reliable letter shaping.',
  'pdf_unsaved_changes': 'Unsaved appearance changes',
  'pdf_revert_changes': 'Revert changes',
  'pdf_leave_changes': 'Save your appearance changes before leaving?',
  'pdf_discard_changes': 'Discard changes',
  'pdf_generation_failed':
      'Could not generate PDF. Check the fonts and profile photo, then retry.',
  'pdf_invalid_data': 'The PDF data is invalid. Generate the preview again.',
  'pdf_extension_required': 'Choose a file name ending in .pdf.',
  'pdf_save_failed': 'Could not save PDF. Check the destination and try again.',
  'pdf_print_failed': 'Could not print PDF. Check that printing is available.',
  'pdf_share_failed':
      'Could not share PDF. Check that a sharing app is available.',
  'pdf_customization_save_failed':
      'Could not save customization. Your draft is still available.',
  'pdf_export_failed': 'Could not export PDF. Please retry.',
  'pdf_saved': 'PDF saved successfully.',
  'pdf_print_submitted': 'PDF submitted to printing.',
  'pdf_share_opened': 'PDF sent to the share panel.',
  'pdf_quality': 'PDF quality',
  'pdf_quality_compact': 'Compact',
  'pdf_quality_standard': 'Standard',
  'pdf_quality_high': 'High',
  'pdf_quality_note':
      'Quality changes profile photo resolution. Text stays sharp and selectable at every setting.',
  'pdf_ats_fixed_note':
      'ATS uses Cairo 11pt with black text and no photo. Appearance controls are disabled.',
  'pdf_preview_outdated':
      'The preview needs updating. Exports use your current settings.',
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
  'ats_choose_resume': 'اختيار سيرة محفوظة',
  'builder_fix_personal':
      'تحقق من الاسم والبريد والهاتف وروابط الحسابات قبل المتابعة.',
  'builder_new_draft': 'مسودة جديدة',
  'builder_remove_photo': 'إزالة الصورة',
  'builder_save_close': 'حفظ وإغلاق',
  'builder_saved': 'تم الحفظ',
  'builder_section_position': 'القسم @current من @total',
  'builder_unsaved': 'تعديلات بانتظار الحفظ',
  'builder_entry_changed':
      'تغيرت السيرة أثناء التعديل. ألغِ التعديل واختر العنصر مجدداً.',
  'builder_future_date': 'لا يمكن أن يكون التاريخ بعد الشهر الحالي.',
  'builder_invalid_year':
      'أدخل سنة من أربعة أرقام بين 1900 وعشر سنوات من الآن.',
  'builder_present': 'حتى الآن',
  'builder_skill_duplicate': 'هذه المهارة موجودة بالفعل.',
  'builder_skill_level_1': 'مبتدئ',
  'builder_skill_level_2': 'أساسي',
  'builder_skill_level_3': 'متوسط',
  'builder_skill_level_4': 'متقدم',
  'builder_skill_level_5': 'خبير',
  'builder_skill_required': 'أدخل اسم المهارة.',
  'builder_certificate_url': 'رابط الشهادة (اختياري)',
  'builder_credential_id': 'معرّف الاعتماد (اختياري)',
  'builder_language_beginner': 'مبتدئ',
  'builder_language_intermediate': 'متوسط',
  'builder_language_advanced': 'متقدم',
  'builder_language_fluent': 'طليق',
  'builder_language_native': 'لغة أم',
  'builder_technology_lines': 'أدخل كل تقنية في سطر مستقل.',
  'builder_interest_name': 'الاهتمام',
  'builder_interest_required': 'أدخل اهتماماً.',
  'builder_interest_duplicate': 'هذا الاهتمام مضاف بالفعل.',
  'builder_add_interest': 'إضافة اهتمام',
  'builder_interest_suggestions': 'اهتمامات مقترحة',
  'builder_no_interests': 'لم تضف اهتمامات بعد',
  'builder_interest_reading': 'القراءة',
  'builder_interest_travel': 'السفر',
  'builder_interest_music': 'الموسيقى',
  'builder_interest_sports': 'الرياضة',
  'builder_interest_photography': 'التصوير',
  'builder_interest_coding': 'البرمجة',
  'builder_interest_art': 'الفن',
  'builder_interest_gaming': 'الألعاب',
  'builder_interest_cooking': 'الطبخ',
  'builder_interest_yoga': 'اليوغا',
  'builder_interest_chess': 'الشطرنج',
  'builder_interest_volunteering': 'التطوع',
  'builder_interest_writing': 'الكتابة',
  'builder_interest_dancing': 'الرقص',
  'pdf_preview_loading': 'جارٍ إنشاء المعاينة…',
  'pdf_custom_color': 'لون مخصّص',
  'pdf_arabic_font_note': 'يستخدم النص العربي خط Cairo لضمان اتصال الحروف.',
  'pdf_unsaved_changes': 'تغييرات تخصيص غير محفوظة',
  'pdf_revert_changes': 'التراجع عن التغييرات',
  'pdf_leave_changes': 'هل تريد حفظ تغييرات التخصيص قبل المغادرة؟',
  'pdf_discard_changes': 'تجاهل التغييرات',
  'pdf_generation_failed':
      'تعذّر توليد PDF. تحقق من الخطوط والصورة الشخصية ثم أعد المحاولة.',
  'pdf_invalid_data': 'بيانات PDF غير صالحة. أعد إنشاء المعاينة.',
  'pdf_extension_required': 'اختر اسماً ينتهي بالامتداد .pdf.',
  'pdf_save_failed': 'تعذّر حفظ PDF. تحقق من وجهة الحفظ وأعد المحاولة.',
  'pdf_print_failed': 'تعذّرت طباعة PDF. تحقق من توفر الطباعة.',
  'pdf_share_failed': 'تعذّرت مشاركة PDF. تحقق من توفر تطبيق للمشاركة.',
  'pdf_customization_save_failed': 'تعذّر حفظ التخصيص. مسودتك ما زالت متاحة.',
  'pdf_export_failed': 'تعذّر تصدير PDF. أعد المحاولة.',
  'pdf_saved': 'تم حفظ PDF بنجاح.',
  'pdf_print_submitted': 'تم إرسال PDF للطباعة.',
  'pdf_share_opened': 'تم إرسال PDF إلى لوحة المشاركة.',
  'pdf_quality': 'جودة PDF',
  'pdf_quality_compact': 'حجم صغير',
  'pdf_quality_standard': 'قياسية',
  'pdf_quality_high': 'عالية',
  'pdf_quality_note':
      'تغيّر الجودة دقة الصورة الشخصية. يبقى النص واضحاً وقابلاً للتحديد في جميع الخيارات.',
  'pdf_ats_fixed_note':
      'يستخدم ATS خط Cairo بحجم 11 ونصاً أسود دون صورة. خيارات التخصيص معطّلة.',
  'pdf_preview_outdated':
      'تحتاج المعاينة إلى تحديث. يستخدم التصدير إعداداتك الحالية.',
};

```

## test/pdf/pdf_export_service_test.dart
```dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cv_builder_pro/core/services/pdf_service.dart';
import 'package:cv_builder_pro/core/services/pdf_export_service.dart';
import 'package:cv_builder_pro/data/models/resume_model.dart';

class _Pdf extends PdfService {
  int? dimension;
  bool fail = false;
  @override
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    int? photoMaxDimension,
  }) async {
    dimension = photoMaxDimension;
    if (fail) throw StateError('failed');
    return Uint8List.fromList('%PDF-test'.codeUnits);
  }
}

class _Picker extends FilePicker {
  String? destination;
  bool fail = false;
  Uint8List? bytesReceived;
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
    if (fail) throw StateError('picker failure');
    expect(allowedExtensions, ['pdf']);
    bytesReceived = bytes;
    return destination;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = Uint8List.fromList('%PDF-test'.codeUnits);
  test(
    'quality selects actual photo resolution and generation errors are localized',
    () async {
      final pdf = _Pdf();
      final service = PdfExportService(pdfService: pdf);
      for (final entry in {
        PdfExportQuality.compact: 96,
        PdfExportQuality.standard: 256,
        PdfExportQuality.high: 768,
      }.entries) {
        await service.generate(ResumeModel(), quality: entry.key);
        expect(pdf.dimension, entry.value);
      }
      pdf.fail = true;
      await expectLater(
        service.generate(ResumeModel()),
        throwsA(
          isA<PdfExportException>().having(
            (e) => e.messageKey,
            'key',
            'pdf_generation_failed',
          ),
        ),
      );
    },
  );
  test(
    'PDF saving writes exact bytes atomically and cancellation leaves existing file intact',
    () async {
      final directory = await Directory.systemTemp.createTemp('cv-pdf-save-');
      try {
        final picker = _Picker();
        final service = PdfExportService(picker: picker);
        final file = File('${directory.path}/resume.pdf');
        await file.writeAsString('old');
        expect(await service.savePdf(bytes, name: 'resume.pdf'), isNull);
        expect(await file.readAsString(), 'old');
        picker.destination = file.path;
        expect(await service.savePdf(bytes, name: 'resume.pdf'), file.path);
        expect(await file.readAsBytes(), bytes);
        expect(picker.bytesReceived, bytes);
        expect(await directory.list().length, 1);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
  test(
    'invalid file extension and picker failure report useful errors',
    () async {
      final picker = _Picker()..destination = 'resume.txt';
      final service = PdfExportService(picker: picker);
      await expectLater(
        service.savePdf(bytes, name: 'resume.pdf'),
        throwsA(
          isA<PdfExportException>().having(
            (e) => e.messageKey,
            'key',
            'pdf_extension_required',
          ),
        ),
      );
      picker.fail = true;
      await expectLater(
        service.savePdf(bytes, name: 'resume.pdf'),
        throwsA(
          isA<PdfExportException>().having(
            (e) => e.messageKey,
            'key',
            'pdf_save_failed',
          ),
        ),
      );
    },
  );
  test(
    'printing preserves native cancellation and reports platform failures',
    () async {
      expect(
        await PdfExportService(
          print: (data, name) async {
            expect(data, bytes);
            return false;
          },
        ).printPdf(bytes, name: 'cv.pdf'),
        isFalse,
      );
      await expectLater(
        PdfExportService(
          print: (_, _) async => throw StateError('no printer'),
        ).printPdf(bytes, name: 'cv.pdf'),
        throwsA(
          isA<PdfExportException>().having(
            (e) => e.messageKey,
            'key',
            'pdf_print_failed',
          ),
        ),
      );
    },
  );
  test('sharing forwards PDF bytes, name, anchor and cancellation', () async {
    final service = PdfExportService(
      share: (params) async {
        expect(params.fileNameOverrides, ['cv.pdf']);
        expect(
          params.sharePositionOrigin,
          const ui.Rect.fromLTWH(1, 2, 30, 40),
        );
        expect(params.files!.single.mimeType, 'application/pdf');
        expect(await params.files!.single.readAsBytes(), bytes);
        return const ShareResult('', ShareResultStatus.dismissed);
      },
    );
    expect(
      (await service.sharePdf(
        bytes,
        name: 'cv.pdf',
        origin: const ui.Rect.fromLTWH(1, 2, 30, 40),
      )).status,
      ShareResultStatus.dismissed,
    );
  });
  test('invalid PDF never reaches native print or save', () async {
    var printed = false;
    final service = PdfExportService(
      print: (_, _) async {
        printed = true;
        return true;
      },
    );
    await expectLater(
      service.printPdf(Uint8List(0), name: 'bad.pdf'),
      throwsA(isA<PdfExportException>()),
    );
    expect(printed, isFalse);
  });
  test(
    'real quality resizing keeps PDF text and changes embedded photo dimensions',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cv-pdf-quality-',
      );
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(
        const ui.Rect.fromLTWH(0, 0, 1000, 500),
        ui.Paint()..color = const ui.Color(0xff1565c0),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(1000, 500);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('${directory.path}/photo.png');
        await file.writeAsBytes(data!.buffer.asUint8List());
        final resume = ResumeModel(
          fullName: 'Photo quality',
          profilePicture: file.path,
        );
        for (final entry in {
          PdfExportQuality.compact: 96,
          PdfExportQuality.standard: 256,
          PdfExportQuality.high: 768,
        }.entries) {
          final pdf = await PdfExportService().generate(
            resume,
            quality: entry.key,
          );
          final source = String.fromCharCodes(pdf);
          expect(
            RegExp('/Width\\s+${entry.value}\\b').hasMatch(source),
            isTrue,
          );
          expect(source, contains('/FontFile2'));
        }
      } finally {
        image.dispose();
        picture.dispose();
        await directory.delete(recursive: true);
      }
    },
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
    final cancel = find.widgetWithText(TextButton, 'cancel'.tr);
    await tester.ensureVisible(cancel);
    await tester.pumpAndSettle();
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}

```

