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
  for (final id in ['modern', 'classic', 'business', 'technical', 'ats']) {
    test(
      '$id English variant overrides Arabic UI locale without mutating input',
      () async {
        final resume = _sample('${id}_en', false);
        final original = resume.copyWith();
        final bytes = await PdfService().generate(resume, locale: 'ar');
        final english = await PdfService().generate(
          resume.copyWith(templateId: id),
          locale: 'en',
        );
        // Embedded text commands must match the English base layout. PDF document
        // identifiers/timestamps differ, so compare decompressed page streams.
        List<String> streams(List<int> data) =>
            RegExp(
              r'stream\r?\n([\s\S]*?)\r?\nendstream',
            ).allMatches(latin1.decode(data)).map((m) {
              try {
                return latin1.decode(zlib.decode(latin1.encode(m[1]!)));
              } catch (_) {
                return m[1]!;
              }
            }).toList();
        expect(streams(bytes), streams(english));
        expect(resume, original);
        expect(latin1.decode(bytes), contains('/FontFile2'));
        if (id == 'ats') {
          expect(
            RegExp(r'/Subtype\s*/Image').hasMatch(latin1.decode(bytes)),
            isFalse,
          );
        }
      },
    );
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
