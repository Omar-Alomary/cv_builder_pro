import '../../data/models/ats_score_model.dart';
import '../../data/models/resume_model.dart';
import '../utils/ats_scorer.dart';
import '../constants/app_constants.dart';
import '../../translations/en_us.dart';
import '../../translations/ar_sa.dart';

/// Analyzes resume data and configured layout; it does not parse a PDF.
class AtsAnalyzerService {
  const AtsAnalyzerService();

  AtsScoreModel analyze(
    ResumeModel resume, {
    String locale = 'en',
    DateTime? now,
    bool? hasPhoto,
    bool? simpleFont,
    bool? singleColumn,
  }) {
    final ar = locale.split(RegExp('[-_]')).first == 'ar';
    String text(String key) => (ar ? arSa : enUs)[key] ?? enUs[key] ?? key;
    final type = AppConstants.templateType(resume.templateId);
    final ats = type == 'ats';
    final configuredFont = resume.customization?['fontFamily'];
    final font = ats
        ? 'Cairo'
        : (configuredFont is String ? configuredFont : 'Poppins');
    final photo =
        hasPhoto ??
        (!ats && (resume.profilePicture?.trim().isNotEmpty ?? false));
    final simple =
        simpleFont ?? {'cairo', 'poppins'}.contains(font.toLowerCase());
    final linear =
        singleColumn ?? {'classic', 'technical', 'ats'}.contains(type);
    final scores = AtsScorer.sectionScores(
      resume,
      now: now,
      hasPhoto: photo,
      simpleFont: simple,
      singleColumn: linear,
    );
    final issues = <AtsIssue>[];
    void check(
      bool passed,
      String severity,
      String category,
      String messageKey,
      String suggestionKey,
    ) {
      if (passed) return;
      issues.add(
        AtsIssue(
          severity: severity,
          category: category,
          description: text(messageKey),
          suggestion: text(suggestionKey),
        ),
      );
    }

    check(
      resume.fullName.trim().isNotEmpty,
      'critical',
      'contact',
      'ats_issue_name',
      'ats_fix_name',
    );
    check(
      AtsScorer.validEmail(resume.email),
      'critical',
      'contact',
      'ats_issue_email',
      'ats_fix_email',
    );
    check(
      AtsScorer.validPhone(resume.phone),
      'critical',
      'contact',
      'ats_issue_phone',
      'ats_fix_phone',
    );
    check(
      AtsScorer.validUrl(resume.linkedin, host: 'linkedin.com'),
      'warning',
      'contact',
      'ats_issue_linkedin',
      'ats_fix_linkedin',
    );
    check(
      AtsScorer.validUrl(resume.website) ||
          AtsScorer.validUrl(resume.portfolio),
      'info',
      'contact',
      'ats_issue_website',
      'ats_fix_website',
    );

    final summary = resume.summary?.trim() ?? '';
    check(
      summary.isNotEmpty,
      'warning',
      'summary',
      'ats_issue_summary_missing',
      'ats_fix_summary_missing',
    );
    check(
      summary.length >= 50 && summary.length <= 300,
      'warning',
      'summary',
      'ats_issue_summary_length',
      'ats_fix_summary_length',
    );
    check(
      AtsScorer.containsAny(summary, [
        ...AtsScorer.keywordGroups.values.expand((terms) => terms),
        ...AtsScorer.technicalTerms,
      ]),
      'info',
      'summary',
      'ats_issue_summary_keywords',
      'ats_fix_summary_keywords',
    );

    check(
      resume.experience.any(
        (entry) =>
            entry.jobTitle.trim().isNotEmpty && entry.company.trim().isNotEmpty,
      ),
      'warning',
      'experience',
      'ats_issue_experience_missing',
      'ats_fix_experience_missing',
    );
    check(
      resume.experience.any(
        (entry) =>
            entry.jobTitle.trim().isNotEmpty &&
            entry.company.trim().isNotEmpty &&
            AtsScorer.containsAny(
              entry.description ?? '',
              AtsScorer.actionVerbs,
            ),
      ),
      'warning',
      'experience',
      'ats_issue_experience_actions',
      'ats_fix_experience_actions',
    );
    check(
      AtsScorer.validExperienceDates(resume, now: now),
      'warning',
      'experience',
      'ats_issue_experience_dates',
      'ats_fix_experience_dates',
    );

    check(
      scores['education']! >= 5,
      'warning',
      'education',
      'ats_issue_education_missing',
      'ats_fix_education_missing',
    );
    check(
      scores['education'] == 10,
      'info',
      'education',
      'ats_issue_education_year',
      'ats_fix_education_year',
    );

    final count = AtsScorer.uniqueSkills(resume).length;
    check(
      count >= 5,
      'warning',
      'skills',
      'ats_issue_skills_minimum',
      'ats_fix_skills_minimum',
    );
    check(
      count >= 10,
      'info',
      'skills',
      'ats_issue_skills_count',
      'ats_fix_skills_count',
    );
    check(
      AtsScorer.diverseSkills(resume),
      'info',
      'skills',
      'ats_issue_skills_diversity',
      'ats_fix_skills_diversity',
    );

    final searchable = AtsScorer.searchableText(resume);
    final missing = AtsScorer.keywordGroups.entries
        .where((entry) => !AtsScorer.containsAny(searchable, entry.value))
        .map((entry) => text('ats_keyword_${entry.key.replaceAll('-', '_')}'))
        .toList();
    check(
      AtsScorer.containsAny(
        searchable,
        AtsScorer.keywordGroups.values.expand((terms) => terms),
      ),
      'info',
      'keywords',
      'ats_issue_keywords_missing',
      'ats_fix_keywords_missing',
    );
    check(
      !AtsScorer.containsAny(searchable, AtsScorer.reviewTerms),
      'warning',
      'keywords',
      'ats_issue_placeholders',
      'ats_fix_placeholders',
    );

    check(!photo, 'warning', 'formatting', 'ats_issue_photo', 'ats_fix_photo');
    check(simple, 'warning', 'formatting', 'ats_issue_font', 'ats_fix_font');
    check(
      linear,
      'warning',
      'formatting',
      'ats_issue_columns',
      'ats_fix_columns',
    );

    final order = {'critical': 0, 'warning': 1, 'info': 2};
    final sorted = <AtsIssue>[
      for (final severity in order.keys)
        ...issues.where((issue) => issue.severity == severity),
    ];
    return AtsScoreModel(
      overallScore: scores.values.fold(0, (sum, score) => sum + score),
      sectionScores: scores,
      issues: sorted,
      suggestions: sorted.map((issue) => issue.suggestion).toSet().toList(),
      missingKeywords: missing,
    );
  }
}
