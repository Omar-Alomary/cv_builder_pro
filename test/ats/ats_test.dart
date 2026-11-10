import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/core/services/ats_analyzer_service.dart';
import 'package:cv_builder_pro/core/utils/ats_scorer.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';

class _Repository implements ResumeRepository {
  bool fail = false;
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw const StorageException('save', 'test failure');
    return resume.copyWith(id: resume.id ?? 1, updatedAt: DateTime.now());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const analyzer = AtsAnalyzerService();
  final now = DateTime(2026, 10, 23);
  ResumeModel complete() => ResumeModel(
    fullName: 'Omer',
    email: 'omer@example.com',
    phone: '+966500000000',
    linkedin: 'https://www.linkedin.com/in/omer',
    website: 'https://example.com',
    summary:
        'Flutter developer with leadership, communication, teamwork and problem-solving experience delivering useful applications.',
    education: [
      Education(degree: 'BSc', institution: 'University', year: '2024'),
    ],
    experience: [
      Experience(
        jobTitle: 'Developer',
        company: 'Company',
        startDate: '01/2024',
        endDate: '10/2025',
        description: 'Developed reliable applications and led delivery.',
      ),
    ],
    skills: [
      'Dart',
      'Flutter',
      'Python',
      'Java',
      'SQL',
      'Git',
      'Teamwork',
      'Leadership',
      'Communication',
      'Problem-solving',
    ].map((name) => Skill(name: name)).toList(),
    templateId: 'ats',
  );

  test(
    'Complete resume reaches exactly 100 with the specified section weights',
    () {
      final score = analyzer.analyze(complete(), now: now);
      expect(score.overallScore, 100);
      expect(score.sectionScores, AtsScorer.sectionMaximums);
      expect(score.issues, isEmpty);
      expect(score.suggestions, isEmpty);
      expect(score.missingKeywords, isEmpty);
    },
  );

  test(
    'Empty ATS resume receives only formatting and no-placeholder points',
    () {
      final score = analyzer.analyze(ResumeModel(templateId: 'ats'), now: now);
      expect(score.overallScore, 15);
      expect(score.sectionScores['experience'], 0);
      expect(score.sectionScores['education'], 0);
      expect(score.issues.first.severity, 'critical');
      final ranks = score.issues
          .map((issue) => AtsIssue.severities.indexOf(issue.severity))
          .toList();
      expect(ranks, orderedEquals([...ranks]..sort()));
      expect(score.suggestions.toSet(), hasLength(score.suggestions.length));
      expect(score.missingKeywords, hasLength(4));
    },
  );

  test(
    'Contact validation rejects malformed data and spoofed LinkedIn domains',
    () {
      final resume = ResumeModel(
        email: 'wrong',
        phone: '123',
        linkedin: 'https://linkedin.com.evil.example/in/user',
        website: 'javascript:alert(1)',
      );
      expect(AtsScorer.contact(resume), 0);
      resume.email = 'valid@example.com';
      resume.phone = '+966 (50) 000-0000';
      resume.linkedin = 'https://linkedin.com/in/user';
      resume.portfolio = 'https://example.com/work';
      expect(AtsScorer.contact(resume), 20);
    },
  );

  test(
    'Summary length boundaries are inclusive and independent of keyword points',
    () {
      for (final length in [49, 50, 300, 301]) {
        final summary = 'Flutter ${List.filled(length - 8, 'x').join()}';
        expect(summary.length, length);
        expect(
          AtsScorer.summary(ResumeModel(summary: summary)),
          length == 50 || length == 300 ? 15 : 10,
        );
      }
    },
  );

  test(
    'Term matching handles complete words, hyphens, Arabic and punctuation',
    () {
      expect(AtsScorer.containsTerm('knowledge', 'led'), false);
      expect(AtsScorer.containsTerm('managedly', 'managed'), false);
      expect(AtsScorer.containsTerm('Led delivery.', 'led'), true);
      expect(
        AtsScorer.containsTerm('Problem-solving', 'problem solving'),
        true,
      );
      expect(AtsScorer.containsTerm('مهارات التَّواصُل', 'التواصل'), true);
      expect(AtsScorer.containsTerm('خبرة في C++ و SQL', 'c++'), true);
    },
  );

  test(
    'Experience checks chronological dates, future dates and current roles',
    () {
      final resume = complete();
      expect(AtsScorer.experience(resume, now: now), 20);
      resume.experience.first.endDate = '01/2023';
      expect(AtsScorer.experience(resume, now: now), 15);
      resume.experience.first.isCurrent = true;
      expect(AtsScorer.experience(resume, now: now), 20);
      resume.experience.first.startDate = '01/2027';
      expect(AtsScorer.experience(resume, now: now), 15);
      resume.experience.first.startDate = '13/2024';
      expect(AtsScorer.validExperienceDates(resume, now: now), false);
      expect(AtsScorer.experience(ResumeModel(), now: now), 0);
      expect(
        AtsScorer.experience(
          ResumeModel(
            experience: [
              Experience(
                jobTitle: '',
                company: '',
                startDate: '01/2024',
                description: 'Led projects',
              ),
            ],
          ),
          now: now,
        ),
        0,
      );
    },
  );

