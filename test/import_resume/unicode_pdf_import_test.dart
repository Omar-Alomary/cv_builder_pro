import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/core/services/pdf_service.dart';
import 'package:cv_builder_pro/core/services/simple_pdf_text_extractor.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/data/index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final family in ['Cairo', 'Sukar', 'Poppins']) {
    for (final locale in ['en', 'ar']) {
      test('mixed content stays readable in $locale UI with $family', () async {
        final name = locale == 'en' ? 'عمر العمري' : 'Alice Developer';
        final bytes = await PdfService().generate(
          ResumeModel(
            fullName: name,
            email: 'alice@example.com',
            summary: 'تطوير تطبيقات Flutter and reliable software',
            customization: {'fontFamily': family},
          ),
          locale: locale,
        );
        final text = SimplePdfTextExtractor.extract(bytes);
        expect(text, contains(name));
        expect(text, contains('Flutter'));
        expect(text, contains('تطوير'));
      });
    }
  }
  for (final arabic in [false, true]) {
    test('external Unicode CMap bfrange ${arabic ? 'array' : 'sequential'}', () {
      final cmap = arabic
          ? '1 beginbfrange <0001> <0003> [<0639> <0645> <0631>] endbfrange'
          : '1 beginbfrange <0001> <0003> <0041> endbfrange';
      const content = 'BT /F0 12 Tf <000100020003> Tj ET';
      final source =
          '%PDF-1.4\n1 0 obj << /Type /Font /Subtype /Type0 /Encoding /Identity-H /ToUnicode 3 0 R >> endobj\n'
          '2 0 obj << /Length ${content.length} >> stream\n$content\nendstream endobj\n'
          '3 0 obj << /Length ${cmap.length} >> stream\n$cmap\nendstream endobj\n'
          '4 0 obj << /Type /Page /Resources << /Font << /F0 1 0 R >> >> /Contents 2 0 R >> endobj\n%%EOF';
      expect(
        SimplePdfTextExtractor.extract(
          Uint8List.fromList(ascii.encode(source)),
        ),
        arabic ? 'عمر' : 'ABC',
      );
    });
  }
  for (final id in ['modern', 'classic', 'business', 'technical', 'ats']) {
    for (final family in ['Cairo', 'Sukar', 'Poppins']) {
      for (final arabic in [false, true]) {
        test(
          'import $id $family ${arabic ? 'Arabic' : 'English'} embedded font',
          () async {
            final name = arabic ? 'عمر العمري' : 'Alice Developer';
            final source = ResumeModel(
              fullName: name,
              email: 'alice@example.com',
              phone: '+966500000000',
              templateId: id,
              summary: arabic
                  ? 'مهندس برمجيات يعمل على Flutter وتطوير التطبيقات'
                  : 'Engineer developing Flutter applications',
              customization: {'fontFamily': family},
              skills: [Skill(name: 'Flutter')],
            );
            final bytes = await PdfService().generate(
              source,
              locale: arabic ? 'ar' : 'en',
            );
            final text = SimplePdfTextExtractor.extract(bytes);
            if (const bool.fromEnvironment('WRITE_PDF_SAMPLES')) {
              await Directory('tmp/pdfs/refreshed').create(recursive: true);
              await File(
                'tmp/pdfs/refreshed/${id}_${family}_${arabic ? 'ar' : 'en'}.pdf',
              ).writeAsBytes(bytes);
            }
            expect(text, contains('alice@example.com'));
            expect(text, contains(name));
            final imported = ResumeImportService().fromBytes(bytes, 'pdf');
            expect(imported.email, 'alice@example.com');
            expect(imported.fullName, name);
          },
        );
      }
    }
  }
}
