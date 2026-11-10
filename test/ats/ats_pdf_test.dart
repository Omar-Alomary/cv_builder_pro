import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/core/services/pdf_service.dart';
import 'package:cv_builder_pro/data/index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'ATS PDF uses embedded font, A4, and no images even when photo is supplied',
    () async {
      final bytes = await PdfService().generateAts(
        ResumeModel(
          fullName: 'Alice',
          email: 'alice@example.com',
          profilePicture: '/does-not-exist.jpg',
          templateId: 'ats',
          summary: 'Professional summary',
          skills: [Skill(name: 'Dart')],
        ),
      );
      final source = latin1.decode(bytes);
      if (const bool.fromEnvironment('WRITE_ATS_SAMPLES')) {
        await Directory('tmp/pdfs').create(recursive: true);
        await File('tmp/pdfs/ats_en.pdf').writeAsBytes(bytes);
      }
      expect(source.startsWith('%PDF-'), true);
      expect(source, contains('/FontFile2'));
      expect(RegExp(r'/Subtype\s*/Image').hasMatch(source), false);
      expect(RegExp(r'/Type\s*/Page\b').allMatches(source), hasLength(1));
    },
  );
  test(
    'Arabic and long sections produce multiple PDF pages without dropped model fields',
    () async {
      final resume = ResumeModel(
        fullName: 'عمر',
        summary: 'مطور تطبيقات بخبرة في البرمجة والتواصل والعمل الجماعي.',
        templateId: 'ats',
        experience: List.generate(
          30,
          (i) => Experience(
            jobTitle: 'مهندس $i',
            company: 'شركة',
            startDate: '01/2024',
            isCurrent: true,
            description: 'تطوير تطبيقات وبرامج مفيدة للمستخدمين. ' * 20,
          ),
        ),
        education: [
          Education(degree: 'بكالوريوس', institution: 'الجامعة', year: '2024'),
        ],
        courses: [Course(name: 'دورة', provider: 'جهة', year: '2024')],
        certificates: [
          Certificate(name: 'شهادة', organization: 'جهة', year: '2024'),
        ],
        languages: [Language(name: 'العربية', level: 'اللغة الأم')],
        projects: [
          Project(name: 'مشروع', description: 'وصف', startDate: '2024'),
        ],
        achievements: [
          Achievement(name: 'إنجاز', description: 'وصف', date: '2024'),
        ],
        interests: ['القراءة'],
      );
      final original = resume.copyWith();
      final bytes = await PdfService().generateAts(resume, locale: 'ar');
      if (const bool.fromEnvironment('WRITE_ATS_SAMPLES')) {
        await Directory('tmp/pdfs').create(recursive: true);
        await File('tmp/pdfs/ats_ar.pdf').writeAsBytes(bytes);
      }
      expect(
        RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length,
        greaterThan(1),
      );
      expect(resume, original);
    },
  );
}