  test('Education accepts expected graduation and rejects malformed years', () {
    final resume = complete();
    resume.education.first.year = '2029';
    expect(AtsScorer.education(resume, now: now), 10);
    resume.education.first.year = 'tomorrow';
    expect(AtsScorer.education(resume, now: now), 5);
  });

  test('Skills count unique names and award diversity separately', () {
    final resume = ResumeModel(
      skills: List.generate(12, (_) => Skill(name: ' Dart ')),
    );
    expect(AtsScorer.skills(resume), 0);
    resume.skills = [
      'Dart',
      'Flutter',
      'Java',
      'SQL',
      'Git',
    ].map((name) => Skill(name: name)).toList();
    expect(AtsScorer.skills(resume), 5);
    expect(AtsScorer.skills(complete()), 15);
  });

  test(
    'Placeholder content loses five keyword points and produces a review issue',
    () {
      final resume = complete()..summary = 'teamwork lorem ipsum';
      final score = analyzer.analyze(resume, now: now);
      expect(score.sectionScores['keywords'], 5);
      expect(
        score.issues.any(
          (issue) =>
              issue.category == 'keywords' && issue.severity == 'warning',
        ),
        true,
      );
    },
  );

  test('Arabic summaries, actions and keyword labels are recognized', () {
    final resume = complete();
    resume.summary =
        'مطوّر تطبيقات يتمتع بمهارات القيادة والتواصل والعمل الجماعي وحل المشكلات في مشاريع البرمجيات.';
    resume.experience.first.description =
        'طورت تطبيقات وحققت نتائج قابلة للقياس.';
    final score = analyzer.analyze(resume, locale: 'ar_SA', now: now);
    expect(score.overallScore, 100);
    final missing = analyzer.analyze(
      ResumeModel(templateId: 'ats'),
      locale: 'ar',
      now: now,
    );
    expect(missing.missingKeywords, contains('حل المشكلات'));
    expect(missing.issues.first.description, contains('اسم'));
  });

  test(
    'Formatting reflects configured output and permits verified overrides',
    () {
      final resume = complete()..profilePicture = '/photo.png';
      expect(analyzer.analyze(resume).sectionScores['formatting'], 10);
      resume.templateId = 'modern';
      resume.customization = {'fontFamily': 'Sukar'};
      expect(analyzer.analyze(resume).sectionScores['formatting'], 0);
      expect(
        analyzer
            .analyze(
              resume,
              hasPhoto: false,
              simpleFont: true,
              singleColumn: true,
            )
            .sectionScores['formatting'],
        10,
      );
    },
  );

  test(
    'Scores always equal section sums and remain within declared bounds',
    () {
      for (final resume in [
        ResumeModel(),
        ResumeModel(templateId: 'ats'),
        complete(),
        complete()..summary = 'lorem ipsum',
      ]) {
        final result = analyzer.analyze(resume, now: now);
        expect(
          result.overallScore,
          result.sectionScores.values.fold<int>(0, (sum, value) => sum + value),
        );
        expect(result.overallScore, inInclusiveRange(0, 100));
        for (final entry in result.sectionScores.entries) {
          expect(
            entry.value,
            inInclusiveRange(0, AtsScorer.sectionMaximums[entry.key]!),
          );
        }
      }
    },
  );

  test(
    'Controller handles no selection and invalidates results when switching resumes',
    () {
      final resumes = ResumeController(repository: _Repository());
      final controller = AtsController(resumeController: resumes);
      controller.onInit();
      addTearDown(controller.onClose);
      addTearDown(resumes.onClose);
      expect(controller.analyze(), isNull);
      expect(controller.errorMessage.value, isEmpty);
      resumes.currentResume.value = complete();
      expect(controller.analyze()!.overallScore, 100);
      resumes.currentResume.value = ResumeModel(fullName: 'Other');
      expect(controller.result.value, isNull);
    },
  );

  test(
    'Applying ATS persists a copy, preserves photo data and reanalyzes',
    () async {
      final repository = _Repository();
      final resumes = ResumeController(repository: repository);
      final controller = AtsController(resumeController: resumes);
      controller.onInit();
      addTearDown(controller.onClose);
      addTearDown(resumes.onClose);
      final original = complete()
        ..templateId = 'modern'
        ..profilePicture = '/photo.png';
      resumes.currentResume.value = original;
      controller.analyze();
      expect(await controller.useAtsTemplate(), true);
      expect(original.templateId, 'modern');
      expect(resumes.currentResume.value!.templateId, 'ats');
      expect(resumes.currentResume.value!.profilePicture, '/photo.png');
      expect(
        resumes.currentResume.value!.customization!['fontFamily'],
        'Cairo',
      );
      expect(controller.result.value!.sectionScores['formatting'], 10);
      expect(controller.isApplyingTemplate.value, false);
    },
  );

  test('Failed ATS save preserves the original selection', () async {
    final repository = _Repository()..fail = true;
    final resumes = ResumeController(repository: repository);
    final controller = AtsController(resumeController: resumes);
    addTearDown(controller.onClose);
    addTearDown(resumes.onClose);
    final original = complete()..templateId = 'modern';
    resumes.currentResume.value = original;
    expect(await controller.useAtsTemplate(), false);
    expect(resumes.currentResume.value, same(original));
    expect(original.templateId, 'modern');
    expect(controller.errorMessage.value, isNotEmpty);
  });
}
