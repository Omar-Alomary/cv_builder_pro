# Part 2 — الدفعة الثانية والعشرون: قوالب PDF المتبقية وخدمة التوليد
طُبقت القوالب Modern وClassic وBusiness وTechnical وربطت المعاينة الحالية بخدمة PdfService.generate. Modern يستخدم خطوطاً زمنية للخبرات والمشاريع، Classic اسماً في الوسط وفواصل تقليدية، Business عناوين مؤسسية ملونة، وTechnical يقدّم المهارات والمشاريع. تشترك القوالب في عارض محتوى واحد لمنع التكرار وإسقاط الحقول. قالب ATS السابق مستقل ويُختار من الخدمة نفسها دون صور أو تخصيصات زخرفية.
تُحفظ جميع أقسام السيرة والروابط والحقول الإضافية في PDF، بما فيها وصف التعليم وروابط شهادات الدورات ومعرّفات الاعتماد والتقنيات وتصنيفات الإنجازات. تُطبق الألوان والخطوط المحلية وأحجام الجسم 8–16 مع التحقق من إعدادات JSON المستوردة. يستخدم النص العربي Cairo لضمان الحروف، مع اختيار Poppins/Sukar/Cairo للإنجليزية ودعم Cairo كخط بديل. الصورة المتاحة تُضمّن، والمرجع المحذوف يُتجاوز، وأخطاء القراءة أو الصور التالفة تُبلّغ كأخطاء توليد.
تحقق PDF: 18 اختباراً جديداً؛ 12 عينة (عربية وإنجليزية وطويلة لكل قالب). العينات العادية صفحتان والعينات الطويلة 24 صفحة عند حجم جسم 16. جرى استخراج النص والتحقق من الحقول الإضافية وحدود النص في كل صفحة، وفحص صور الصفحات الأولى والأخيرة بصرياً. كشف الفحص اتجاه فاصلة داخل اسم تقنية إنجليزي وفصل عنوان عن محتواه، وأُصلح كلاهما قبل التسليم. تقرير الصفحات محفوظ في deliveries/part_2_batch_22_pdf_verification.json.
لا توجد اعتمادية Flutter جديدة. يمكن إعادة إنشاء العينات عبر flutter test --no-pub --dart-define=WRITE_PDF_SAMPLES=true test/pdf/pdf_templates_test.dart ثم تشغيل tool/verify_pdf_templates.py ببيئة Python تحتوي pdfplumber وpypdf وpypdfium2 وPillow. هذه أدوات تحقق خارج تطبيق Flutter.
المتبقي للدفعة التالية: فصل شاشة المعاينة والتخصيص، خدمة تصدير PDF مع خيارات الجودة والطباعة والمشاركة، وإزالة ملف المعاينة القديم. لم يُجر اختبار الطباعة والمشاركة على جهاز فعلي في هذه الدفعة.
## الملفات
1. lib/core/services/pdf_service.dart
2. lib/features/resume_builder/presentation/templates/modern_pdf_template.dart
3. lib/features/resume_builder/presentation/templates/classic_pdf_template.dart
4. lib/features/resume_builder/presentation/templates/business_pdf_template.dart
5. lib/features/resume_builder/presentation/templates/technical_pdf_template.dart
6. lib/features/resume_builder/presentation/templates/pdf_template_options.dart
7. lib/features/resume_builder/presentation/templates/styled_pdf_template.dart
8. lib/features/resume_builder/index.dart
9. lib/legacy_app.dart
10. test/pdf/pdf_templates_test.dart
11. tool/verify_pdf_templates.py

## lib/core/services/pdf_service.dart
```dart
import 'dart:io';
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
  Future<Uint8List> generate(ResumeModel resume, {String locale = 'en'}) async {
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
          if (await file.exists()) photo = await file.readAsBytes();
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

## lib/features/resume_builder/presentation/templates/modern_pdf_template.dart
```dart
import 'styled_pdf_template.dart';

/// Timeline accents for work and project entries.
class ModernPdfTemplate extends StyledPdfTemplate {
  const ModernPdfTemplate({super.options, super.fallbackFont, super.photo})
    : super(layout: PdfLayoutStyle.modern);
}

