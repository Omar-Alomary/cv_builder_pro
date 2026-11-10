import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/data/index.dart';

void main() {
  test('A new resume has editable independent section lists', () {
    final first = ResumeModel();
    final second = ResumeModel();
    first.skills.add(Skill(name: 'Dart'));
    expect(second.skills, isEmpty);
  });
  ResumeModel sample() => ResumeModel(
    id: 12,
    fullName: 'عمر',
    email: 'omer@example.com',
    phone: '+966500000000',
    address: 'الرياض',
    profilePicture: '/photo.png',
    summary: 'مهندس برمجيات',
    education: [
      Education(
        degree: 'BSc',
        institution: 'University',
        year: '2024',
        grade: 'A',
        description: 'CS',
      ),
    ],
    experience: [
      Experience(
        jobTitle: 'Developer',
        company: 'Company',
        startDate: '01/2024',
        isCurrent: true,
        description: 'Developed apps',
      ),
    ],
    skills: [Skill(name: 'Dart', level: 5)],
    courses: [
      Course(
        name: 'Course',
        provider: 'Provider',
        year: '2024',
        certificateUrl: 'https://example.com',
      ),
    ],
    certificates: [
      Certificate(
        name: 'Cert',
        organization: 'Org',
        year: '2024',
        credentialId: '123',
      ),
    ],
    languages: [Language(name: 'Arabic', level: 'Native')],
    projects: [
      Project(
        name: 'App',
        description: 'Description',
        startDate: '01/2024',
        technologies: ['Dart'],
      ),
    ],
    achievements: [
      Achievement(
        name: 'Award',
        description: 'Description',
        date: '2024',
        organization: 'Org',
        category: 'Tech',
      ),
    ],
    linkedin: 'https://linkedin.com/in/example',
    github: 'https://github.com/example',
    website: 'https://example.com',
    portfolio: 'https://example.com/portfolio',
    interests: ['قراءة'],
    templateId: 'technical',
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
    isFavorite: true,
    customization: {
      'font': 'Cairo',
      'nested': {
        'colors': ['blue'],
      },
    },
  );

  test('Complete resume survives JSON text round trip without field loss', () {
    final original = sample();
    final decoded = ResumeJson.decode(ResumeJson.encode(original));
    expect(decoded, original);
    expect(decoded.toJson(), original.toJson());
    expect(decoded.hashCode, original.hashCode);
  });

  test(
    'copyWith clears nullable fields and preserves false, zero and empty values',
    () {
      final copy = sample().copyWith(
        id: 0,
        summary: null,
        updatedAt: null,
        interests: null,
        customization: null,
        isFavorite: false,
        fullName: '',
        skills: [],
      );
      expect(copy.id, 0);
      expect(copy.summary, isNull);
      expect(copy.updatedAt, isNull);
      expect(copy.interests, isNull);
      expect(copy.customization, isNull);
      expect(copy.isFavorite, false);
      expect(copy.fullName, '');
      expect(copy.skills, isEmpty);
    },
  );

  test('copyWith isolates nested entries, lists and customization', () {
    final original = sample();
    final copy = original.copyWith();
    copy.education.first.degree = 'Changed';
    copy.projects.first.technologies.add('Other');
    ((copy.customization!['nested'] as Map)['colors'] as List).add('red');
    expect(original.education.first.degree, 'BSc');
    expect(original.projects.first.technologies, ['Dart']);
    expect((original.customization!['nested'] as Map)['colors'], ['blue']);
  });

  test('Map key order does not affect equality or hash', () {
    final first = sample();
    final second = first.copyWith(
      customization: {
        'nested': {
          'colors': ['blue'],
        },
        'font': 'Cairo',
      },
    );
    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test('Minimal schema and UTF-8 BOM are supported', () {
    final resume = ResumeJson.decode('\uFEFF{"fullName":"عمر"}');
    expect(resume.fullName, 'عمر');
    expect(resume.templateId, 'modern');
    expect(resume.education, isEmpty);
    expect(resume.createdAt, isA<DateTime>());
  });

  test('Malformed roots, types, dates and list entries are rejected', () {
    for (final source in [
      '[]',
      '{}',
      '{"fullName":1}',
      '{"fullName":"A","skills":"Dart"}',
      '{"fullName":"A","education":[1]}',
      '{"fullName":"A","createdAt":"2024-02-31"}',
      '{"fullName":"A","createdAt":"bad"}',
    ]) {
      expect(() => ResumeJson.decode(source), throwsFormatException);
    }
  });

  test('Template metadata round trips', () {
    const template = TemplateModel(
      id: 'ats',
      name: 'ATS',
      nameAr: 'قالب ATS',
      description: 'Linear',
      descriptionAr: 'خطي',
      type: 'ats',
      language: 'ar',
      icon: 'text',
      previewColor: '#000000',
      previewImage: '/preview.png',
      isFeatured: true,
    );
    final decoded = TemplateModel.fromJson(
      jsonDecode(jsonEncode(template.toJson())) as Map<String, dynamic>,
    );
    expect(decoded, template);
    expect(decoded.hashCode, template.hashCode);
  });

  test('ATS results are immutable and survive round trip', () {
    final scores = {'contact': 20, 'summary': 10};
    final issues = [
      AtsIssue(
        severity: 'warning',
        category: 'summary',
        description: 'Short',
        suggestion: 'Expand',
      ),
    ];
    final result = AtsScoreModel(
      overallScore: 30,
      sectionScores: scores,
      issues: issues,
      suggestions: ['Expand'],
      missingKeywords: ['leadership'],
    );
    scores['contact'] = 0;
    issues.clear();
    expect(result.sectionScores['contact'], 20);
    expect(result.issues, hasLength(1));
    expect(() => result.suggestions.add('Other'), throwsUnsupportedError);
    final decoded = AtsScoreModel.fromJson(
      jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>,
    );
    expect(decoded, result);
    expect(decoded.hashCode, result.hashCode);
    expect(
      () => AtsScoreModel(
        overallScore: 101,
        sectionScores: {},
        issues: [],
        suggestions: [],
        missingKeywords: [],
      ),
      throwsRangeError,
    );
    expect(
      () => AtsIssue(
        severity: 'unknown',
        category: '',
        description: '',
        suggestion: '',
      ),
      throwsArgumentError,
    );
  });
}
