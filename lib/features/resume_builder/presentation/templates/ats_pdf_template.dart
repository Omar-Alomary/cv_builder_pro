import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../data/models/resume_model.dart';
import 'base_pdf_template.dart';
import 'pdf_directional_text.dart';

/// Single-column black text ATS layout with no photos, icons or decorations.
class AtsPdfTemplate extends BasePdfTemplate {
  const AtsPdfTemplate();
  @override
  Future<Uint8List> build({
    required ResumeModel resume,
    required pw.Font font,
    required bool isArabic,
  }) async {
    final document = pw.Document();
    final content = <pw.Widget>[];
    pw.Widget lineWidget(String line, double size, bool rtl) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2),
      child: pw.SizedBox(
        width: double.infinity,
        child: pw.Builder(
          builder: (context) => pdfDirectionalText(
            line,
            align: rtl ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              font: font,
              fontSize: size,
              color: PdfColors.black,
              lineSpacing:
                  size *
                  (1.4 - font.getFont(context).stringMetrics('Ag').maxHeight),
            ),
            direction: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
        ),
      ),
    );
    void text(String? value, {double size = 11, bool? rtl}) {
      if (value == null || value.trim().isEmpty) return;
      for (var line in value.split(RegExp(r'\r?\n'))) {
        if (line.isEmpty) {
          content.add(pw.SizedBox(height: 5));
          continue;
        }
        final limit = size == 20 ? 80 : 400;
        while (line.length > limit) {
          var stop = line.lastIndexOf(' ', limit);
          if (stop < limit ~/ 2) stop = limit;
          content.add(
            lineWidget(
              line.substring(0, stop),
              size,
              rtl ?? RegExp(r'[\u0600-\u06ff]').hasMatch(line),
            ),
          );
          line = line.substring(stop).trimLeft();
        }
        if (line.isNotEmpty) {
          content.add(
            lineWidget(
              line,
              size,
              rtl ?? RegExp(r'[\u0600-\u06ff]').hasMatch(line),
            ),
          );
        }
      }
    }

    void section(String title, bool present) {
      if (!present) return;
      content.add(pw.NewPage(freeSpace: title == 'WORK EXPERIENCE' ? 140 : 90));
      content.add(pw.SizedBox(height: 12));
      text(title, size: 14, rtl: false);
      content.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4),
          height: .5,
          color: PdfColors.black,
        ),
      );
      content.add(pw.SizedBox(height: 5));
    }

    String join(Iterable<String?> values) => values
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(' | ');
    String dates(String start, String? end, bool current) =>
        join([start, current ? (isArabic ? 'حتى الآن' : 'Present') : end]);
    text(resume.fullName, size: 20);
    for (final value in [resume.email, resume.phone]) {
      text(value, rtl: false);
    }
    text(resume.address);
    for (final link in [
      resume.linkedin,
      resume.github,
      resume.website,
      resume.portfolio,
    ]) {
      text(link, rtl: false);
    }
    section('PROFESSIONAL SUMMARY', resume.summary?.trim().isNotEmpty ?? false);
    text(resume.summary);
    section('WORK EXPERIENCE', resume.experience.isNotEmpty);
    for (final item in resume.experience) {
      content.add(pw.NewPage(freeSpace: 90));
      text(join([item.jobTitle, item.company]));
      text(dates(item.startDate, item.endDate, item.isCurrent));
      text(item.description);
      content.add(pw.SizedBox(height: 6));
    }
    section('EDUCATION', resume.education.isNotEmpty);
    for (final item in resume.education) {
      text(join([item.degree, item.institution, item.year, item.grade]));
      text(item.description);
    }
    section('SKILLS', resume.skills.isNotEmpty);
    text(join(resume.skills.map((item) => item.name)));
    section('COURSES', resume.courses.isNotEmpty);
    for (final item in resume.courses) {
      text(join([item.name, item.provider, item.year]));
      text(item.certificateUrl, rtl: false);
    }
    section('CERTIFICATIONS', resume.certificates.isNotEmpty);
    for (final item in resume.certificates) {
      text(join([item.name, item.organization, item.year, item.credentialId]));
    }
    section('LANGUAGES', resume.languages.isNotEmpty);
    for (final item in resume.languages) {
      text(join([item.name, item.level]));
    }
    section('PROJECTS', resume.projects.isNotEmpty);
    for (final item in resume.projects) {
      content.add(pw.NewPage(freeSpace: 90));
      text(item.name);
      text(dates(item.startDate, item.endDate, item.isCurrent));
      text(item.description);
      text(join(item.technologies));
    }
    section('ACHIEVEMENTS', resume.achievements.isNotEmpty);
    for (final item in resume.achievements) {
      text(join([item.name, item.organization, item.date, item.category]));
      text(item.description);
    }
    section('INTERESTS', resume.interests?.isNotEmpty ?? false);
    text(join(resume.interests ?? []));
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(.75 * PdfPageFormat.inch),
        maxPages: 200,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        build: (_) => content,
      ),
    );
    return document.save();
  }
}