```

## lib/features/resume_builder/presentation/templates/classic_pdf_template.dart
```dart
import 'styled_pdf_template.dart';

/// Traditional centered name and understated section rules.
class ClassicPdfTemplate extends StyledPdfTemplate {
  const ClassicPdfTemplate({super.options, super.fallbackFont, super.photo})
    : super(layout: PdfLayoutStyle.classic);
}

```

## lib/features/resume_builder/presentation/templates/business_pdf_template.dart
```dart
import 'styled_pdf_template.dart';

/// Corporate color bands and clear section hierarchy.
class BusinessPdfTemplate extends StyledPdfTemplate {
  const BusinessPdfTemplate({super.options, super.fallbackFont, super.photo})
    : super(layout: PdfLayoutStyle.business);
}

```

## lib/features/resume_builder/presentation/templates/technical_pdf_template.dart
```dart
import 'styled_pdf_template.dart';

/// Skills and projects prioritized before employment and education.
class TechnicalPdfTemplate extends StyledPdfTemplate {
  const TechnicalPdfTemplate({super.options, super.fallbackFont, super.photo})
    : super(layout: PdfLayoutStyle.technical);
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

## lib/features/resume_builder/presentation/templates/styled_pdf_template.dart
```dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../data/models/resume_model.dart';
import '../../../../translations/ar_sa.dart';
import '../../../../translations/en_us.dart';
import 'base_pdf_template.dart';
import 'pdf_template_options.dart';

/// Distinct presentation styles sharing complete, paginated resume content.
enum PdfLayoutStyle { modern, classic, business, technical }

/// Common text and section renderer keeping long content safely pageable.
class StyledPdfTemplate extends BasePdfTemplate {
  const StyledPdfTemplate({
    required this.layout,
    this.options = const PdfTemplateOptions(),
    this.fallbackFont,
    this.photo,
  });
  final PdfLayoutStyle layout;
  final PdfTemplateOptions options;
  final pw.Font? fallbackFont;
  final Uint8List? photo;

  @override
  Future<Uint8List> build({
    required ResumeModel resume,
    required pw.Font font,
    required bool isArabic,
  }) async {
    final document = pw.Document(
      title: resume.fullName,
      author: resume.fullName,
    );
    final content = <pw.Widget>[];
    final messages = isArabic ? arSa : enUs;
    String label(String key) => messages[key] ?? key;
    final direction = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    String join(Iterable<String?> values) => values
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(' | ');
    String dates(String start, String? end, bool current) =>
        join([start, current ? label('builder_present') : end]);
    Iterable<String> chunks(String value, int limit) sync* {
      for (var line in value.split(RegExp(r'\r?\n'))) {
        while (line.runes.length > limit) {
          final runes = line.runes.toList();
          var stop = limit;
          for (var i = limit; i > limit ~/ 2; i--) {
            if (runes[i] == 32) {
              stop = i;
              break;
            }
          }
          yield String.fromCharCodes(runes.take(stop));
          line = String.fromCharCodes(runes.skip(stop)).trimLeft();
        }
        if (line.isNotEmpty) yield line;
      }
    }

    pw.Text textWidget(
      String value, {
      double? size,
      PdfColor? color,
      bool ltr = false,
    }) => pw.Text(
      value,
      textDirection: ltr || !RegExp(r'[\u0600-\u06ff]').hasMatch(value)
          ? pw.TextDirection.ltr
          : direction,
      style: pw.TextStyle(
        font: font,
        fontFallback: [?fallbackFont],
        fontSize: size ?? options.fontSize,
        color: color ?? PdfColors.black,
        lineSpacing: 3,
      ),
    );
    void text(
      String? value, {
      double? size,
      PdfColor? color,
      bool ltr = false,
      bool timeline = false,
    }) {
      if (value == null || value.trim().isEmpty) return;
      for (final chunk in chunks(
        value,
        (size ?? options.fontSize) > 16 ? 45 : 240,
      )) {
        content.add(
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: timeline && layout == PdfLayoutStyle.modern
                ? pw.BoxDecoration(
                    border: isArabic
                        ? pw.Border(
                            right: pw.BorderSide(
                              color: options.primary,
                              width: 2,
                            ),
                          )
                        : pw.Border(
                            left: pw.BorderSide(
                              color: options.primary,
                              width: 2,
                            ),
                          ),
                  )
                : null,
            child: textWidget(chunk, size: size, color: color, ltr: ltr),
          ),
        );
      }
    }

    void section(String key, bool present) {
      if (!present) return;
      content.add(pw.NewPage(freeSpace: 150));
      content.add(pw.SizedBox(height: 12));
      final title = label(key);
      final coloredBand = layout == PdfLayoutStyle.business;
      content.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            color: coloredBand ? options.primary : null,
            border: !coloredBand
                ? pw.Border(
                    bottom: pw.BorderSide(
                      color: layout == PdfLayoutStyle.classic
                          ? PdfColors.black
                          : options.primary,
                      width: layout == PdfLayoutStyle.modern ? 2 : .7,
                    ),
                  )
                : null,
          ),
          child: textWidget(
            isArabic ? title : title.toUpperCase(),
            size: options.fontSize + 2,
            color: coloredBand ? PdfColors.white : options.primary,
          ),
        ),
      );
      content.add(pw.SizedBox(height: 5));
    }

    void entry() {
      content.add(pw.NewPage(freeSpace: 70));
    }

    if (photo != null) {
      content.add(
        pw.Align(
          alignment: isArabic
              ? pw.Alignment.centerRight
              : pw.Alignment.centerLeft,
          child: pw.Image(
            pw.MemoryImage(photo!),
            width: 64,
            height: 64,
            fit: pw.BoxFit.cover,
          ),
        ),
      );
    }
    for (final chunk in chunks(resume.fullName, 40)) {
      content.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          color: layout == PdfLayoutStyle.business ? options.primary : null,
          alignment: layout == PdfLayoutStyle.classic
              ? pw.Alignment.center
              : isArabic
              ? pw.Alignment.centerRight
              : pw.Alignment.centerLeft,
          child: textWidget(
            chunk,
            size: 24,
            color: layout == PdfLayoutStyle.business
                ? PdfColors.white
                : options.primary,
          ),
        ),
      );
    }
    text(resume.email, ltr: true);
    text(resume.phone, ltr: true);
    text(resume.address);
    for (final link in [
      resume.linkedin,
      resume.github,
      resume.website,
      resume.portfolio,
    ]) {
      text(link, ltr: true, color: options.secondary);
    }
    section('summary', resume.summary?.trim().isNotEmpty ?? false);
    text(resume.summary);
    void skills() {
      section('skills', resume.skills.isNotEmpty);
      for (final item in resume.skills) {
        text('${item.name} (${item.level}/5)');
      }
    }

    void projects() {
      section('projects', resume.projects.isNotEmpty);
      for (final item in resume.projects) {
        entry();
        text(item.name, color: options.primary, timeline: true);
        text(
          dates(item.startDate, item.endDate, item.isCurrent),
          timeline: true,
        );
        text(item.description, timeline: true);
        for (final technology in item.technologies) {
          text(technology, timeline: true);
        }
      }
    }

    if (layout == PdfLayoutStyle.technical) {
      skills();
      projects();
    }
    section('experience', resume.experience.isNotEmpty);
    for (final item in resume.experience) {
      entry();
      text(
        join([item.jobTitle, item.company]),
        color: options.primary,
        timeline: true,
      );
      text(dates(item.startDate, item.endDate, item.isCurrent), timeline: true);
      text(item.description, timeline: true);
    }
    section('education', resume.education.isNotEmpty);
    for (final item in resume.education) {
      entry();
      text(join([item.degree, item.institution, item.year, item.grade]));
      text(item.description);
    }
    if (layout != PdfLayoutStyle.technical) {
      skills();
    }
    section('courses', resume.courses.isNotEmpty);
    for (final item in resume.courses) {
      entry();
      text(join([item.name, item.provider, item.year]));
      text(item.certificateUrl, ltr: true);
    }
    section('certificates', resume.certificates.isNotEmpty);
    for (final item in resume.certificates) {
      entry();
      text(join([item.name, item.organization, item.year, item.credentialId]));
    }
    section('languages', resume.languages.isNotEmpty);
    for (final item in resume.languages) {
      final levelKey = 'builder_language_${item.level.toLowerCase()}';
      text(join([item.name, messages[levelKey] ?? item.level]));
    }
    if (layout != PdfLayoutStyle.technical) {
      projects();
    }
    section('achievements', resume.achievements.isNotEmpty);
    for (final item in resume.achievements) {
      entry();
      text(join([item.name, item.organization, item.date, item.category]));
      text(item.description);
    }
    section('interests', resume.interests?.isNotEmpty ?? false);
    for (final value in resume.interests ?? <String>[]) {
      text(messages['builder_interest_${value.toLowerCase()}'] ?? value);
    }
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        maxPages: 200,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: textWidget(
            '${context.pageNumber} / ${context.pagesCount}',
            size: 9,
            color: options.secondary,
            ltr: true,
          ),
        ),
        build: (_) => content,
      ),
    );
    return document.save();
  }
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
import 'app/routes/app_routes.dart';
import 'core/services/pdf_service.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ==================== MODELS ====================

// ==================== VALIDATORS ====================

// ==================== WIDGETS ====================

// ==================== RESUME BUILDER SCREENS ====================
// Helper Widgets
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
    if (resumeController.currentResume.value?.templateId == 'ats') {
      _primaryColor = Colors.black;
      _secondaryColor = Colors.black;
      _fontFamily = 'Cairo';
      _fontSize = 11;
      _showCustomization = false;
      return;
    }
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
      if (mounted) setState(() => _isGeneratingPDF = false);
    }
  }

  Future<Uint8List> _generatePDF() async {
    final resume = resumeController.currentResume.value;
    if (resume == null) throw StateError('No resume selected');
    final snapshot = resume.copyWith(
      customization: {
        'primaryColor': _primaryColor.toARGB32(),
        'secondaryColor': _secondaryColor.toARGB32(),
        'fontFamily': _fontFamily,
        'fontSize': _fontSize,
      },
    );
    return PdfService().generate(
      snapshot,
      locale: Get.locale?.languageCode ?? 'en',
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
      resumeController.currentResume.refresh();
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
          IconButton(
            key: const ValueKey('preview-check-ats'),
            tooltip: 'ats_checker'.tr,
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () async {
              await Get.toNamed<void>(AppRoutes.atsChecker);
              if (!mounted) return;
              _loadCustomization();
              await _generatePDFAndCache();
            },
          ),
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
          if (resumeController.currentResume.value?.templateId != 'ats')
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

## test/pdf/pdf_templates_test.dart
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/core/services/pdf_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/presentation/templates/pdf_template_options.dart';

class _FailingAssets extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => throw StateError('missing asset');
}

ResumeModel _sample(String id, bool arabic, {bool long = false}) => ResumeModel(
  fullName: arabic ? 'عمر العمري' : 'Alice Developer',
  email: 'alice@example.com',
  phone: '+966500000000',
  address: arabic ? 'الرياض' : 'Riyadh',
  templateId: id,
  summary: arabic
      ? 'مطور تطبيقات بخبرة في البرمجة والعمل الجماعي.'
      : 'Developed useful applications with measurable outcomes.',
  linkedin: 'https://linkedin.com/in/example',
  github: 'https://github.com/example',
  website: 'https://example.com',
  portfolio: 'https://portfolio.example.com',
  education: [
    Education(
      degree: 'EDU-DEGREE',
      institution: 'EDU-INSTITUTION',
      year: '2024',
      grade: 'GRADE-A',
      description: 'EDU-DESCRIPTION',
    ),
  ],
  experience: List.generate(
    long ? 18 : 1,
    (i) => Experience(
      jobTitle: arabic ? 'مهندس برمجيات $i' : 'JOB-TITLE',
      company: 'COMPANY',
      startDate: '01/2024',
      isCurrent: true,
      description: long
          ? ('تطوير تطبيقات وبرامج مفيدة للمستخدمين والعمل الجماعي. ' * 24)
          : 'EXPERIENCE-DESCRIPTION',
    ),
  ),
  skills: [
    Skill(name: 'Dart', level: 5),
    Skill(name: 'Communication', level: 4),
  ],
  courses: [
    Course(
      name: 'COURSE-NAME',
      provider: 'COURSE-PROVIDER',
      year: '2023',
      certificateUrl: 'https://cert.example.com',
    ),
  ],
  certificates: [
    Certificate(
      name: 'CERT-NAME',
      organization: 'CERT-ORG',
      year: '2024',
      credentialId: 'CREDENTIAL-123',
    ),
  ],
  languages: [Language(name: arabic ? 'العربية' : 'English', level: 'Native')],
  projects: [
    Project(
      name: 'PROJECT-NAME',
      description: 'PROJECT-DESCRIPTION',
      startDate: '01/2023',
      endDate: '12/2023',
      technologies: ['Flutter', 'Web, Mobile'],
    ),
  ],
  achievements: [
    Achievement(
      name: 'ACHIEVEMENT-NAME',
      description: 'ACHIEVEMENT-DESCRIPTION',
      date: '01/2024',
      organization: 'AWARD-ORG',
      category: 'CUSTOM-CATEGORY',
    ),
  ],
  interests: ['Reading', 'CUSTOM-INTEREST'],
  customization: {
    'primaryColor': 0xff1565c0,
    'secondaryColor': 0xff455a64,
    'fontFamily': arabic
        ? 'Cairo'
        : id == 'classic'
        ? 'Sukar'
        : 'Poppins',
    'fontSize': long ? 16 : 11,
  },
);
Future<void> _saveSample(String name, List<int> bytes) async {
  if (!const bool.fromEnvironment('WRITE_PDF_SAMPLES')) return;
  try {
    await Directory('tmp/pdfs/templates').create(recursive: true);
    await File('tmp/pdfs/templates/$name.pdf').writeAsBytes(bytes);
  } catch (error) {
    throw StateError('Unable to save test PDF: $error');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final id in ['modern', 'classic', 'business', 'technical']) {
    for (final arabic in [false, true]) {
      test(
        '$id generates complete ${arabic ? 'Arabic' : 'English'} PDF',
        () async {
          final resume = _sample(id, arabic);
          final original = resume.copyWith();
          final bytes = await PdfService().generate(
            resume,
            locale: arabic ? 'ar' : 'en',
          );
          final source = latin1.decode(bytes);
          expect(source.startsWith('%PDF-'), isTrue);
          expect(source, contains('/FontFile2'));
          expect(
            RegExp(r'/Type\s*/Page\b').allMatches(source).length,
            greaterThanOrEqualTo(1),
          );
          expect(resume, original);
          await _saveSample('${id}_${arabic ? 'ar' : 'en'}', bytes);
        },
      );
    }
    test('$id paginates long Arabic at maximum body size', () async {
      final bytes = await PdfService().generate(
        _sample(id, true, long: true),
        locale: 'ar',
      );
      expect(
        RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length,
        greaterThan(2),
      );
      await _saveSample('${id}_long', bytes);
    });
  }
  test('appearance settings tolerate imported malformed values', () {
    final options = PdfTemplateOptions.fromJson({
      'primaryColor': 'bad',
      'secondaryColor': -1,
      'fontFamily': 'remote-font',
      'fontSize': double.nan,
    });
    expect(options.primaryColor, 0xff1565c0);
    expect(options.secondaryColor, 0xff546e7a);
    expect(options.fontFamily, 'Cairo');
    expect(options.fontSize, 11);
    expect(PdfTemplateOptions.fromJson({'fontSize': 500}).fontSize, 16);
    expect(PdfTemplateOptions.fromJson({'fontSize': 1}).fontSize, 8);
  });
  test('missing local fonts report meaningful generation error', () async {
    await expectLater(
      PdfService(assets: _FailingAssets()).generate(_sample('modern', false)),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Unable to generate modern PDF'),
        ),
      ),
    );
  });
  test(
    'unknown template is reported instead of silently substituted',
    () async {
      await expectLater(
        PdfService().generate(_sample('unknown', false)),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Unknown PDF template'),
          ),
        ),
      );
    },
  );
  test('ATS dispatch ignores photo and visual customization', () async {
    final resume = _sample('ats', true)..profilePicture = '/missing.jpg';
    final bytes = await PdfService().generate(resume, locale: 'ar');
    expect(
      RegExp(r'/Subtype\s*/Image').hasMatch(latin1.decode(bytes)),
      isFalse,
    );
  });
  test('styled PDF embeds an available profile image', () async {
    final directory = await Directory.systemTemp.createTemp('cv-pdf-photo-');
    try {
      final file = File('${directory.path}/photo.png');
      await file.writeAsBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEklEQVR4nGNkYPjPwMDAxAAGAAsfAQMU4wsAAAAAAElFTkSuQmCC',
        ),
      );
      final resume = _sample('modern', false)..profilePicture = file.path;
      final bytes = await PdfService().generate(resume);
      expect(
        RegExp(r'/Subtype\s*/Image').hasMatch(latin1.decode(bytes)),
        isTrue,
      );
    } finally {
      await directory.delete(recursive: true);
    }
  });
  test('styled PDF tolerates a deleted photo reference', () async {
    final resume = _sample('modern', false)
      ..profilePicture = '/missing/photo.jpg';
    final bytes = await PdfService().generate(resume);
    expect(
      RegExp(r'/Subtype\s*/Image').hasMatch(latin1.decode(bytes)),
      isFalse,
    );
  });
}

```

## tool/verify_pdf_templates.py
```python
from pathlib import Path
import json
import pdfplumber
import pypdfium2 as pdfium
from pypdf import PdfReader
from PIL import Image, ImageDraw
root=Path('tmp/pdfs/templates')
required=['EDU-DEGREE','EDU-INSTITUTION','GRADE-A','EDU-DESCRIPTION','COMPANY','COURSE-NAME','COURSE-PROVIDER','https://cert.example.com','CERT-NAME','CERT-ORG','CREDENTIAL-123','PROJECT-NAME','PROJECT-DESCRIPTION','Flutter','Web, Mobile','ACHIEVEMENT-NAME','ACHIEVEMENT-DESCRIPTION','AWARD-ORG','CUSTOM-CATEGORY','CUSTOM-INTEREST','alice@example.com','https://portfolio.example.com']
thumbs=[];results=[]
for path in sorted(root.glob('*.pdf')):
 reader=PdfReader(path)
 text='\n'.join(p.extract_text() or '' for p in reader.pages)
 for value in required:
  assert value in text,(path.name,'missing',value)
 if path.stem.endswith('_en'):
  assert 'Alice Developer' in text
  if path.stem.startswith('technical'):
   assert text.index('PROJECTS') < text.index('EXPERIENCE')
 with pdfplumber.open(path) as pdf:
  for page in pdf.pages:
   for char in page.chars:
    assert char['x0']>=37 and char['x1']<=page.width-37,(path.name,'horizontal bounds',char)
    assert char['top']>=28 and char['bottom']<=page.height-28,(path.name,'vertical bounds',char)
 doc=pdfium.PdfDocument(path)
 for i in sorted({0,len(doc)-1}):
  img=doc[i].render(scale=1.2).to_pil().convert('RGB');img.save(root/f'{path.stem}_{i+1}.png');img.thumbnail((290,410))
  tile=Image.new('RGB',(310,450),'white');tile.paste(img,(10,30));ImageDraw.Draw(tile).text((10,8),f'{path.stem} p{i+1}',fill='black');thumbs.append(tile)
 results.append({'sample':path.stem,'pages':len(reader.pages),'characters':len(text)})
contact=Image.new('RGB',(1240,450*((len(thumbs)+3)//4)),'#ddd')
for i,tile in enumerate(thumbs):contact.paste(tile,((i%4)*310,(i//4)*450))
contact.save(root/'contact_sheet.png')
(root/'verification.json').write_text(json.dumps(results,indent=2),encoding='utf8')
print(json.dumps(results))

```


التحقق النهائي: نجحت جميع اختبارات المشروع وعددها 238، منها 18 اختباراً جديداً لهذه الدفعة. التحليل الساكن للكود المفصول والاختبارات دون ملاحظات؛ تبقى 19 ملاحظة في واجهة المعاينة القديمة دون أخطاء تحليل.
