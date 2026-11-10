import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/data/index.dart';

Uint8List _pdf(String content, {bool compressed = false, String font = ''}) {
  final stream = compressed
      ? zlib.encode(ascii.encode(content))
      : ascii.encode(content);
  return Uint8List.fromList([
    ...ascii.encode(
      '%PDF-1.4\n$font\n1 0 obj\n<< /Length ${stream.length} ${compressed ? '/Filter /FlateDecode' : ''} >>\nstream\n',
    ),
    ...stream,
    ...ascii.encode('\nendstream\nendobj\n%%EOF'),
  ]);
}

Matcher _error(String key) => throwsA(
  isA<ImportException>().having((error) => error.messageKey, 'messageKey', key),
);

void main() {
  final service = ResumeImportService();
  test('reversed Arabic marked content preserves lam-alef ligatures', () {
    final result = service.fromBytes(
      _pdf(
        'BT /F0 12 Tf 1 0 0 1 20 700 Tm /ReversedChars BMC /Span << /ActualText <FEFF06440627> >> BDC (glyph) Tj EMC EMC ET',
      ),
      'pdf',
    );
    expect(result.fullName, 'لا');
  });
  test('PDF category wrapping does not fragment multi-word skills', () {
    final model = service.fromPlainText(
      'Name: Alice\nTECHNICAL SKILLS\nMobile: Flutter, user interface (UI)\nimplementation, Android.\nMethods: debugging, problem\nsolving.\nWORK EXPERIENCE',
    );
    expect(model.skills.map((s) => s.name), [
      'Flutter',
      'user interface (UI) implementation',
      'Android',
      'debugging',
      'problem solving',
    ]);
  });
  test('marked content dictionaries and ActualText are readable', () {
    final result = service.fromBytes(
      _pdf(
        'BT /F0 12 Tf /Span << /MCID 0 /ActualText <FEFF0041006C006900630065> >> BDC 1 0 0 1 20 700 Tm (wrong glyphs) Tj EMC ET',
      ),
      'pdf',
    );
    expect(result.fullName, 'Alice');
  });
  test('structured bilingual text separates sections and contact address', () {
    const text =
        'Ahmed\nPhone: (+967) 779218017 (Mobile) Email address: ahmed@example.com\nAddress:\nRiyadh\nPROFESSIONAL PROFILE\nEngineer using Flutter\nWORK EXPERIENCE\nGoogle\nSenior Engineer\n[01/03/2020 - Current]\nLed a team.\nMicrosoft\nEngineer\n[01/01/2018 - 31/12/2019]\nDeveloped applications.\nEDUCATION & TRAINING\nBachelor of Computer Science\nUniversity [2012 - 2016]\nTECHNICAL SKILLS\nMobile: Flutter, Dart, Flutter\nLANGUAGE SKILLS\nArabic: Native\nEnglish: Fluent';
    final result = service.fromPlainText(text);
    expect(result.address, 'Riyadh');
    expect(result.phone, '+967779218017');
    expect(result.summary, 'Engineer using Flutter');
    expect(result.education.single.year, '2016');
    expect(result.experience, hasLength(2));
    expect(result.experience.first.company, 'Google');
    expect(result.experience.first.isCurrent, true);
    expect(result.experience.last.description, 'Developed applications.');
    expect(result.skills.map((s) => s.name), ['Flutter', 'Dart']);
    expect(result.languages, hasLength(2));
  });
  test('full JSON round trip preserves every field', () {
    final resume = ResumeModel(
      fullName: 'عمر',
      id: 44,
      email: 'test@example.com',
      phone: '+966500000000',
      templateId: 'ats',
      summary: 'Summary',
      education: [
        Education(degree: 'BSc', institution: 'University', year: '2024'),
      ],
      experience: [
        Experience(
          jobTitle: 'Developer',
          company: 'Company',
          startDate: '01/2024',
          isCurrent: true,
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
        Project.fromJson({'name': 'Project'}),
      ],
      achievements: [
        Achievement.fromJson({'title': 'Award'}),
      ],
      interests: ['Reading'],
      linkedin: 'https://linkedin.com/in/test',
      github: 'https://github.com/test',
      website: 'https://example.com',
      portfolio: 'https://example.com/work',
      customization: {'fontSize': 12},
    );
    expect(service.fromJsonText(ResumeJson.encode(resume)), resume);
  });
  test('invalid schema and empty JSON are rejected with helpful keys', () {
    for (final source in [
      '',
      '[]',
      '{"email":"a"}',
      '{"fullName":"A","skills":"Dart"}',
      '{bad}',
    ]) {
      expect(() => service.fromJsonText(source), _error('import_invalid_json'));
    }
  });
  test('UTF8 BOM and UTF16 text are accepted', () {
    const json = '{"fullName":"عمر"}';
    expect(
      service
          .fromBytes(
            Uint8List.fromList([239, 187, 191, ...utf8.encode(json)]),
            'json',
          )
          .fullName,
      'عمر',
    );
    final utf16 = Uint8List.fromList([
      255,
      254,
      ...json.codeUnits.expand((code) => [code & 255, code >> 8]),
    ]);
    expect(service.fromBytes(utf16, 'json').fullName, 'عمر');
    expect(
      () => service.fromBytes(Uint8List.fromList([255, 0]), 'txt'),
      _error('import_text_encoding'),
    );
  });
  test('English text extracts contacts and skills and preserves source', () {
    const text =
        'Name: Alice\nEmail: alice@example.com\nPhone: +1 555 123 4567\nSkills: Dart, Flutter, Dart\nhttps://linkedin.com/in/alice\nEDUCATION\nBSc 2024';
    final result = service.fromPlainText(text);
    expect(result.fullName, 'Alice');
    expect(result.email, 'alice@example.com');
    expect(result.phone, '+1 555 123 4567');
    expect(result.skills.map((skill) => skill.name), ['Dart', 'Flutter']);
    expect(result.summary, text);
    expect(result.linkedin, 'https://linkedin.com/in/alice');
  });
  test('Arabic text labels and commas are extracted', () {
    final result = service.fromPlainText(
      'الاسم الكامل: عمر\nالهاتف: +966500000000\nالمهارات: برمجة، تواصل\nhttps://linkedin.com.evil.test/user',
    );
    expect(result.fullName, 'عمر');
    expect(result.phone, '+966500000000');
    expect(result.skills, hasLength(2));
    expect(result.linkedin, isNull);
  });
  for (final compressed in [false, true]) {
    test('simple PDF extraction compressed=$compressed', () {
      final result = service.fromBytes(
        _pdf(
          r'BT /F1 12 Tf (Alice) Tj (alice@example.com) Tj (Skills: Dart, Flutter) Tj ET',
          compressed: compressed,
        ),
        'pdf',
      );
      expect(result.fullName, 'Alice');
      expect(result.email, 'alice@example.com');
      expect(result.skills, hasLength(2));
    });
  }
  test('PDF escapes are decoded', () {
    final result = service.fromBytes(
      _pdf(r'BT (Alice \(Developer\)) Tj (Skills: D\141rt) Tj ET'),
      'pdf',
    );
    expect(result.fullName, 'Alice (Developer)');
    expect(result.skills.single.name, 'Dart');
  });
  test('PDF scans encryption and unsupported fonts fail explicitly', () {
    expect(
      () => service.fromBytes(_pdf('q Q'), 'pdf'),
      _error('import_pdf_no_text'),
    );
    expect(
      () => service.fromBytes(
        _pdf('BT (Alice) Tj ET', font: '/Encrypt 5 0 R'),
        'pdf',
      ),
      _error('import_pdf_encrypted'),
    );
    expect(
      () => service.fromBytes(
        _pdf('BT <00010002> Tj ET', font: '/Subtype /Type0'),
        'pdf',
      ),
      _error('import_pdf_font_unsupported'),
    );
    expect(
      () => service.fromBytes(
        Uint8List.fromList(ascii.encode('not a PDF')),
        'pdf',
      ),
      _error('import_invalid_pdf'),
    );
  });
  test('oversized empty and unknown formats fail', () {
    expect(
      () => service.fromBytes(Uint8List(0), 'txt'),
      _error('import_empty'),
    );
    expect(
      () => service.fromBytes(Uint8List(10 * 1024 * 1024 + 1), 'json'),
      _error('import_too_large'),
    );
    expect(
      () => service.fromBytes(Uint8List.fromList([65]), 'docx'),
      _error('import_unsupported'),
    );
  });
  test('compressed PDF expansion is bounded', () {
    final bomb = _pdf('A' * (21 * 1024 * 1024), compressed: true);
    expect(() => service.fromBytes(bomb, 'pdf'), _error('import_too_large'));
  });
}
