import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../data/models/resume_model.dart';
import '../../../../translations/ar_sa.dart';
import '../../../../translations/en_us.dart';
import 'base_pdf_template.dart';
import 'pdf_directional_text.dart';
import 'pdf_template_options.dart';

/// Distinct presentation styles sharing complete, paginated resume content.
enum PdfLayoutStyle { modern, classic, business, technical }

/// Common text and section renderer keeping long content safely pageable.
class StyledPdfTemplate extends BasePdfTemplate {
  const StyledPdfTemplate({
    required this.layout,
    this.options = const PdfTemplateOptions(),
    this.fallbackFont,
    this.boldFont,
    this.photo,
  });
  final PdfLayoutStyle layout;
  final PdfTemplateOptions options;
  final pw.Font? fallbackFont;
  final pw.Font? boldFont;
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

    pw.Widget textWidget(
      String value, {
      double? size,
      PdfColor? color,
      bool ltr = false,
      bool bold = false,
    }) => pdfDirectionalText(
      value,
      direction: ltr || !RegExp(r'[\u0600-\u06ff]').hasMatch(value)
          ? pw.TextDirection.ltr
          : pw.TextDirection.rtl,
      align: !ltr && RegExp(r'[\u0600-\u06ff]').hasMatch(value)
          ? pw.TextAlign.right
          : pw.TextAlign.left,
      style: pw.TextStyle(
        font: bold
            ? (boldFont ?? font)
            : options.fontFamily == 'Poppins' &&
                  RegExp(r'[\u0600-\u06ff]').hasMatch(value)
            ? (fallbackFont ?? font)
            : font,
        fontFallback: [?fallbackFont],
        fontSize: size ?? options.fontSize,
        color: color ?? PdfColor.fromHex('#243247'),
        lineSpacing: 4,
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
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
            child: textWidget(
              chunk,
              size: size,
              color: color,
              ltr: ltr,
              bold: timeline && color != null,
            ),
          ),
        );
      }
    }

    void section(String key, bool present) {
      if (!present) return;
      content.add(
        pw.NewPage(
          freeSpace:
              [
                'experience',
                'education',
                'projects',
                'achievements',
                'certificates',
              ].contains(key)
              ? 140
              : 90,
        ),
      );
      content.add(pw.SizedBox(height: 12));
      final title = label(key);
      final coloredBand = layout == PdfLayoutStyle.business;
      content.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
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
                : pw.Border(
                    bottom: pw.BorderSide(color: options.secondary, width: .7),
                  ),
          ),
          child: textWidget(
            isArabic ? title : title.toUpperCase(),
            size: options.fontSize + 1,
            bold: true,
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
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: pw.BoxDecoration(
            color: layout == PdfLayoutStyle.business ? options.primary : null,
            border: layout == PdfLayoutStyle.technical
                ? (isArabic
                      ? pw.Border(
                          right: pw.BorderSide(
                            color: options.primary,
                            width: 4,
                          ),
                        )
                      : pw.Border(
                          left: pw.BorderSide(color: options.primary, width: 4),
                        ))
                : null,
          ),
          alignment: layout == PdfLayoutStyle.classic
              ? pw.Alignment.center
              : isArabic
              ? pw.Alignment.centerRight
              : pw.Alignment.centerLeft,
          child: textWidget(
            chunk,
            size: 28,
            bold: true,
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
